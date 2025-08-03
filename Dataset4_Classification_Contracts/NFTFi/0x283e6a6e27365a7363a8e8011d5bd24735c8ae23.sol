// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981Upgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981Upgradeable is Initializable, IERC2981Upgradeable, ERC165Upgradeable {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    function __ERC2981_init() internal onlyInitializing {
    }

    function __ERC2981_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC2981Upgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981Upgradeable
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

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
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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
// ArchetypePayouts v0.7.0
//
//        d8888                 888               888
//       d88888                 888               888
//      d88P888                 888               888
//     d88P 888 888d888 .d8888b 88888b.   .d88b.  888888 888  888 88888b.   .d88b.
//    d88P  888 888P"  d88P"    888 "88b d8P  Y8b 888    888  888 888 "88b d8P  Y8b
//   d88P   888 888    888      888  888 88888888 888    888  888 888  888 88888888
//  d8888888888 888    Y88b.    888  888 Y8b.     Y88b.  Y88b 888 888 d88P Y8b.
// d88P     888 888     "Y8888P 888  888  "Y8888   "Y888  "Y88888 88888P"   "Y8888
//                                                            888 888
//                                                       Y8b d88P 888
//

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error InvalidLength();
error InvalidSplitShares();
error TransferFailed();
error BalanceEmpty();
error NotApprovedToWithdraw();

contract ArchetypePayouts {
  event Withdrawal(address indexed src, address token, uint256 wad);
  event FundsAdded(address indexed recipient, address token, uint256 amount);

  mapping(address => mapping(address => uint256)) private _balance;
  mapping(address => mapping(address => bool)) private _approvals;

  function updateBalances(
    uint256 totalAmount,
    address token,
    address[] calldata recipients,
    uint16[] calldata splits
  ) public payable {
    if (recipients.length != splits.length) {
      revert InvalidLength();
    }

    uint256 totalShares = 0;
    for (uint256 i = 0; i < splits.length; i++) {
      totalShares += splits[i];
    }
    if (totalShares != 10000) {
      revert InvalidSplitShares();
    }

    if (token == address(0)) {
      // ETH payments
      uint256 totalReceived = msg.value;
      for (uint256 i = 0; i < recipients.length; i++) {
        if (splits[i] > 0) {
          uint256 amountToAdd = (totalReceived * splits[i]) / 10000;
          _balance[recipients[i]][token] += amountToAdd;
          emit FundsAdded(recipients[i], token, amountToAdd);
        }
      }
    } else {
      // ERC20 payments
      IERC20 paymentToken = IERC20(token);
      bool success = paymentToken.transferFrom(msg.sender, address(this), totalAmount);
      if (!success) {
        revert TransferFailed();
      }

      for (uint256 i = 0; i < recipients.length; i++) {
        if (splits[i] > 0) {
          uint256 amountToAdd = (totalAmount * splits[i]) / 10000;
          _balance[recipients[i]][token] += amountToAdd;
          emit FundsAdded(recipients[i], token, amountToAdd);
        }
      }
    }
  }

  function withdraw() external {
    address msgSender = msg.sender;
    _withdraw(msgSender, msgSender, address(0));
  }

  function withdrawTokens(address[] memory tokens) external {
    address msgSender = msg.sender;

    for (uint256 i = 0; i < tokens.length; i++) {
      _withdraw(msgSender, msgSender, tokens[i]);
    }
  }

  function withdrawFrom(address from, address to) public {
    if (from != msg.sender && !_approvals[from][to]) {
      revert NotApprovedToWithdraw();
    }
    _withdraw(from, to, address(0));
  }

  function withdrawTokensFrom(
    address from,
    address to,
    address[] memory tokens
  ) public {
    if (from != msg.sender && !_approvals[from][to]) {
      revert NotApprovedToWithdraw();
    }
    for (uint256 i = 0; i < tokens.length; i++) {
      _withdraw(from, to, tokens[i]);
    }
  }

  function _withdraw(
    address from,
    address to,
    address token
  ) internal {
    uint256 wad;

    wad = _balance[from][token];
    _balance[from][token] = 0;

    if (wad == 0) {
      revert BalanceEmpty();
    }

    if (token == address(0)) {
      bool success = false;
      (success, ) = to.call{ value: wad }("");
      if (!success) {
        revert TransferFailed();
      }
    } else {
      IERC20 erc20Token = IERC20(token);
      bool success = erc20Token.transfer(to, wad);
      if (!success) {
        revert TransferFailed();
      }
    }
    emit Withdrawal(from, token, wad);
  }

  function approveWithdrawal(address delegate, bool approved) external {
    _approvals[msg.sender][delegate] = approved;
  }

  function isApproved(address from, address delegate) external view returns (bool) {
    return _approvals[from][delegate];
  }

  function balance(address recipient) external view returns (uint256) {
    return _balance[recipient][address(0)];
  }

  function balanceToken(address recipient, address token) external view returns (uint256) {
    return _balance[recipient][token];
  }
}
// SPDX-License-Identifier: MIT
// Archetype v0.8.0 - BURGERS404
//
//        d8888                 888               888
//       d88888                 888               888
//      d88P888                 888               888
//     d88P 888 888d888 .d8888b 88888b.   .d88b.  888888 888  888 88888b.   .d88b.
//    d88P  888 888P"  d88P"    888 "88b d8P  Y8b 888    888  888 888 "88b d8P  Y8b
//   d88P   888 888    888      888  888 88888888 888    888  888 888  888 88888888
//  d8888888888 888    Y88b.    888  888 Y8b.     Y88b.  Y88b 888 888 d88P Y8b.
// d88P     888 888     "Y8888P 888  888  "Y8888   "Y888  "Y88888 88888P"   "Y8888
//                                                            888 888
//                                                       Y8b d88P 888
//                                                        "Y88P"  888

pragma solidity ^0.8.20;

import "./ArchetypeLogicBurgers404.sol";
import "dn404/src/DN420.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "solady/src/utils/LibString.sol";
import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";

contract ArchetypeBurgers404 is DN420, Initializable, OwnableUpgradeable, ERC2981Upgradeable {
  //
  // EVENTS
  //
  event Invited(bytes32 indexed key, bytes32 indexed cid);
  event Referral(address indexed affiliate, address token, uint128 wad, uint256 numMints);
  event Withdrawal(address indexed src, address token, uint128 wad);

  //
  // VARIABLES
  //
  mapping(bytes32 => AdvancedInvite) public invites;
  mapping(bytes32 => uint256) public packedBonusDiscounts;
  mapping(address => mapping(bytes32 => uint256)) private _minted;
  mapping(bytes32 => uint256) private _listSupply;
  mapping(address => uint128) private _ownerBalance;
  mapping(address => mapping(address => uint128)) private _affiliateBalance;
  mapping(bytes32 => bytes32) public pairedListKeys; 

  string private _name;
  string private _symbol;
  uint256 private totalErc20Mints;
  Config public config;
  PayoutConfig public payoutConfig;
  uint256 public flags;
  // bit 0: uriLocked
  // bit 1: maxSupplyLocked 
  // bit 2: ownerAltPayoutLocked

  //
  // METHODS
  //
  function initialize(
    string memory name_,
    string memory symbol_,
    Config calldata config_,
    PayoutConfig calldata payoutConfig_,
    address _receiver
  ) external initializer {
    _name = name_;
    _symbol = symbol_;
    config = config_;

    _initializeDN420(0, address(0));

    // check max bps not reached and min platform fee.
    if (
      config_.affiliateFee > MAXBPS ||
      config_.affiliateDiscount > MAXBPS ||
      config_.affiliateSigner == address(0) ||
      config_.maxBatchSize == 0
    ) {
      revert InvalidConfig();
    }
    __Ownable_init();

    uint256 totalShares = payoutConfig_.ownerBps +
      payoutConfig_.platformBps +
      payoutConfig_.partnerBps +
      payoutConfig_.superAffiliateBps;

    if (payoutConfig_.platformBps < 250 || totalShares != 10000) {
      revert InvalidSplitShares();
    }
    payoutConfig = payoutConfig_;
    setDefaultRoyalty(_receiver, config.defaultRoyalty);
  }

  //
  // PUBLIC
  //
  function mint(
    Auth calldata auth,
    uint256 quantity,
    address affiliate,
    bytes calldata signature
  ) external payable {
    mintTo(auth, quantity, _msgSender(), affiliate, signature);
  }

  function batchMintTo(
    Auth calldata auth,
    address[] calldata toList,
    uint256[] calldata quantityList,
    address affiliate,
    bytes calldata signature
  ) external payable {
    if (quantityList.length != toList.length) {
      revert InvalidConfig();
    }

    AdvancedInvite storage invite = invites[auth.key];
    uint256 packedDiscount = packedBonusDiscounts[auth.key];

    uint256 totalQuantity;
    uint256 totalBonusMints;

    for (uint256 i; i < toList.length; ) {
      uint256 quantityToAdd;
      if (invite.unitSize > 1) {
        quantityToAdd = quantityList[i] * invite.unitSize;
      } else {
        quantityToAdd = quantityList[i];
      }

      uint256 numBonusMints = ArchetypeLogicBurgers404.bonusMintsAwarded(quantityToAdd / config.erc20Ratio, packedDiscount) * config.erc20Ratio;
      _mintNext(toList[i], (quantityToAdd + numBonusMints) * ERC20_UNIT, "");

      totalQuantity += quantityToAdd;
      totalBonusMints += numBonusMints;

      unchecked {
        ++i;
      }
    }

    validateAndCreditMint(invite, auth, totalQuantity, totalBonusMints, totalErc20Mints, affiliate, signature);
  }

  function mintTo(
    Auth calldata auth,
    uint256 quantity,
    address to,
    address affiliate,
    bytes calldata signature
  ) public payable {
    AdvancedInvite storage invite = invites[auth.key];
    uint256 packedDiscount = packedBonusDiscounts[auth.key];

    if (invite.unitSize > 1) {
      quantity = quantity * invite.unitSize;
    }

    uint256 numBonusMints = ArchetypeLogicBurgers404.bonusMintsAwarded(quantity / config.erc20Ratio, packedDiscount) * config.erc20Ratio;
    _mintNext(to, (quantity + numBonusMints) * ERC20_UNIT, "");

    validateAndCreditMint(invite, auth, quantity, numBonusMints, totalErc20Mints, affiliate, signature);
  }

  function validateAndCreditMint(
    AdvancedInvite storage invite,
    Auth calldata auth,
    uint256 quantity,
    uint256 numBonusMints,
    uint256 curSupply,
    address affiliate,
    bytes calldata signature
  ) internal {
    uint256 totalQuantity = quantity + numBonusMints;
    ValidationArgs memory args;
    {
      bytes32 pairedKey = pairedListKeys[auth.key];
      uint256 pairedSupply = pairedKey != 0 ? _listSupply[bytes32(uint256(pairedKey) - 1)]: 0;
      args = ValidationArgs({
        owner: owner(),
        affiliate: affiliate,
        quantity: totalQuantity,
        curSupply: curSupply,
        listSupply: _listSupply[auth.key],
        pairedSupply: pairedSupply
      });
    }

    uint128 cost = uint128(
      ArchetypeLogicBurgers404.computePrice(
        invite,
        config.affiliateDiscount,
        quantity,
        args.listSupply,
        args.affiliate != address(0)
      )
    );

    ArchetypeLogicBurgers404.validateMint(invite, config, auth, _minted, signature, args, cost);

    if (invite.limit < invite.maxSupply) {
      _minted[_msgSender()][auth.key] += totalQuantity;
    }
    if (invite.maxSupply < UINT32_MAX) {
      _listSupply[auth.key] += totalQuantity;
    }
    totalErc20Mints += totalQuantity;

    ArchetypeLogicBurgers404.updateBalances(
      invite,
      config,
      _ownerBalance,
      _affiliateBalance,
      affiliate,
      quantity,
      cost
    );

    if (msg.value > cost) {
      _refund(_msgSender(), msg.value - cost);
    }
  }

  function burnToRemint(uint256[] calldata tokenIds) public {
    if(config.remintPremium == 0) {
      revert burnToRemintDisabled();
    }

    if(tokenIds.length < 1) {
      revert invalidTokenIdLength();
    }

    address msgSender = _msgSender();
    uint256 mintQuantity = 1 * _unit();
    uint256 burnQuantity =  mintQuantity * config.remintPremium / 10000;
    uint256 msgSenderBalance = balanceOf(msgSender);
    uint256 change = 0;

    // transfer nft 1
    safeTransferNFT(msgSender, 0x000000000000000000000000000000000000dEaD, tokenIds[0], "");

    // if premium will make minter lose an nft, transfer nft 2 and give back change, otherwise just transfer erc20
    if(msgSenderBalance % _unit() < burnQuantity) {
      if(tokenIds.length < 2) {
        revert invalidTokenIdLength();
      }
      _safeTransferNFT(msgSender, msgSender, 0x000000000000000000000000000000000000dEaD, tokenIds[1], "");
      change += _unit() - burnQuantity;
    } else {
      _transfer(msgSender, 0x000000000000000000000000000000000000dEaD, burnQuantity, "");
    }

    // remint
    _mintNext(msgSender, mintQuantity + change, "");
  }

  function withdraw() external {
    address[] memory tokens = new address[](1);
    tokens[0] = address(0);
    withdrawTokens(tokens);
  }

  function withdrawTokens(address[] memory tokens) public {
    ArchetypeLogicBurgers404.withdrawTokens(payoutConfig, _ownerBalance, owner(), tokens);
  }

  function withdrawAffiliate() external {
    address[] memory tokens = new address[](1);
    tokens[0] = address(0);
    withdrawTokensAffiliate(tokens);
  }

  function withdrawTokensAffiliate(address[] memory tokens) public {
    ArchetypeLogicBurgers404.withdrawTokensAffiliate(_affiliateBalance, tokens);
  }

  function ownerBalance() external view returns (uint128) {
    return _ownerBalance[address(0)];
  }

  function ownerBalanceToken(address token) external view returns (uint128) {
    return _ownerBalance[token];
  }

  function affiliateBalance(address affiliate) external view returns (uint128) {
    return _affiliateBalance[affiliate][address(0)];
  }

  function affiliateBalanceToken(address affiliate, address token) external view returns (uint128) {
    return _affiliateBalance[affiliate][token];
  }

  function minted(address minter, bytes32 key) external view returns (uint256) {
    return _minted[minter][key];
  }

  function listSupply(bytes32 key) external view returns (uint256) {
    return _listSupply[key];
  }

  function numErc20Minted() public view returns (uint256) {
    return totalErc20Mints;
  }

  function numNftsMinted() public view returns (uint256) {
    return totalErc20Mints / config.erc20Ratio;
  }

  function balanceOfNFT(address owner) public view returns (uint256) {
    return _balanceOfNFT(owner);
  }

  function exists(uint256 id) external view returns (bool) {
    return _exists(id);
  }

  function platform() external pure returns (address) {
    return PLATFORM;
  }

  function computePrice(
    bytes32 key,
    uint256 quantity,
    bool affiliateUsed
  ) external view returns (uint256) {
    AdvancedInvite storage i = invites[key];
    uint256 listSupply_ = _listSupply[key];
    return ArchetypeLogicBurgers404.computePrice(i, config.affiliateDiscount, quantity, listSupply_, affiliateUsed);
  }

  //
  // Overides
  //

  function name() public view override returns (string memory) {
    return _name;
  }

  function symbol() public view override returns (string memory) {
    return _symbol;
  }

  function uri(uint256 tokenId) public view override returns (string memory) {
    if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

    return
      bytes(config.baseUri).length != 0
        ? string(abi.encodePacked(config.baseUri, LibString.toString(tokenId)))
        : "";
  }

  //
  // OWNER ONLY
  //

  function setBaseURI(string memory baseUri) external _onlyOwner {
    if (_getFlag(0)) {
      revert LockedForever();
    }

    config.baseUri = baseUri;
  }

  /// @notice the password is "forever"
  function lockURI(string calldata password) external _onlyOwner {
    _checkPassword(password);
    _setFlag(0);
  }

  // max supply cannot subceed total supply. Be careful changing.
  function setMaxSupply(uint32 maxSupply) external _onlyOwner {
    if (_getFlag(1)) {
      revert LockedForever();
    }

    if (maxSupply < numErc20Minted()) {
      revert MaxSupplyExceeded();
    }

    config.maxSupply = maxSupply;
  }

  /// @notice the password is "forever"
  function lockMaxSupply(string calldata password) external _onlyOwner {
    _checkPassword(password);
    _setFlag(1);
  }

  function setAffiliateFee(uint16 affiliateFee) external _onlyOwner {
    if (affiliateFee > MAXBPS) {
      revert InvalidConfig();
    }

    config.affiliateFee = affiliateFee;
  }

  function setAffiliateDiscount(uint16 affiliateDiscount) external _onlyOwner {
    if (affiliateDiscount > MAXBPS) {
      revert InvalidConfig();
    }

    config.affiliateDiscount = affiliateDiscount;
  }

  function setOwnerAltPayout(address ownerAltPayout) external _onlyOwner {
    if (_getFlag(2)) {
      revert LockedForever();
    }

    payoutConfig.ownerAltPayout = ownerAltPayout;
  }

  /// @notice the password is "forever"
  function lockOwnerAltPayout(string calldata password) external _onlyOwner {
    _checkPassword(password);
    _setFlag(2);
  }

  function setMaxBatchSize(uint32 maxBatchSize) external _onlyOwner {
    config.maxBatchSize = maxBatchSize;
  }

  function setRemintPremium(uint16 remintPremium) external _onlyOwner {
    config.remintPremium = remintPremium;
  }

  // Up to 8 discount tiers: [discount7][discount6][discount5][discount4][discount3][discount2][discount1][discount0]
  function setBonusDiscounts(bytes32 _key, BonusDiscount[] calldata _bonusDiscounts) public onlyOwner {
      if(_bonusDiscounts.length > 8) {
        revert InvalidConfig();
      }
      
      uint256 packed;
      for (uint8 i = 0; i < _bonusDiscounts.length; i++) {
          if (i > 0 && _bonusDiscounts[i].numMints >= _bonusDiscounts[i - 1].numMints) {
              revert InvalidConfig();
          }
          uint32 discount = (uint32(_bonusDiscounts[i].numMints) << 16) | uint32(_bonusDiscounts[i].numBonusMints);
          packed |= uint256(discount) << (32 * i);
      }
      packedBonusDiscounts[_key] = packed;
  }

  function setBonusInvite(
    bytes32 _key,
    bytes32 _cid,
    AdvancedInvite calldata _advancedInvite,
    BonusDiscount[] calldata _bonusDiscount
  ) external _onlyOwner {
    setBonusDiscounts(_key, _bonusDiscount);
    setAdvancedInvite(_key, _cid, _advancedInvite);
  }

  function setInvite(
    bytes32 _key,
    bytes32 _cid,
    Invite calldata _invite
  ) external _onlyOwner {
    setAdvancedInvite(_key, _cid, AdvancedInvite({
      price: _invite.price,
      reservePrice: _invite.price,
      delta: 0,
      start: _invite.start,
      end: _invite.end,
      limit: _invite.limit,
      maxSupply: _invite.maxSupply,
      interval: 0,
      unitSize: _invite.unitSize,
      tokenAddress: _invite.tokenAddress,
      isBlacklist: _invite.isBlacklist
    }));
  }

  function setAdvancedInvite(
    bytes32 _key,
    bytes32 _cid,
    AdvancedInvite memory _AdvancedInvite
  ) public _onlyOwner {
    // approve token for withdrawals if erc20 list
    if (_AdvancedInvite.tokenAddress != address(0)) {
      bool success = IERC20(_AdvancedInvite.tokenAddress).approve(PAYOUTS, 2**256 - 1);
      if (!success) {
        revert NotApprovedToTransfer();
      }
    }
    if (_AdvancedInvite.start < block.timestamp) {
      _AdvancedInvite.start = uint32(block.timestamp);
    }
    invites[_key] = _AdvancedInvite;
    emit Invited(_key, _cid);
  }

  // method will pair the supplies of two invite lists
  function setPairedInvite(bytes32 key1, bytes32 key2) external _onlyOwner {
    if(invites[key1].maxSupply != invites[key2].maxSupply) {
      revert InvalidConfig();
    }
    pairedListKeys[key1] = bytes32(uint256(key2) + 1);
    pairedListKeys[key2] = bytes32(uint256(key1) + 1);
  }

  //
  // INTERNAL
  //

  function _unit() internal view override returns (uint256) {
    return ERC20_UNIT * uint256(config.erc20Ratio);
  }

  function _msgSender() internal view override returns (address) {
    return msg.sender == BATCH ? tx.origin : msg.sender;
  }

  modifier _onlyOwner() {
    if (_msgSender() != owner()) {
      revert NotOwner();
    }
    _;
  }

  function _refund(address to, uint256 refund) internal {
    (bool success, ) = payable(to).call{ value: refund }("");
    if (!success) {
      revert TransferFailed();
    }
  }

  function _checkPassword(string calldata password) internal pure {
    if (keccak256(abi.encodePacked(password)) != keccak256(abi.encodePacked("forever"))) {
      revert WrongPassword();
    }
  }

  function _setFlag(uint256 flag) internal {
    flags |= 1 << flag;
  }

  function _getFlag(uint256 flag) internal view returns (bool) {
    return (flags & (1 << flag)) != 0;
  }

  //ERC2981 ROYALTY
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(DN420, ERC2981Upgradeable)
    returns (bool)
  {
    // Supports the following `interfaceId`s:
    // - IERC165: 0x01ffc9a7
    // - ERC1155: 0xd9b67a26
    // - ERC1155MetadataURI: 0x0e89341c
    // - IERC2981: 0x2a55205a
    return
      DN420.supportsInterface(interfaceId) || ERC2981Upgradeable.supportsInterface(interfaceId);
  }

  function setDefaultRoyalty(address receiver, uint16 feeNumerator) public _onlyOwner {
    config.defaultRoyalty = feeNumerator;
    _setDefaultRoyalty(receiver, feeNumerator);
  }
}
// SPDX-License-Identifier: MIT
// ArchetypeLogic v0.8.0 - BURGERS404
//
//        d8888                 888               888
//       d88888                 888               888
//      d88P888                 888               888
//     d88P 888 888d888 .d8888b 88888b.   .d88b.  888888 888  888 88888b.   .d88b.
//    d88P  888 888P"  d88P"    888 "88b d8P  Y8b 888    888  888 888 "88b d8P  Y8b
//   d88P   888 888    888      888  888 88888888 888    888  888 888  888 88888888
//  d8888888888 888    Y88b.    888  888 Y8b.     Y88b.  Y88b 888 888 d88P Y8b.
// d88P     888 888     "Y8888P 888  888  "Y8888   "Y888  "Y88888 88888P"   "Y8888
//                                                            888 888
//                                                       Y8b d88P 888
//                                                        "Y88P"  888

pragma solidity ^0.8.20;

import "../ArchetypePayouts.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "solady/src/utils/MerkleProofLib.sol";
import "solady/src/utils/ECDSA.sol";

error InvalidConfig();
error MintNotYetStarted();
error MintEnded();
error WalletUnauthorizedToMint();
error InsufficientEthSent();
error ExcessiveEthSent();
error Erc20BalanceTooLow();
error MaxSupplyExceeded();
error ListMaxSupplyExceeded();
error NumberOfMintsExceeded();
error MintingPaused();
error InvalidReferral();
error InvalidSignature();
error MaxBatchSizeExceeded();
error NotTokenOwner();
error NotPlatform();
error NotOwner();
error NotShareholder();
error NotApprovedToTransfer();
error InvalidAmountOfTokens();
error WrongPassword();
error LockedForever();
error Blacklisted();
error URIQueryForNonexistentToken();
error invalidTokenIdLength();
error burnToRemintDisabled();

//
// STRUCTS
//
struct Auth {
  bytes32 key;
  bytes32[] proof;
}

struct BonusDiscount {
  uint16 numMints;
  uint16 numBonusMints;
}

struct Config {
  string baseUri;
  address affiliateSigner;
  uint32 maxSupply; // in erc20
  uint32 maxBatchSize; // in erc20
  uint16 affiliateFee; //BPS
  uint16 affiliateDiscount; // BPS
  uint16 defaultRoyalty; //BPS
  uint16 remintPremium; //BPS premium for burning and reminting a new token
  uint16 erc20Ratio; // number of erc20 (10**18) equal to one nft
}

struct PayoutConfig {
  uint16 ownerBps;
  uint16 platformBps;
  uint16 partnerBps;
  uint16 superAffiliateBps;
  address partner;
  address superAffiliate;
  address ownerAltPayout;
}

struct AdvancedInvite {
  uint128 price; // in erc20
  uint128 reservePrice; // in erc20
  uint128 delta; // in erc20
  uint32 maxSupply; // in erc20
  uint32 limit; // in erc20
  uint32 start;
  uint32 end;
  uint32 interval;
  uint32 unitSize; // mint 1 get x
  address tokenAddress;
  bool isBlacklist;
}

struct Invite {
  uint128 price; 
  uint32 maxSupply; // in erc20
  uint32 limit; // in erc20
  uint32 start;
  uint32 end;
  uint32 unitSize; // mint 1 get x
  address tokenAddress;
  bool isBlacklist;
}

struct ValidationArgs {
  address owner;
  address affiliate;
  uint256 quantity;
  uint256 curSupply;
  uint256 listSupply;
  uint256 pairedSupply;
}

// UPDATE CONSTANTS BEFORE DEPLOY
address constant PLATFORM = 0x86B82972282Dd22348374bC63fd21620F7ED847B;
address constant BATCH = 0x6Bc558A6DC48dEfa0e7022713c23D65Ab26e4Fa7;
address constant PAYOUTS = 0xaAfdfA4a935d8511bF285af11A0544ce7e4a1199;
uint16 constant MAXBPS = 5000; // max fee or discount is 50%
uint32 constant UINT32_MAX = 2**32 - 1;
uint256 constant ERC20_UNIT = 10 ** 18;

library ArchetypeLogicBurgers404 {
  //
  // EVENTS
  //
  event Invited(bytes32 indexed key, bytes32 indexed cid);
  event Referral(address indexed affiliate, address token, uint128 wad, uint256 numMints);
  event Withdrawal(address indexed src, address token, uint128 wad);

  // calculate price based on affiliate usage and mint discounts
  function computePrice(
    AdvancedInvite storage invite,
    uint16 affiliateDiscount,
    uint256 numTokens,
    uint256 listSupply,
    bool affiliateUsed
  ) public view returns (uint256) {
    uint256 price = invite.price;
    uint256 cost;
    if (invite.interval > 0 && invite.delta > 0) {
      // Apply dutch pricing
      uint256 diff = (((block.timestamp - invite.start) / invite.interval) * invite.delta);
      if (price > invite.reservePrice) {
        if (diff > price - invite.reservePrice) {
          price = invite.reservePrice;
        } else {
          price = price - diff;
        }
      } else if (price < invite.reservePrice) {
        if (diff > invite.reservePrice - price) {
          price = invite.reservePrice;
        } else {
          price = price + diff;
        }
      }
      cost = price * numTokens;
    } else if (invite.interval == 0 && invite.delta > 0) {
      // Apply linear curve
      uint256 lastPrice = price + invite.delta * listSupply;
      cost = lastPrice * numTokens + (invite.delta * numTokens * (numTokens - 1)) / 2;
    } else {
      cost = price * numTokens;
    }

    if (affiliateUsed) {
      cost = cost - ((cost * affiliateDiscount) / 10000);
    }

    return cost;
  }

  function bonusMintsAwarded(uint256 numNfts, uint256 packedDiscount) internal pure returns (uint256) {
    for (uint8 i = 0; i < 8; i++) {
        uint32 discount = uint32((packedDiscount >> (32 * i)) & 0xFFFFFFFF);
        uint16 tierNumMints = uint16(discount >> 16);
        uint16 tierBonusMints = uint16(discount);
        
        if (tierNumMints == 0) {
            break; // End of valid discounts
        }
        
        if (numNfts >= tierNumMints) {
            return (numNfts / tierNumMints) * tierBonusMints;
        }
    }
    return 0;
  }

  function validateMint(
    AdvancedInvite storage i,
    Config storage config,
    Auth calldata auth,
    mapping(address => mapping(bytes32 => uint256)) storage minted,
    bytes calldata signature,
    ValidationArgs memory args,
    uint128 cost
  ) public view {
    address msgSender = _msgSender();
    if (args.affiliate != address(0)) {
      if (
        args.affiliate == PLATFORM || args.affiliate == args.owner || args.affiliate == msgSender
      ) {
        revert InvalidReferral();
      }
      validateAffiliate(args.affiliate, signature, config.affiliateSigner);
    }

    if (i.limit == 0) {
      revert MintingPaused();
    }

    if (!i.isBlacklist) {
      if (!verify(auth, i.tokenAddress, msgSender)) {
        revert WalletUnauthorizedToMint();
      }
    } else {
      if (verify(auth, i.tokenAddress, msgSender)) {
        revert Blacklisted();
      }
    }

    if (block.timestamp < i.start) {
      revert MintNotYetStarted();
    }

    if (i.end > i.start && block.timestamp > i.end) {
      revert MintEnded();
    }

    if (i.limit < i.maxSupply) {
      uint256 totalAfterMint = minted[msgSender][auth.key] + args.quantity;

      if (totalAfterMint > i.limit) {
        revert NumberOfMintsExceeded();
      }
    }

    if (i.maxSupply < config.maxSupply) {
      uint256 totalAfterMint = args.listSupply + args.pairedSupply + args.quantity;
        if (totalAfterMint > i.maxSupply) {
            revert ListMaxSupplyExceeded();
        }
    }

    if (args.quantity > config.maxBatchSize) {
      revert MaxBatchSizeExceeded();
    }

    if ((args.curSupply + args.quantity) > config.maxSupply) {
      revert MaxSupplyExceeded();
    }

    if (i.tokenAddress != address(0)) {
      IERC20 erc20Token = IERC20(i.tokenAddress);
      if (erc20Token.allowance(msgSender, address(this)) < cost) {
        revert NotApprovedToTransfer();
      }

      if (erc20Token.balanceOf(msgSender) < cost) {
        revert Erc20BalanceTooLow();
      }

      if (msg.value != 0) {
        revert ExcessiveEthSent();
      }
    } else {
      if (msg.value < cost) {
        revert InsufficientEthSent();
      }
    }
  }

  function updateBalances(
    AdvancedInvite storage i,
    Config storage config,
    mapping(address => uint128) storage _ownerBalance,
    mapping(address => mapping(address => uint128)) storage _affiliateBalance,
    address affiliate,
    uint256 quantity,
    uint128 value
  ) public {
    address tokenAddress = i.tokenAddress;

    uint128 affiliateWad;
    if (affiliate != address(0)) {
      affiliateWad = (value * config.affiliateFee) / 10000;
      _affiliateBalance[affiliate][tokenAddress] += affiliateWad;
      emit Referral(affiliate, tokenAddress, affiliateWad, quantity);
    }

    uint128 balance = _ownerBalance[tokenAddress];
    uint128 ownerWad = value - affiliateWad;
    _ownerBalance[tokenAddress] = balance + ownerWad;

    if (tokenAddress != address(0)) {
      IERC20 erc20Token = IERC20(tokenAddress);
      bool success = erc20Token.transferFrom(_msgSender(), address(this), value);
      if (!success) {
        revert TransferFailed();
      }
    }
  }

  function withdrawTokensAffiliate(
    mapping(address => mapping(address => uint128)) storage _affiliateBalance,
    address[] calldata tokens
  ) public {
    address msgSender = _msgSender();

    for (uint256 i; i < tokens.length; i++) {
      address tokenAddress = tokens[i];
      uint128 wad = _affiliateBalance[msgSender][tokenAddress];
      _affiliateBalance[msgSender][tokenAddress] = 0;

      if (wad == 0) {
        revert BalanceEmpty();
      }

      if (tokenAddress == address(0)) {
        bool success = false;
        (success, ) = msgSender.call{ value: wad }("");
        if (!success) {
          revert TransferFailed();
        }
      } else {
        IERC20 erc20Token = IERC20(tokenAddress);
        bool success = erc20Token.transfer(msgSender, wad);
        if (!success) {
          revert TransferFailed();
        }
      }

      emit Withdrawal(msgSender, tokenAddress, wad);
    }
  }

  function withdrawTokens(
    PayoutConfig storage payoutConfig,
    mapping(address => uint128) storage _ownerBalance,
    address owner,
    address[] calldata tokens
  ) public {
    address msgSender = _msgSender();
    for (uint256 i; i < tokens.length; i++) {
      address tokenAddress = tokens[i];
      uint128 wad;

      if (
        msgSender == owner ||
        msgSender == PLATFORM ||
        msgSender == payoutConfig.partner ||
        msgSender == payoutConfig.superAffiliate ||
        msgSender == payoutConfig.ownerAltPayout
      ) {
        wad = _ownerBalance[tokenAddress];
        _ownerBalance[tokenAddress] = 0;
      } else {
        revert NotShareholder();
      }

      if (wad == 0) {
        revert BalanceEmpty();
      }

      if (payoutConfig.ownerAltPayout == address(0)) {
        address[] memory recipients = new address[](4);
        recipients[0] = owner;
        recipients[1] = PLATFORM;
        recipients[2] = payoutConfig.partner;
        recipients[3] = payoutConfig.superAffiliate;

        uint16[] memory splits = new uint16[](4);
        splits[0] = payoutConfig.ownerBps;
        splits[1] = payoutConfig.platformBps;
        splits[2] = payoutConfig.partnerBps;
        splits[3] = payoutConfig.superAffiliateBps;

        if (tokenAddress == address(0)) {
          ArchetypePayouts(PAYOUTS).updateBalances{ value: wad }(
            wad,
            tokenAddress,
            recipients,
            splits
          );
        } else {
          ArchetypePayouts(PAYOUTS).updateBalances(wad, tokenAddress, recipients, splits);
        }
      } else {
        uint256 ownerShare = (uint256(wad) * payoutConfig.ownerBps) / 10000;
        uint256 remainingShare = wad - ownerShare;

        if (tokenAddress == address(0)) {
          (bool success, ) = payable(payoutConfig.ownerAltPayout).call{ value: ownerShare }("");
          if (!success) revert TransferFailed();
        } else {
          IERC20(tokenAddress).transfer(payoutConfig.ownerAltPayout, ownerShare);
        }

        address[] memory recipients = new address[](3);
        recipients[0] = PLATFORM;
        recipients[1] = payoutConfig.partner;
        recipients[2] = payoutConfig.superAffiliate;

        uint16[] memory splits = new uint16[](3);
        uint16 remainingBps = 10000 - payoutConfig.ownerBps;
        splits[1] = uint16((uint256(payoutConfig.partnerBps) * 10000) / remainingBps);
        splits[2] = uint16((uint256(payoutConfig.superAffiliateBps) * 10000) / remainingBps);
        splits[0] = 10000 - splits[1] - splits[2];

        if (tokenAddress == address(0)) {
          ArchetypePayouts(PAYOUTS).updateBalances{ value: remainingShare }(
            remainingShare,
            tokenAddress,
            recipients,
            splits
          );
        } else {
          ArchetypePayouts(PAYOUTS).updateBalances(
            remainingShare,
            tokenAddress,
            recipients,
            splits
          );
        }
      }
      emit Withdrawal(msgSender, tokenAddress, wad);
    }
  }


  function validateAffiliate(
    address affiliate,
    bytes calldata signature,
    address affiliateSigner
  ) public view {
    bytes32 signedMessagehash = ECDSA.toEthSignedMessageHash(
      keccak256(abi.encodePacked(affiliate))
    );
    address signer = ECDSA.recover(signedMessagehash, signature);

    if (signer != affiliateSigner) {
      revert InvalidSignature();
    }
  }

  function verify(
    Auth calldata auth,
    address tokenAddress,
    address account
  ) public pure returns (bool) {
    // keys 0-255 and tokenAddress are public
    if (uint256(auth.key) <= 0xff || auth.key == keccak256(abi.encodePacked(tokenAddress))) {
      return true;
    }

    return MerkleProofLib.verify(auth.proof, auth.key, keccak256(abi.encodePacked(account)));
  }

  function _msgSender() internal view returns (address) {
    return msg.sender == BATCH ? tx.origin : msg.sender;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title DN420
/// @notice DN420 is a fully standard compliant, single-contract,
/// ERC20 and ERC1155 chimera implementation that mints
/// and burns NFTs based on an account's ERC20 token balance.
///
/// This contract has not yet been audited. USE AT YOUR OWN RISK!
///
/// @author vectorized.eth (@optimizoor)
/// @author Quit (@0xQuit)
/// @author Michael Amadi (@AmadiMichaels)
/// @author cygaar (@0xCygaar)
/// @author Thomas (@0xjustadev)
/// @author Harrison (@PopPunkOnChain)
///
/// @dev Note:
/// - On-transfer token ID burning scheme:
///     * DN420: Largest token ID up to owned checkpoint (inclusive) first.
///     * DN404: Most recently acquired token ID first.
/// - This implementation uses bitmap scans to find ERC1155 token IDs
///   to transfer / burn upon ERC20 transfers.
/// - For long-term gas efficiency, please ensure that the maximum
///   supply of NFTs is bounded and not too big.
///   10k is fine; it will cost less than 100k gas to bitmap scan 10k bits.
///   Otherwise, users can still always call `setOwnedCheckpoint` to unblock.
/// - A unit worth of ERC20 tokens equates to a deed to one NFT token.
///   The skip NFT status determines if this deed is automatically exercised.
///   An account can configure their skip NFT status.
///     * If `getSkipNFT(owner) == true`, ERC20 mints / transfers to `owner`
///       will NOT trigger NFT mints / transfers to `owner` (i.e. deeds are left unexercised).
///     * If `getSkipNFT(owner) == false`, ERC20 mints / transfers to `owner`
///       will trigger NFT mints / transfers to `owner`, until the NFT balance of `owner`
///       is equal to its ERC20 balance divided by the unit (rounded down).
/// - Invariant: `_balanceOfNFT(owner) <= balanceOf(owner) / _unit()`.
/// - The gas costs for automatic minting / transferring / burning of NFTs is O(n).
///   This can exceed the block gas limit.
///   Applications and users may need to break up large transfers into a few transactions.
/// - This implementation uses safe transfers for automatic NFT transfers,
///   as all transfers require the recipient check by the ERC1155 spec.
/// - The ERC20 token allowances and ERC1155 token / operator approvals are separate.
/// - For MEV safety, users should NOT have concurrently open orders for the ERC20 and ERC1155.
abstract contract DN420 {
    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                           EVENTS                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Emitted when `amount` tokens is transferred from `from` to `to`.
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @dev Emitted when `amount` tokens is approved by `owner` to be used by `spender`.
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @dev Emitted when `owner` sets their skipNFT flag to `status`.
    event SkipNFTSet(address indexed owner, bool status);

    /// @dev Emitted when `owner` sets their owned checkpoint to `id`.
    event OwnedCheckpointSet(address indexed owner, uint256 id);

    /// @dev Emitted when `amount` of token `id` is transferred
    /// from `from` to `to` by `operator`.
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    /// @dev Emitted when `amounts` of token `ids` are transferred
    /// from `from` to `to` by `operator`.
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    /// @dev Emitted when `owner` enables or disables `operator` to manage all of their tokens.
    event ApprovalForAll(address indexed owner, address indexed operator, bool isApproved);

    /// @dev Emitted when the Uniform Resource Identifier (URI) for token `id`
    /// is updated to `value`. This event is not used in the base contract.
    /// You may need to emit this event depending on your URI logic.
    ///
    /// See: https://eips.ethereum.org/EIPS/eip-1155#metadata
    event URI(string value, uint256 indexed id);

    /// @dev `keccak256(bytes("Transfer(address,address,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /// @dev `keccak256(bytes("Approval(address,address,uint256)"))`.
    uint256 private constant _APPROVAL_EVENT_SIGNATURE =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /// @dev `keccak256(bytes("SkipNFTSet(address,bool)"))`.
    uint256 private constant _SKIP_NFT_SET_EVENT_SIGNATURE =
        0xb5a1de456fff688115a4f75380060c23c8532d14ff85f687cc871456d669393;

    /// @dev `keccak256(bytes("TransferSingle(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_SINGLE_EVENT_SIGNATURE =
        0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62;

    /// @dev `keccak256(bytes("TransferBatch(address,address,address,uint256[],uint256[])"))`.
    uint256 private constant _TRANSFER_BATCH_EVENT_SIGNATURE =
        0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb;

    /// @dev `keccak256(bytes("ApprovalForAll(address,address,bool)"))`.
    uint256 private constant _APPROVAL_FOR_ALL_EVENT_SIGNATURE =
        0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                        CUSTOM ERRORS                       */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Thrown when attempting to double-initialize the contract.
    error DNAlreadyInitialized();

    /// @dev The contract has not been initialized.
    error DNNotInitialized();

    /// @dev Thrown when attempting to transfer or burn more tokens than sender's balance.
    error InsufficientBalance();

    /// @dev Thrown when a spender attempts to transfer tokens with an insufficient allowance.
    error InsufficientAllowance();

    /// @dev Thrown when minting an amount of tokens that would overflow the max tokens.
    error TotalSupplyOverflow();

    /// @dev The lengths of the input arrays are not the same.
    error ArrayLengthsMismatch();

    /// @dev The unit must be greater than zero and less than `2**96`.
    error InvalidUnit();

    /// @dev Thrown when attempting to transfer tokens to the zero address.
    error TransferToZeroAddress();

    /// @dev Thrown when transferring an NFT
    /// and the caller is not the owner or an approved operator.
    error NotOwnerNorApproved();

    /// @dev Thrown when transferring an NFT and the from address is not the current owner.
    error TransferFromIncorrectOwner();

    /// @dev The amount of ERC1155 NFT transferred per token must be 1.
    error InvalidNFTAmount();

    /// @dev The function selector is not recognized.
    error FnSelectorNotRecognized();

    /// @dev Cannot safely transfer to a contract that does not implement
    /// the ERC1155Receiver interface.
    error TransferToNonERC1155ReceiverImplementer();

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                         CONSTANTS                          */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev The flag to denote that the skip NFT flag is initialized.
    uint8 internal constant _ADDRESS_DATA_SKIP_NFT_INITIALIZED_FLAG = 1 << 0;

    /// @dev The flag to denote that the address should skip NFTs.
    uint8 internal constant _ADDRESS_DATA_SKIP_NFT_FLAG = 1 << 1;

    /// @dev The flag to denote that the address has overridden the default Permit2 allowance.
    uint8 internal constant _ADDRESS_DATA_OVERRIDE_PERMIT2_FLAG = 1 << 2;

    /// @dev The canonical Permit2 address.
    /// For signature-based allowance granting for single transaction ERC20 `transferFrom`.
    /// To enable, override `_givePermit2DefaultInfiniteAllowance()`.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                          STORAGE                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Struct containing an address's token data and settings.
    struct AddressData {
        // Auxiliary data.
        uint88 aux;
        // Flags for `initialized` and `skipNFT`.
        uint8 flags;
        // The index which to start scanning backwards for burnable / transferable token IDs.
        uint32 ownedCheckpoint;
        // The number of NFT tokens.
        uint32 ownedCount;
        // The token balance in wei.
        uint96 balance;
    }

    /// @dev A bitmap in storage.
    struct Bitmap {
        uint256 spacer;
    }

    /// @dev A struct to wrap a uint256 in storage.
    struct Uint256Ref {
        uint256 value;
    }

    /// @dev A mapping of an address pair to a Uint256Ref.
    struct AddressPairToUint256RefMap {
        uint256 spacer;
    }

    /// @dev Struct containing the base token contract storage.
    struct DN420Storage {
        // Next NFT ID to assign for a mint.
        uint32 nextTokenId;
        // This is greater than or equal to the largest NFT ID minted thus far.
        // A non-zero value is used to denote that the contract has been initialized.
        uint32 tokenIdUpTo;
        // Total supply of tokens.
        uint96 totalSupply;
        // Mapping of user operator approvals for NFTs.
        AddressPairToUint256RefMap operatorApprovals;
        // Bitmap of whether a NFT ID exists.
        Bitmap exists;
        // Mapping of user allowances for ERC20 spenders.
        AddressPairToUint256RefMap allowance;
        // Bitmap of NFT IDs owned by an address.
        mapping(address => Bitmap) owned;
        // Mapping of user account AddressData.
        mapping(address => AddressData) addressData;
    }

    /// @dev Returns a storage pointer for DN420Storage.
    function _getDN420Storage() internal pure virtual returns (DN420Storage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            // `uint72(bytes9(keccak256("DN420_STORAGE")))`.
            $.slot := 0xb6dffd38a260769cb2 // Truncate to 9 bytes to reduce bytecode size.
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                         INITIALIZER                        */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Initializes the DN420 contract with an
    /// `initialTokenSupply` and `initialTokenOwner`.
    ///
    /// Note: The `initialSupplyOwner` will have their skip NFT status set to true.
    function _initializeDN420(uint256 initialTokenSupply, address initialSupplyOwner)
        internal
        virtual
    {
        DN420Storage storage $ = _getDN420Storage();

        if ($.tokenIdUpTo != 0) revert DNAlreadyInitialized();
        unchecked {
            $.tokenIdUpTo = uint32((initialTokenSupply / _unit()) | 1);
            if (_unit() - 1 >= 2 ** 96 - 1) revert InvalidUnit();
        }
        $.nextTokenId = 1;

        if (initialTokenSupply != 0) {
            if (initialSupplyOwner == address(0)) revert TransferToZeroAddress();
            if (_totalSupplyOverflows(initialTokenSupply)) revert TotalSupplyOverflow();

            $.totalSupply = uint96(initialTokenSupply);

            AddressData storage initialOwnerAddressData = $.addressData[initialSupplyOwner];
            initialOwnerAddressData.balance = uint96(initialTokenSupply);

            /// @solidity memory-safe-assembly
            assembly {
                // Emit the ERC20 {Transfer} event.
                mstore(0x00, initialTokenSupply)
                log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, shl(96, initialSupplyOwner)))
            }

            _setSkipNFT(initialSupplyOwner, true);
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*               BASE UNIT FUNCTION TO OVERRIDE               */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Amount of token balance that is equal to one NFT.
    ///
    /// Note: The return value MUST be kept constant after `_initializeDN420` is called.
    function _unit() internal view virtual returns (uint256) {
        return 10 ** 18;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*               METADATA FUNCTIONS TO OVERRIDE               */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the name of the token.
    function name() public view virtual returns (string memory);

    /// @dev Returns the symbol of the token.
    function symbol() public view virtual returns (string memory);

    /// @dev Returns the URI for token `id`.
    ///
    /// You can either return the same templated URI for all token IDs,
    /// (e.g. "https://example.com/api/{id}.json"),
    /// or return a unique URI for each `id`.
    ///
    /// See: https://eips.ethereum.org/EIPS/eip-1155#metadata
    function uri(uint256 id) public view virtual returns (string memory);

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                       CONFIGURABLES                        */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns if direct NFT transfers should be used during ERC20 transfers
    /// whenever possible, instead of burning and re-minting.
    function _useDirectTransfersIfPossible() internal view virtual returns (bool) {
        return true;
    }

    /// @dev Hook that is called after a batch of NFT transfers.
    /// The lengths of `from`, `to`, and `ids` are guaranteed to be the same.
    function _afterNFTTransfers(address[] memory from, address[] memory to, uint256[] memory ids)
        internal
        virtual
    {}

    /// @dev Override this function to return true if `_afterNFTTransfers` is used.
    /// This is to help the compiler avoid producing dead bytecode.
    function _useAfterNFTTransfers() internal virtual returns (bool) {}

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                      ERC20 OPERATIONS                      */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the decimals places of the ERC20 token. Always 18.
    function decimals() public pure returns (uint8) {
        return 18;
    }

    /// @dev Returns the amount of ERC20 tokens in existence.
    function totalSupply() public view virtual returns (uint256) {
        return uint256(_getDN420Storage().totalSupply);
    }

    /// @dev Returns the amount of ERC20 tokens owned by `owner`.
    function balanceOf(address owner) public view virtual returns (uint256) {
        return _getDN420Storage().addressData[owner].balance;
    }

    /// @dev Returns the amount of ERC20 tokens that `spender` can spend on behalf of `owner`.
    function allowance(address owner, address spender) public view returns (uint256) {
        if (_givePermit2DefaultInfiniteAllowance() && spender == _PERMIT2) {
            uint8 flags = _getDN420Storage().addressData[owner].flags;
            if ((flags & _ADDRESS_DATA_OVERRIDE_PERMIT2_FLAG) == uint256(0)) {
                return type(uint256).max;
            }
        }
        return _ref(_getDN420Storage().allowance, owner, spender).value;
    }

    /// @dev Sets `amount` as the allowance of `spender` over the caller's ERC20 tokens.
    ///
    /// Emits an ERC20 {Approval} event.
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /// @dev Transfer `amount` ERC20 tokens from the caller to `to`.
    ///
    /// Will burn sender's ERC1155 NFTs if balance after transfer is less than
    /// the amount required to support the current NFT balance.
    ///
    /// Will mint ERC1155 NFTs to `to` if the recipient's new balance supports
    /// additional ERC1155 NFTs ***AND*** the `to` address's skipNFT flag is
    /// set to false.
    ///
    /// Requirements:
    /// - `from` must at least have `amount` ERC20 tokens.
    ///
    /// Emits an ERC1155 {TransferBatch} event for direct transfers (if any).
    /// Emits an ERC1155 {TransferBatch} event for mints (if any).
    /// Emits an ERC1155 {TransferBatch} event for burns (if any).
    /// Emits an ERC20 {Transfer} event.
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, to, amount, "");
        return true;
    }

    /// @dev Transfers `amount` ERC20 tokens from `from` to `to`.
    ///
    /// Note: Does not update the ERC20 allowance if it is the maximum uint256 value.
    ///
    /// Will burn sender ERC1155 NFTs if balance after transfer is less than
    /// the amount required to support the current ERC1155 NFT balance.
    ///
    /// Will mint ERC1155 NFTs to `to` if the recipient's new balance supports
    /// additional ERC1155 NFTs ***AND*** the `to` address's skipNFT flag is
    /// set to false.
    ///
    /// Requirements:
    /// - `from` must at least have `amount` ERC20 tokens.
    /// - The caller must have at least `amount` of ERC20 allowance to transfer the tokens of `from`.
    ///
    /// Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        Uint256Ref storage a = _ref(_getDN420Storage().allowance, from, msg.sender);

        uint256 allowed = _givePermit2DefaultInfiniteAllowance() && msg.sender == _PERMIT2
            && (_getDN420Storage().addressData[from].flags & _ADDRESS_DATA_OVERRIDE_PERMIT2_FLAG)
                == uint256(0) ? type(uint256).max : a.value;

        if (allowed != type(uint256).max) {
            if (amount > allowed) revert InsufficientAllowance();
            unchecked {
                a.value = allowed - amount;
            }
        }
        _transfer(from, to, amount, "");
        return true;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                          PERMIT2                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Whether Permit2 has infinite ERC20 allowances by default for all owners.
    /// For signature-based allowance granting for single transaction ERC20 `transferFrom`.
    /// To enable, override this function to return true.
    function _givePermit2DefaultInfiniteAllowance() internal view virtual returns (bool) {
        return false;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                  INTERNAL MINT FUNCTIONS                   */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Mints `amount` ERC20 tokens to `to`, increasing the total supply.
    ///
    /// Will mint ERC1155 NFTs to `to` if the recipient's new balance supports
    /// additional ERC1155 NFTs ***AND*** the `to` address's skipNFT flag is set to false.
    ///
    /// Emits an ERC1155 {TransferBatch} event for mints (if any).
    /// Emits an ERC20 {Transfer} event.
    function _mint(address to, uint256 amount, bytes memory data) internal virtual {
        if (to == address(0)) revert TransferToZeroAddress();

        DN420Storage storage $ = _getDN420Storage();
        if ($.tokenIdUpTo == uint256(0)) revert DNNotInitialized();
        AddressData storage toAddressData = $.addressData[to];

        _DNMintTemps memory t;
        unchecked {
            {
                uint256 toBalance = uint256(toAddressData.balance) + amount;
                toAddressData.balance = uint96(toBalance);
                t.toEnd = toBalance / _unit();
            }
            uint256 maxId;
            {
                uint256 totalSupply_ = uint256($.totalSupply) + amount;
                $.totalSupply = uint96(totalSupply_);
                uint256 overflows = _toUint(_totalSupplyOverflows(totalSupply_));
                if (overflows | _toUint(totalSupply_ < amount) != 0) revert TotalSupplyOverflow();
                maxId = totalSupply_ / _unit();
                $.tokenIdUpTo = uint32(_max($.tokenIdUpTo, maxId));
            }
            if (!getSkipNFT(to)) {
                t.mintIds = _idsMalloc(_zeroFloorSub(t.toEnd, toAddressData.ownedCount));
                if (t.mintIds.length != 0) {
                    Bitmap storage toOwned = $.owned[to];
                    uint256 ownedCheckpoint = toAddressData.ownedCheckpoint;
                    uint256 id = _wrapNFTId($.nextTokenId, maxId);
                    // Mint loop.
                    for (uint256 n = t.mintIds.length;;) {
                        while (_get($.exists, id)) {
                            id = _wrapNFTId(_findFirstUnset($.exists, id + 1, maxId), maxId);
                        }
                        _set($.exists, id, true);
                        _set(toOwned, id, true);
                        ownedCheckpoint = _max(ownedCheckpoint, id);
                        _idsAppend(t.mintIds, id);
                        id = _wrapNFTId(id + 1, maxId);
                        if (--n == uint256(0)) break;
                    }
                    toAddressData.ownedCheckpoint = uint32(ownedCheckpoint);
                    toAddressData.ownedCount = uint32(t.toEnd);
                    $.nextTokenId = uint32(id);
                    _batchTransferEmit(address(0), to, t.mintIds);
                }
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the ERC20 {Transfer} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, shl(96, to)))
        }
        if (_useAfterNFTTransfers()) {
            _afterNFTTransfers(
                _zeroAddresses(t.mintIds.length), _filled(t.mintIds.length, to), t.mintIds
            );
        }
        if (_hasCode(to)) _checkOnERC1155BatchReceived(address(0), to, t.mintIds, data);
    }

    /// @dev Mints `amount` tokens to `to`, increasing the total supply.
    /// This variant mints NFT tokens starting from ID `preTotalSupply / _unit() + 1`.
    /// The `nextTokenId` will not be changed.
    ///
    /// Will mint NFTs to `to` if the recipient's new balance supports
    /// additional NFTs ***AND*** the `to` address's skipNFT flag is set to false.
    ///
    /// Note:
    /// - May mint more NFTs than `amount / _unit()`.
    ///   The number of NFTs minted is what is needed to make `to`'s NFT balance whole.
    /// - Token IDs may wrap around `totalSupply / _unit()` back to 1.
    ///
    /// Emits an ERC1155 {TransferBatch} event for mints (if any).
    /// Emits an ERC20 {Transfer} event.
    function _mintNext(address to, uint256 amount, bytes memory data) internal virtual {
        if (to == address(0)) revert TransferToZeroAddress();

        DN420Storage storage $ = _getDN420Storage();
        if ($.tokenIdUpTo == uint256(0)) revert DNNotInitialized();
        AddressData storage toAddressData = $.addressData[to];

        _DNMintTemps memory t;
        unchecked {
            {
                uint256 toBalance = uint256(toAddressData.balance) + amount;
                toAddressData.balance = uint96(toBalance);
                t.toEnd = toBalance / _unit();
            }
            uint256 id;
            uint256 maxId;
            {
                uint256 preTotalSupply = uint256($.totalSupply);
                uint256 newTotalSupply = uint256(preTotalSupply) + amount;
                $.totalSupply = uint96(newTotalSupply);
                uint256 overflows = _toUint(_totalSupplyOverflows(newTotalSupply));
                if (overflows | _toUint(newTotalSupply < amount) != 0) revert TotalSupplyOverflow();
                maxId = newTotalSupply / _unit();
                id = _wrapNFTId(preTotalSupply / _unit() + 1, maxId);
                $.tokenIdUpTo = uint32(_max($.tokenIdUpTo, maxId));
            }
            if (!getSkipNFT(to)) {
                t.mintIds = _idsMalloc(_zeroFloorSub(t.toEnd, toAddressData.ownedCount));
                if (t.mintIds.length != 0) {
                    Bitmap storage toOwned = $.owned[to];
                    uint256 ownedCheckpoint = toAddressData.ownedCheckpoint;
                    // Mint loop.
                    for (uint256 n = t.mintIds.length;;) {
                        while (_get($.exists, id)) {
                            id = _wrapNFTId(_findFirstUnset($.exists, id + 1, maxId), maxId);
                        }
                        _set($.exists, id, true);
                        _set(toOwned, id, true);
                        ownedCheckpoint = _max(ownedCheckpoint, id);
                        _idsAppend(t.mintIds, id);
                        id = _wrapNFTId(id + 1, maxId);
                        if (--n == uint256(0)) break;
                    }
                    toAddressData.ownedCheckpoint = uint32(ownedCheckpoint);
                    toAddressData.ownedCount = uint32(t.toEnd);
                    _batchTransferEmit(address(0), to, t.mintIds);
                }
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the ERC20 {Transfer} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, shl(96, to)))
        }
        if (_useAfterNFTTransfers()) {
            _afterNFTTransfers(
                _zeroAddresses(t.mintIds.length), _filled(t.mintIds.length, to), t.mintIds
            );
        }
        if (_hasCode(to)) _checkOnERC1155BatchReceived(address(0), to, t.mintIds, data);
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                  INTERNAL BURN FUNCTIONS                   */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Burns `amount` ERC20 tokens from `from`, reducing the total supply.
    ///
    /// Will burn sender's ERC1155 NFTs if balance after transfer is less than
    /// the amount required to support the current ERC1155 NFT balance.
    ///
    /// Emits an ERC1155 {TransferBatch} event for burns (if any).
    /// Emits an ERC20 {Transfer} event.
    function _burn(address from, uint256 amount) internal virtual {
        DN420Storage storage $ = _getDN420Storage();
        if ($.tokenIdUpTo == uint256(0)) revert DNNotInitialized();
        AddressData storage fromAddressData = $.addressData[from];

        uint256[] memory ids;
        unchecked {
            uint256 fromBalance = fromAddressData.balance;
            if (amount > fromBalance) revert InsufficientBalance();

            fromAddressData.balance = uint96(fromBalance -= amount);
            $.totalSupply -= uint96(amount);

            Bitmap storage fromOwned = $.owned[from];
            uint256 fromIndex = fromAddressData.ownedCount;
            uint256 numNFTBurns = _zeroFloorSub(fromIndex, fromBalance / _unit());

            if (numNFTBurns != 0) {
                ids = _idsMalloc(numNFTBurns);
                fromAddressData.ownedCount = uint32(fromIndex - numNFTBurns);
                uint256 id = fromAddressData.ownedCheckpoint;
                // Burn loop.
                while (true) {
                    id = _findLastSet(fromOwned, id);
                    if (id == uint256(0)) id = _findLastSet(fromOwned, $.tokenIdUpTo);
                    _set(fromOwned, id, false);
                    _set($.exists, id, false);
                    _idsAppend(ids, id);
                    if (--numNFTBurns == uint256(0)) break;
                }
                fromAddressData.ownedCheckpoint = uint32(id);
                _batchTransferEmit(from, address(0), ids);
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the ERC20 {Transfer} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), 0)
        }
        if (_useAfterNFTTransfers()) {
            _afterNFTTransfers(_filled(ids.length, from), _zeroAddresses(ids.length), ids);
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                INTERNAL TRANSFER FUNCTIONS                 */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Moves `amount` of ERC20 tokens from `from` to `to`.
    ///
    /// Will burn sender ERC1155 NFTs if balance after transfer is less than
    /// the amount required to support the current ERC1155 NFT balance.
    ///
    /// Will mint ERC1155 NFTs to `to` if the recipient's new balance supports
    /// additional ERC1155 NFTs ***AND*** the `to` address's skipNFT flag is
    /// set to false.
    ///.
    /// Emits an ERC1155 {TransferBatch} event for direct transfers (if any).
    /// Emits an ERC1155 {TransferBatch} event for mints (if any).
    /// Emits an ERC1155 {TransferBatch} event for burns (if any).
    /// Emits an ERC20 {Transfer} event
    function _transfer(address from, address to, uint256 amount, bytes memory data)
        internal
        virtual
    {
        if (to == address(0)) revert TransferToZeroAddress();

        DN420Storage storage $ = _getDN420Storage();
        if ($.tokenIdUpTo == uint256(0)) revert DNNotInitialized();
        AddressData storage fromAddressData = $.addressData[from];
        AddressData storage toAddressData = $.addressData[to];

        _DNTransferTemps memory t;
        t.fromOwnedCount = fromAddressData.ownedCount;
        t.toOwnedCount = toAddressData.ownedCount;

        unchecked {
            uint256 toBalance;
            uint256 fromBalance = fromAddressData.balance;
            if (amount > fromBalance) revert InsufficientBalance();

            fromAddressData.balance = uint96(fromBalance -= amount);
            toAddressData.balance = uint96(toBalance = uint256(toAddressData.balance) + amount);

            t.numNFTBurns = _zeroFloorSub(t.fromOwnedCount, fromBalance / _unit());

            if (!getSkipNFT(to)) {
                if (from == to) t.toOwnedCount = t.fromOwnedCount - t.numNFTBurns;
                t.numNFTMints = _zeroFloorSub(toBalance / _unit(), t.toOwnedCount);
            }
        }

        unchecked {
            while (_useDirectTransfersIfPossible()) {
                uint256 n = _min(t.fromOwnedCount, _min(t.numNFTBurns, t.numNFTMints));
                if (n == uint256(0)) break;
                t.numNFTBurns -= n;
                t.numNFTMints -= n;
                if (from == to) {
                    t.toOwnedCount += n;
                    break;
                }
                t.directIds = _idsMalloc(n);
                Bitmap storage fromOwned = $.owned[from];
                Bitmap storage toOwned = $.owned[to];

                uint256 id = fromAddressData.ownedCheckpoint;
                fromAddressData.ownedCount = uint32(t.fromOwnedCount -= n);
                toAddressData.ownedCheckpoint = uint32(_max(toAddressData.ownedCheckpoint, id));
                toAddressData.ownedCount = uint32(t.toOwnedCount += n);
                // Direct transfer loop.
                while (true) {
                    id = _findLastSet(fromOwned, id);
                    if (id == uint256(0)) id = _findLastSet(fromOwned, $.tokenIdUpTo);
                    _set(fromOwned, id, false);
                    _set(toOwned, id, true);
                    _idsAppend(t.directIds, id);
                    if (--n == uint256(0)) break;
                }
                fromAddressData.ownedCheckpoint = uint32(id);
                _batchTransferEmit(from, to, t.directIds);
                break;
            }

            if (t.numNFTBurns != 0) {
                uint256 n = t.numNFTBurns;
                t.burnIds = _idsMalloc(n);
                Bitmap storage fromOwned = $.owned[from];
                fromAddressData.ownedCount = uint32(t.fromOwnedCount - n);
                uint256 id = fromAddressData.ownedCheckpoint;
                // Burn loop.
                while (true) {
                    id = _findLastSet(fromOwned, id);
                    if (id == uint256(0)) id = _findLastSet(fromOwned, $.tokenIdUpTo);
                    _set(fromOwned, id, false);
                    _set($.exists, id, false);
                    _idsAppend(t.burnIds, id);
                    if (--n == uint256(0)) break;
                }
                fromAddressData.ownedCheckpoint = uint32(id);
                _batchTransferEmit(from, address(0), t.burnIds);
            }

            if (t.numNFTMints != 0) {
                uint256 n = t.numNFTMints;
                t.mintIds = _idsMalloc(n);
                Bitmap storage toOwned = $.owned[to];
                toAddressData.ownedCount = uint32(t.toOwnedCount + n);
                uint256 maxId = $.totalSupply / _unit();
                uint256 id = _wrapNFTId($.nextTokenId, maxId);
                uint256 ownedCheckpoint = toAddressData.ownedCheckpoint;
                // Mint loop.
                while (true) {
                    while (_get($.exists, id)) {
                        id = _wrapNFTId(_findFirstUnset($.exists, id + 1, maxId), maxId);
                    }
                    _set($.exists, id, true);
                    _set(toOwned, id, true);
                    ownedCheckpoint = _max(ownedCheckpoint, id);
                    _idsAppend(t.mintIds, id);
                    id = _wrapNFTId(id + 1, maxId);
                    if (--n == uint256(0)) break;
                }
                toAddressData.ownedCheckpoint = uint32(ownedCheckpoint);
                $.nextTokenId = uint32(id);
                _batchTransferEmit(address(0), to, t.mintIds);
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the ERC20 {Transfer} event.
            mstore(0x00, amount)
            // forgefmt: disable-next-item
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), shr(96, shl(96, to)))
        }
        if (_useAfterNFTTransfers()) {
            uint256[] memory ids = t.directIds;
            unchecked {
                _afterNFTTransfers(
                    _concat(
                        _filled(ids.length + t.numNFTBurns, from), _zeroAddresses(t.numNFTMints)
                    ),
                    _concat(
                        _concat(_filled(ids.length, to), _zeroAddresses(t.numNFTBurns)),
                        _filled(t.numNFTMints, to)
                    ),
                    _concat(_concat(ids, t.burnIds), t.mintIds)
                );
            }
        }
        if (_hasCode(to)) {
            _checkOnERC1155BatchReceived(from, to, t.directIds, data);
            _checkOnERC1155BatchReceived(address(0), to, t.mintIds, data);
        }
    }

    /// @dev Transfers ERC1155 `id` from `from` to `to`.
    ///
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - `from` must have `id`.
    /// - If `by` is not the zero address, it must be either `from`,
    ///   or approved to manage the ERC1155 tokens of `from`.
    /// - If `to` refers to a smart contract, it must implement
    ///   {ERC1155-onERC1155Reveived}, which is called upon a batch transfer.
    ///
    /// Emits an ERC1155 {TransferSingle} event.
    /// Emits an ERC20 {Transfer} event.
    function _safeTransferNFT(address by, address from, address to, uint256 id, bytes memory data)
        internal
        virtual
    {
        if (to == address(0)) revert TransferToZeroAddress();

        DN420Storage storage $ = _getDN420Storage();
        if ($.tokenIdUpTo == uint256(0)) revert DNNotInitialized();

        if (_toUint(by == address(0)) | _toUint(by == from) == uint256(0)) {
            if (!isApprovedForAll(from, by)) revert NotOwnerNorApproved();
        }

        Bitmap storage fromOwned = $.owned[from];
        if (!_owns(fromOwned, id)) revert TransferFromIncorrectOwner();
        _set(fromOwned, id, false);
        _set($.owned[to], id, true);

        uint256 unit = _unit();
        AddressData storage fromAddressData = $.addressData[from];
        AddressData storage toAddressData = $.addressData[to];
        /// @solidity memory-safe-assembly
        assembly {
            let diff := shl(128, or(shl(32, unit), 1))
            sstore(fromAddressData.slot, sub(sload(fromAddressData.slot), diff))
            let toPacked := sload(toAddressData.slot)
            let toCheckpoint := and(0xffffffff, shr(96, toPacked))
            // forgefmt: disable-next-item
            sstore(toAddressData.slot, add(diff,
                xor(toPacked, shl(96, mul(gt(id, toCheckpoint), xor(id, toCheckpoint))))))
        }
        /// @solidity memory-safe-assembly
        assembly {
            from := shr(96, shl(96, from))
            to := shr(96, shl(96, to))
            // Emit the ERC1155 {TransferSingle} event.
            mstore(0x00, id)
            mstore(0x20, 1)
            log4(0x00, 0x40, _TRANSFER_SINGLE_EVENT_SIGNATURE, caller(), from, to)
            // Emit the ERC20 {Transfer} event.
            mstore(0x00, unit)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, from, to)
        }
        if (_useAfterNFTTransfers()) {
            _afterNFTTransfers(_filled(1, from), _filled(1, to), _filled(1, id));
        }
        if (_hasCode(to)) _checkOnERC1155Received(from, to, id, data);
    }

    /// @dev Transfers `id` from `from` to `to`.
    ///
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - `from` must have `ids`.
    /// - If `by` is not the zero address, it must be either `from`,
    ///   or approved to manage the ERC1155 tokens of `from`.
    /// - If `to` refers to a smart contract, it must implement
    ///   {ERC1155-onERC1155Reveived}, which is called upon a batch transfer.
    ///
    /// Emits an ERC1155 {TransferBatch} event.
    /// Emits an ERC20 {Transfer} event.
    function _safeBatchTransferNFTs(
        address by,
        address from,
        address to,
        uint256[] memory ids,
        bytes memory data
    ) internal virtual {
        if (to == address(0)) revert TransferToZeroAddress();

        DN420Storage storage $ = _getDN420Storage();
        if ($.tokenIdUpTo == uint256(0)) revert DNNotInitialized();

        if (_toUint(by == address(0)) | _toUint(by == from) == uint256(0)) {
            if (!isApprovedForAll(from, by)) revert NotOwnerNorApproved();
        }

        uint256 amount;
        uint256 upTo;
        AddressData storage fromAddressData = $.addressData[from];
        AddressData storage toAddressData = $.addressData[to];
        unchecked {
            uint256 n = ids.length;
            amount = n * _unit();
            Bitmap storage fromOwned = $.owned[from];
            Bitmap storage toOwned = $.owned[to];
            while (n != 0) {
                uint256 id = _get(ids, --n);
                if (!_owns(fromOwned, id)) revert TransferFromIncorrectOwner();
                _set(fromOwned, id, false);
                _set(toOwned, id, true);
                upTo = _max(upTo, id);
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            let diff := shl(128, or(shl(32, amount), mload(ids)))
            sstore(fromAddressData.slot, sub(sload(fromAddressData.slot), diff))
            let toPacked := sload(toAddressData.slot)
            let toCheckpoint := and(0xffffffff, shr(96, toPacked))
            // forgefmt: disable-next-item
            sstore(toAddressData.slot, add(diff,
                xor(toPacked, shl(96, mul(gt(upTo, toCheckpoint), xor(upTo, toCheckpoint))))))
        }
        _batchTransferEmit(from, to, ids);
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the ERC20 {Transfer} event.
            mstore(0x00, amount)
            // forgefmt: disable-next-item
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), shr(96, shl(96, to)))
        }
        if (_useAfterNFTTransfers()) {
            _afterNFTTransfers(_filled(ids.length, from), _filled(ids.length, to), ids);
        }
        if (_hasCode(to)) _checkOnERC1155BatchReceived(from, to, ids, data);
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                 INTERNAL APPROVE FUNCTIONS                 */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Sets `amount` as the allowance of `spender` over the tokens of `owner`.
    ///
    /// Emits a {Approval} event.
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        if (_givePermit2DefaultInfiniteAllowance() && spender == _PERMIT2) {
            _getDN420Storage().addressData[owner].flags |= _ADDRESS_DATA_OVERRIDE_PERMIT2_FLAG;
        }
        _ref(_getDN420Storage().allowance, owner, spender).value = amount;
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the {Approval} event.
            mstore(0x00, amount)
            // forgefmt: disable-next-item
            log3(0x00, 0x20, _APPROVAL_EVENT_SIGNATURE, shr(96, shl(96, owner)), shr(96, shl(96, spender)))
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                 DATA HITCHHIKING FUNCTIONS                 */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the auxiliary data for `owner`.
    /// Minting, transferring, burning the tokens of `owner` will not change the auxiliary data.
    /// Auxiliary data can be set for any address, even if it does not have any tokens.
    function _getAux(address owner) internal view virtual returns (uint88) {
        return _getDN420Storage().addressData[owner].aux;
    }

    /// @dev Set the auxiliary data for `owner` to `value`.
    /// Minting, transferring, burning the tokens of `owner` will not change the auxiliary data.
    /// Auxiliary data can be set for any address, even if it does not have any tokens.
    function _setAux(address owner, uint88 value) internal virtual {
        _getDN420Storage().addressData[owner].aux = value;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                     SKIP NFT FUNCTIONS                     */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns true if minting and transferring ERC20s to `owner` will skip minting NFTs.
    /// Returns false otherwise.
    function getSkipNFT(address owner) public view virtual returns (bool result) {
        uint8 flags = _getDN420Storage().addressData[owner].flags;
        /// @solidity memory-safe-assembly
        assembly {
            result := iszero(iszero(and(flags, _ADDRESS_DATA_SKIP_NFT_FLAG)))
            if iszero(and(flags, _ADDRESS_DATA_SKIP_NFT_INITIALIZED_FLAG)) {
                result := iszero(iszero(extcodesize(owner)))
            }
        }
    }

    /// @dev Sets the caller's skipNFT flag to `skipNFT`. Returns true.
    ///
    /// Emits a {SkipNFTSet} event.
    function setSkipNFT(bool skipNFT) public virtual returns (bool) {
        _setSkipNFT(msg.sender, skipNFT);
        return true;
    }

    /// @dev Internal function to set account `owner` skipNFT flag to `state`
    ///
    /// Initializes account `owner` AddressData if it is not currently initialized.
    ///
    /// Emits a {SkipNFTSet} event.
    function _setSkipNFT(address owner, bool state) internal virtual {
        AddressData storage d = _getDN420Storage().addressData[owner];
        uint8 flags = d.flags;
        /// @solidity memory-safe-assembly
        assembly {
            let s := xor(iszero(and(flags, _ADDRESS_DATA_SKIP_NFT_FLAG)), iszero(state))
            flags := xor(mul(_ADDRESS_DATA_SKIP_NFT_FLAG, s), flags)
            flags := or(_ADDRESS_DATA_SKIP_NFT_INITIALIZED_FLAG, flags)
            mstore(0x00, iszero(iszero(state)))
            log2(0x00, 0x20, _SKIP_NFT_SET_EVENT_SIGNATURE, shr(96, shl(96, owner)))
        }
        d.flags = flags;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                 OWNED CHECKPOINT FUNCTIONS                 */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the owned checkpoint of `owner`.
    function getOwnedCheckpoint(address owner) public view virtual returns (uint256) {
        return _getDN420Storage().addressData[owner].ownedCheckpoint;
    }

    /// @dev Just in case the collection gets too large and the caller needs
    /// to set their owned checkpoint manually to skip large bitmap scans
    /// for automatic ERC1155 NFT burns upon ERC20 transfers.
    function setOwnedCheckpoint(uint256 id) public virtual {
        _setOwnedCheckpoint(msg.sender, id);
    }

    /// @dev Sets the owned checkpoint of `owner` to `id`.
    /// `id` will be clamped to `[1..tokenIdUpTo]`.
    function _setOwnedCheckpoint(address owner, uint256 id) internal virtual {
        DN420Storage storage $ = _getDN420Storage();
        id = _min(_max(1, id), $.tokenIdUpTo);
        $.addressData[owner].ownedCheckpoint = uint32(id);
        emit OwnedCheckpointSet(owner, id);
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                     ERC1155 OPERATIONS                     */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns if `owner` owns ERC1155 `id`.
    function owns(address owner, uint256 id) public view virtual returns (bool) {
        return _owns(_getDN420Storage().owned[owner], id);
    }

    /// @dev Returns if the ERC1155 `id` is set in `owned`.
    function _owns(Bitmap storage owned, uint256 id) internal view virtual returns (bool) {
        return _get(owned, _restrictNFTId(id));
    }

    /// @dev Returns whether `operator` is approved to manage the ERC1155 tokens of `owner`.
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _ref(_getDN420Storage().operatorApprovals, owner, operator).value != 0;
    }

    /// @dev Sets whether `operator` is approved to manage the ERC1155 tokens of the caller.
    ///
    /// Emits a {ApprovalForAll} event.
    function setApprovalForAll(address operator, bool isApproved) public virtual {
        _setApprovalForAll(msg.sender, operator, isApproved);
    }

    /// @dev Sets whether `operator` is approved to manage the ERC1155 tokens of the caller.
    ///
    /// Emits a {ApprovalForAll} event.
    function _setApprovalForAll(address owner, address operator, bool isApproved)
        internal
        virtual
    {
        _ref(_getDN420Storage().operatorApprovals, owner, operator).value = _toUint(isApproved);
        /// @solidity memory-safe-assembly
        assembly {
            // Emit the {ApprovalForAll} event.
            mstore(0x00, isApproved)
            // forgefmt: disable-next-item
            log3(0x00, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE,
                shr(96, shl(96, owner)), shr(96, shl(96, operator)))
        }
    }

    /// @dev Transfers the ERC1155 NFT at `id` from `from` to `to`.
    function safeTransferNFT(address from, address to, uint256 id, bytes memory data)
        public
        virtual
    {
        _safeTransferNFT(msg.sender, from, to, id, data);
    }

    /// @dev Transfers the ERC1155 NFTs at `ids` from `from` to `to`.
    function safeBatchTransferNFTs(
        address from,
        address to,
        uint256[] memory ids,
        bytes memory data
    ) public virtual {
        _safeBatchTransferNFTs(msg.sender, from, to, ids, data);
    }

    /// @dev Returns true if this contract implements the interface defined by `interfaceId`.
    /// See: https://eips.ethereum.org/EIPS/eip-165
    /// This function call must use less than 30000 gas.
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC1155: 0xd9b67a26, ERC1155MetadataURI: 0x0e89341c.
            result := or(or(eq(s, 0x01ffc9a7), eq(s, 0xd9b67a26)), eq(s, 0x0e89341c))
        }
    }

    /// @dev Returns `owner`'s ERC1155 NFT balance.
    function _balanceOfNFT(address owner) internal view virtual returns (uint256) {
        return _getDN420Storage().addressData[owner].ownedCount;
    }

    /// @dev Returns if the ERC1155 token `id` exists.
    function _exists(uint256 id) internal view virtual returns (bool) {
        return _get(_getDN420Storage().exists, _restrictNFTId(id));
    }

    /// @dev Returns the ERC1155 NFT IDs of `owner` in range `[lower, upper)`.
    /// Optimized for smaller bytecode size, as this function is intended for off-chain calling.
    function _findOwnedIds(address owner, uint256 lower, uint256 upper)
        internal
        view
        virtual
        returns (uint256[] memory ids)
    {
        unchecked {
            DN420Storage storage $ = _getDN420Storage();
            Bitmap storage owned = $.owned[owner];
            upper = _min(uint256($.tokenIdUpTo) + 1, upper);
            /// @solidity memory-safe-assembly
            assembly {
                ids := mload(0x40)
                let n := 0
                let s := shl(96, owned.slot)
                for { let id := lower } lt(id, upper) { id := add(1, id) } {
                    if and(1, shr(and(0xff, id), sload(add(s, shr(8, id))))) {
                        mstore(add(add(ids, 0x20), shl(5, n)), id)
                        n := add(1, n)
                    }
                }
                mstore(ids, n)
                mstore(0x40, add(shl(5, n), add(0x20, ids)))
            }
        }
    }

    /// @dev Fallback modifier for the regular ERC1155 functions and other functions.
    modifier dn420Fallback() virtual {
        uint256 fnSelector = _calldataload(0x00) >> 224;

        // We hide the regular ERC1155 functions that has variable amounts
        // in the fallback for ABI aesthetic purposes.

        // `safeTransferFrom(address,address,uint256,uint256,bytes)`.
        if (fnSelector == 0xf242432a) {
            if (_calldataload(0x64) != 1) revert InvalidNFTAmount();
            _safeTransferNFT(
                msg.sender, // `by`.
                address(uint160(_calldataload(0x04))), // `from`.
                address(uint160(_calldataload(0x24))), // `to`.
                _calldataload(0x44), // `id`.
                _calldataBytes(0x84) // `data`.
            );
            _return(1);
        }
        // `safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)`.
        if (fnSelector == 0x2eb2c2d6) {
            uint256[] memory ids = _calldataUint256Array(0x44);
            unchecked {
                uint256[] memory amounts = _calldataUint256Array(0x64);
                uint256 n = ids.length;
                if (n != amounts.length) revert ArrayLengthsMismatch();
                while (n-- != 0) if (_get(amounts, n) != 1) revert InvalidNFTAmount();
            }
            _safeBatchTransferNFTs(
                msg.sender,
                address(uint160(_calldataload(0x04))), // `from`.
                address(uint160(_calldataload(0x24))), // `to`.
                ids,
                _calldataBytes(0x84) // `data.
            );
            _return(1);
        }
        // `balanceOfBatch(address[],uint256[])`.
        if (fnSelector == 0x4e1273f4) {
            uint256[] memory owners = _calldataUint256Array(0x04);
            uint256[] memory ids = _calldataUint256Array(0x24);
            unchecked {
                uint256 n = ids.length;
                if (owners.length != n) revert ArrayLengthsMismatch();
                uint256[] memory result = _idsMalloc(n);
                while (n-- != 0) {
                    address owner = address(uint160(_get(owners, n)));
                    _set(result, n, _toUint(owns(owner, _get(ids, n))));
                }
                /// @solidity memory-safe-assembly
                assembly {
                    mstore(sub(result, 0x20), 0x20)
                    return(sub(result, 0x20), add(0x40, shl(5, mload(result))))
                }
            }
        }
        // `balanceOf(address,uint256)`.
        if (fnSelector == 0x00fdd58e) {
            bool result = owns(
                address(uint160(_calldataload(0x04))), // `owner`.
                _calldataload(0x24) // `id`.
            );
            _return(_toUint(result));
        }
        // `implementsDN420()`.
        if (fnSelector == 0x0e0b0984) {
            _return(1);
        }
        _;
    }

    /// @dev Fallback function for regular ERC1155 functions and other functions.
    /// Override this if you need to implement your custom
    /// fallback with utilities like Solady's `LibZip.cdFallback()`.
    /// And always remember to always wrap the fallback with `dn420Fallback`.
    fallback() external payable virtual dn420Fallback {
        revert FnSelectorNotRecognized(); // Not mandatory. Just for quality of life.
    }

    /// @dev This is to silence the compiler warning.
    /// Override and remove the revert if you want your contract to receive ETH via receive.
    receive() external payable virtual {
        if (msg.value != 0) revert();
    }

    /// @dev Perform a call to invoke {IERC1155Receiver-onERC1155Received} on `to`.
    /// Reverts if the target does not support the function correctly.
    function _checkOnERC1155Received(address from, address to, uint256 id, bytes memory data)
        private
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the calldata.
            let m := mload(0x40)
            // `onERC1155Received(address,address,uint256,uint256,bytes)`.
            mstore(m, 0xf23a6e61)
            mstore(add(m, 0x20), caller())
            mstore(add(m, 0x40), shr(96, shl(96, from)))
            mstore(add(m, 0x60), id)
            mstore(add(m, 0x80), 1)
            mstore(add(m, 0xa0), 0xa0)
            let n := mload(data)
            mstore(add(m, 0xc0), n)
            if n { pop(staticcall(gas(), 4, add(data, 0x20), n, add(m, 0xe0), n)) }
            // Revert if the call reverts.
            if iszero(call(gas(), to, 0, add(m, 0x1c), add(0xc4, n), m, 0x20)) {
                if returndatasize() {
                    // Bubble up the revert if the call reverts.
                    returndatacopy(m, 0x00, returndatasize())
                    revert(m, returndatasize())
                }
            }
            // Load the returndata and compare it with the function selector.
            if iszero(eq(mload(m), shl(224, 0xf23a6e61))) {
                mstore(0x00, 0x9c05499b) // `TransferToNonERC1155ReceiverImplementer()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Perform a call to invoke {IERC1155Receiver-onERC1155BatchReceived} on `to`.
    /// Reverts if the target does not support the function correctly.
    function _checkOnERC1155BatchReceived(
        address from,
        address to,
        uint256[] memory ids,
        bytes memory data
    ) private {
        if (ids.length == uint256(0)) return;
        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the calldata.
            let m := mload(0x40)
            // `onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)`.
            mstore(m, 0xbc197c81)
            mstore(add(m, 0x20), caller())
            mstore(add(m, 0x40), shr(96, shl(96, from)))
            // Copy the `ids`.
            mstore(add(m, 0x60), 0xa0)
            let o := add(m, 0xc0)
            {
                let n := add(0x20, shl(5, mload(ids)))
                pop(staticcall(gas(), 4, ids, n, o, n))
            }
            // Copy the `amounts`.
            mstore(add(m, 0x80), add(0xa0, returndatasize()))
            mstore(add(m, 0xa0), add(returndatasize(), add(0xa0, returndatasize())))
            o := add(o, returndatasize())
            mstore(o, mload(ids))
            let end := add(o, returndatasize())
            for { o := add(o, 0x20) } iszero(eq(o, end)) { o := add(0x20, o) } { mstore(o, 1) }
            // Copy the `data`.
            {
                let n := add(0x20, mload(data))
                pop(staticcall(gas(), 4, data, n, end, n))
            }
            // Revert if the call reverts.
            // forgefmt: disable-next-item
            if iszero(call(gas(), to, 0,
                add(m, 0x1c), sub(add(end, returndatasize()), add(m, 0x1c)), m, 0x20)) {
                if returndatasize() {
                    // Bubble up the revert if the call reverts.
                    returndatacopy(m, 0x00, returndatasize())
                    revert(m, returndatasize())
                }
            }
            // Load the returndata and compare it with the function selector.
            if iszero(eq(mload(m), shl(224, 0xbc197c81))) {
                mstore(0x00, 0x9c05499b) // `TransferToNonERC1155ReceiverImplementer()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                 INTERNAL / PRIVATE HELPERS                 */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the boolean value of the bit at `index` in `bitmap`.
    function _get(Bitmap storage bitmap, uint256 index) internal view returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let s := add(shl(96, bitmap.slot), shr(8, index)) // Storage slot.
            result := and(1, shr(and(0xff, index), sload(s)))
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to `value`.
    function _set(Bitmap storage bitmap, uint256 index, bool value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let s := add(shl(96, bitmap.slot), shr(8, index)) // Storage slot.
            let o := and(0xff, index) // Storage slot offset (bits).
            sstore(s, or(and(sload(s), not(shl(o, 1))), shl(o, iszero(iszero(value)))))
        }
    }

    /// @dev Returns the index of the least significant unset bit in `[begin..upTo]`.
    /// If no unset bit is found, returns `type(uint256).max`.
    function _findFirstUnset(Bitmap storage bitmap, uint256 begin, uint256 upTo)
        internal
        view
        returns (uint256 unsetBitIndex)
    {
        /// @solidity memory-safe-assembly
        assembly {
            unsetBitIndex := not(0) // Initialize to `type(uint256).max`.
            let s := shl(96, bitmap.slot) // Storage offset of the bitmap.
            let bucket := add(s, shr(8, begin))
            let negBits := shl(and(0xff, begin), shr(and(0xff, begin), not(sload(bucket))))
            if iszero(negBits) {
                let lastBucket := add(s, shr(8, upTo))
                for {} 1 {} {
                    bucket := add(bucket, 1)
                    negBits := not(sload(bucket))
                    if or(negBits, gt(bucket, lastBucket)) { break }
                }
                if gt(bucket, lastBucket) {
                    negBits := shr(and(0xff, not(upTo)), shl(and(0xff, not(upTo)), negBits))
                }
            }
            if negBits {
                // Find-first-set routine.
                // From: https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol
                let b := and(negBits, add(not(negBits), 1)) // Isolate the least significant bit.
                // For the upper 3 bits of the result, use a De Bruijn-like lookup.
                // Credit to adhusson: https://blog.adhusson.com/cheap-find-first-set-evm/
                // forgefmt: disable-next-item
                let r := shl(5, shr(252, shl(shl(2, shr(250, mul(b,
                    0x2aaaaaaaba69a69a6db6db6db2cb2cb2ce739ce73def7bdeffffffff))),
                    0x1412563212c14164235266736f7425221143267a45243675267677)))
                // For the lower 5 bits of the result, use a De Bruijn lookup.
                // forgefmt: disable-next-item
                r := or(r, byte(and(div(0xd76453e0, shr(r, b)), 0x1f),
                    0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
                r := or(shl(8, sub(bucket, s)), r)
                unsetBitIndex := or(r, sub(0, or(gt(r, upTo), lt(r, begin))))
            }
        }
    }

    /// @dev Returns the index of the most significant set bit in `[0..upTo]`.
    /// If no set bit is found, returns zero.
    function _findLastSet(Bitmap storage bitmap, uint256 upTo)
        internal
        view
        returns (uint256 setBitIndex)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let s := shl(96, bitmap.slot) // Storage offset of the bitmap.
            let bucket := add(s, shr(8, upTo))
            let bits := shr(and(0xff, not(upTo)), shl(and(0xff, not(upTo)), sload(bucket)))
            if iszero(or(bits, eq(bucket, s))) {
                for {} 1 {} {
                    bucket := sub(bucket, 1)
                    mstore(0x00, bucket)
                    bits := sload(bucket)
                    if or(bits, eq(bucket, s)) { break }
                }
            }
            if bits {
                // Find-last-set routine.
                let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, bits))
                r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, bits))))
                r := or(r, shl(5, lt(0xffffffff, shr(r, bits))))
                r := or(r, shl(4, lt(0xffff, shr(r, bits))))
                r := or(r, shl(3, lt(0xff, shr(r, bits))))
                // forgefmt: disable-next-item
                r := or(r, byte(and(0x1f, shr(shr(r, bits), 0x8421084210842108cc6318c6db6d54be)),
                    0x0706060506020504060203020504030106050205030304010505030400000000))
                r := or(shl(8, sub(bucket, s)), r)
                setBitIndex := mul(r, iszero(gt(r, upTo)))
            }
        }
    }

    /// @dev Returns a storage reference to the value at (`a0`, `a1`) in `map`.
    function _ref(AddressPairToUint256RefMap storage map, address a0, address a1)
        internal
        pure
        returns (Uint256Ref storage ref)
    {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x28, a1)
            mstore(0x14, a0)
            mstore(0x00, map.slot)
            ref.slot := keccak256(0x00, 0x48)
            // Clear the part of the free memory pointer that was overwritten.
            mstore(0x28, 0x00)
        }
    }

    /// @dev Wraps the NFT ID.
    function _wrapNFTId(uint256 id, uint256 maxId) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := or(mul(iszero(gt(id, maxId)), id), gt(id, maxId))
        }
    }

    /// @dev Returns `id > type(uint32).max ? 0 : id`.
    function _restrictNFTId(uint256 id) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mul(id, lt(id, 0x100000000))
        }
    }

    /// @dev Returns whether `amount` is a valid `totalSupply`.
    function _totalSupplyOverflows(uint256 amount) internal view returns (bool result) {
        uint256 unit = _unit();
        /// @solidity memory-safe-assembly
        assembly {
            result := iszero(iszero(or(shr(96, amount), lt(0xfffffffe, div(amount, unit)))))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function _zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Returns `x < y ? x : y`.
    function _min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns `x > y ? x : y`.
    function _max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns `b ? 1 : 0`.
    function _toUint(bool b) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := iszero(iszero(b))
        }
    }

    /// @dev Creates an array with length `n` that is suitable for `_idsAppend`.
    function _idsMalloc(uint256 n) private pure returns (uint256[] memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := add(0x20, mload(0x40))
            let offset := add(result, 0x20)
            mstore(sub(result, 0x20), offset)
            mstore(result, n)
            mstore(0x40, add(offset, shl(5, n)))
        }
    }

    /// @dev Appends `id` to `a`. `a` must be created via `_idsMalloc`.
    function _idsAppend(uint256[] memory a, uint256 id) private pure {
        /// @solidity memory-safe-assembly
        assembly {
            let offset := mload(sub(a, 0x20))
            mstore(offset, id)
            mstore(sub(a, 0x20), add(offset, 0x20))
        }
    }

    /// @dev Emits the ERC1155 {TransferBatch} event with `from`, `to`, and `ids`.
    function _batchTransferEmit(address from, address to, uint256[] memory ids) private {
        if (ids.length == uint256(0)) return;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x40)
            let o := add(m, 0x40)
            // We have to copy the `ids`, as it might not be from `_idsMalloc`.
            // See: `_safeBatchTransferNFTs`.
            {
                let n := add(0x20, shl(5, mload(ids)))
                pop(staticcall(gas(), 4, ids, n, o, n))
            }
            mstore(add(m, 0x20), add(0x40, returndatasize()))
            o := add(o, returndatasize())
            // Store the length of `amounts`.
            mstore(o, mload(ids))
            let end := add(o, returndatasize())
            for { o := add(o, 0x20) } iszero(eq(o, end)) { o := add(0x20, o) } { mstore(o, 1) }
            // Emit a {TransferBatch} event.
            // forgefmt: disable-next-item
            log4(m, sub(o, m), _TRANSFER_BATCH_EVENT_SIGNATURE, caller(),
                shr(96, shl(96, from)), shr(96, shl(96, to)))
        }
    }

    /// @dev Returns an array of zero addresses.
    function _zeroAddresses(uint256 n) private pure returns (address[] memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            mstore(0x40, add(add(result, 0x20), shl(5, n)))
            mstore(result, n)
            codecopy(add(result, 0x20), codesize(), shl(5, n))
        }
    }

    /// @dev Returns an array each set to `value`.
    function _filled(uint256 n, uint256 value) private pure returns (uint256[] memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(result, 0x20)
            let end := add(o, shl(5, n))
            mstore(0x40, end)
            mstore(result, n)
            for {} iszero(eq(o, end)) { o := add(o, 0x20) } { mstore(o, value) }
        }
    }

    /// @dev Returns an array each set to `value`.
    function _filled(uint256 n, address value) private pure returns (address[] memory result) {
        result = _toAddresses(_filled(n, uint160(value)));
    }

    /// @dev Concatenates the arrays.
    function _concat(uint256[] memory a, uint256[] memory b)
        private
        view
        returns (uint256[] memory result)
    {
        uint256 aN = a.length;
        uint256 bN = b.length;
        if (aN == uint256(0)) return b;
        if (bN == uint256(0)) return a;
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(aN, bN)
            if n {
                result := mload(0x40)
                mstore(result, n)
                let o := add(result, 0x20)
                mstore(0x40, add(o, shl(5, n)))
                let aL := shl(5, aN)
                pop(staticcall(gas(), 4, add(a, 0x20), aL, o, aL))
                pop(staticcall(gas(), 4, add(b, 0x20), shl(5, bN), add(o, aL), shl(5, bN)))
            }
        }
    }

    /// @dev Concatenates the arrays.
    function _concat(address[] memory a, address[] memory b)
        private
        view
        returns (address[] memory result)
    {
        result = _toAddresses(_concat(_toUints(a), _toUints(b)));
    }

    /// @dev Reinterpret cast to an uint array.
    function _toUints(address[] memory a) private pure returns (uint256[] memory casted) {
        /// @solidity memory-safe-assembly
        assembly {
            casted := a
        }
    }

    /// @dev Reinterpret cast to an address array.
    function _toAddresses(uint256[] memory a) private pure returns (address[] memory casted) {
        /// @solidity memory-safe-assembly
        assembly {
            casted := a
        }
    }

    /// @dev Struct of temporary variables for mints.
    struct _DNMintTemps {
        uint256 toEnd;
        uint256[] mintIds;
    }

    /// @dev Struct of temporary variables for transfers.
    struct _DNTransferTemps {
        uint256 numNFTBurns;
        uint256 numNFTMints;
        uint256 fromOwnedCount;
        uint256 toOwnedCount;
        uint256 ownedCheckpoint;
        uint256[] directIds;
        uint256[] burnIds;
        uint256[] mintIds;
    }

    /// @dev Returns if `a` has bytecode of non-zero length.
    function _hasCode(address a) private view returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := extcodesize(a) // Can handle dirty upper bits.
        }
    }

    /// @dev Returns a `uint256[] calldata` at `offset` in calldata as `uint256[] memory`.
    function _calldataUint256Array(uint256 offset) private pure returns (uint256[] memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(0x04, calldataload(offset))
            let n := calldataload(o)
            mstore(result, n)
            calldatacopy(add(0x20, result), add(o, 0x20), shl(5, n))
            mstore(0x40, add(add(0x20, result), shl(5, n)))
        }
    }

    /// @dev Returns a `bytes calldata` at `offset` in calldata as `bytes memory`.
    function _calldataBytes(uint256 offset) private pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(0x04, calldataload(offset))
            let n := calldataload(o)
            mstore(result, n)
            calldatacopy(add(0x20, result), add(o, 0x20), n)
            o := add(add(0x20, result), n)
            mstore(o, 0) // Zeroize the slot after the last word.
            mstore(0x40, add(0x20, o))
        }
    }

    /// @dev Returns `a[i]` without bounds check.
    function _get(uint256[] memory a, uint256 i) private pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(add(add(0x20, a), shl(5, i)))
        }
    }

    /// @dev Sets `a[i]` to `value`, without bounds check.
    function _set(uint256[] memory a, uint256 i, uint256 value) private pure {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(add(add(0x20, a), shl(5, i)), value)
        }
    }

    /// @dev Returns the calldata value at `offset`.
    function _calldataload(uint256 offset) private pure returns (uint256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := calldataload(offset)
        }
    }

    /// @dev Executes a return opcode to return `x` and end the current call frame.
    function _return(uint256 x) private pure {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, x)
            return(0x00, 0x20)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized ECDSA wrapper.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ECDSA.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ECDSA.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
///
/// @dev Note:
/// - The recovery functions use the ecrecover precompile (0x1).
/// - As of Solady version 0.0.68, the `recover` variants will revert upon recovery failure.
///   This is for more safety by default.
///   Use the `tryRecover` variants if you need to get the zero address back
///   upon recovery failure instead.
/// - As of Solady version 0.0.134, all `bytes signature` variants accept both
///   regular 65-byte `(r, s, v)` and EIP-2098 `(r, vs)` short form signatures.
///   See: https://eips.ethereum.org/EIPS/eip-2098
///   This is for calldata efficiency on smart accounts prevalent on L2s.
///
/// WARNING! Do NOT directly use signatures as unique identifiers:
/// - The recovery operations do NOT check if a signature is non-malleable.
/// - Use a nonce in the digest to prevent replay attacks on the same contract.
/// - Use EIP-712 for the digest to prevent replay attacks across different chains and contracts.
///   EIP-712 also enables readable signing of typed data for better user safety.
/// - If you need a unique hash from a signature, please use the `canonicalHash` functions.
library ECDSA {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The order of the secp256k1 elliptic curve.
    uint256 internal constant N = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;

    /// @dev `N/2 + 1`. Used for checking the malleability of the signature.
    uint256 private constant _HALF_N_PLUS_1 =
        0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The signature is invalid.
    error InvalidSignature();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    RECOVERY OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recover(bytes32 hash, bytes memory signature) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   TRY-RECOVER OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // WARNING!
    // These functions will NOT revert upon recovery failure.
    // Instead, they will return the zero address upon recovery failure.
    // It is critical that the returned address is NEVER compared against
    // a zero address (e.g. an uninitialized address variable).

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    /// @dev Returns an Ethereum Signed Message, created from `s`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    /// Note: Supports lengths of `s` up to 999999 bytes.
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let sLength := mload(s)
            let o := 0x20
            mstore(o, "\x19Ethereum Signed Message:\n") // 26 bytes, zero-right-padded.
            mstore(0x00, 0x00)
            // Convert the `s.length` to ASCII decimal representation: `base10(s.length)`.
            for { let temp := sLength } 1 {} {
                o := sub(o, 1)
                mstore8(o, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }
            let n := sub(0x3a, o) // Header length: `26 + 32 - o`.
            // Throw an out-of-offset error (consumes all gas) if the header exceeds 32 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0x20))
            mstore(s, or(mload(0x00), mload(n))) // Temporarily store the header.
            result := keccak256(add(s, sub(0x20, n)), add(n, sLength))
            mstore(s, sLength) // Restore the length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  CANONICAL HASH FUNCTIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // The following functions returns the hash of the signature in it's canonicalized format,
    // which is the 65-byte `abi.encodePacked(r, s, uint8(v))`, where `v` is either 27 or 28.
    // If `s` is greater than `N / 2` then it will be converted to `N - s`
    // and the `v` value will be flipped.
    // If the signature has an invalid length, or if `v` is invalid,
    // a uniquely corrupt hash will be returned.
    // These functions are useful for "poor-mans-VRF".

    /// @dev Returns the canonical hash of `signature`.
    function canonicalHash(bytes memory signature) internal pure returns (bytes32 result) {
        // @solidity memory-safe-assembly
        assembly {
            let l := mload(signature)
            for {} 1 {} {
                mstore(0x00, mload(add(signature, 0x20))) // `r`.
                let s := mload(add(signature, 0x40))
                let v := mload(add(signature, 0x41))
                if eq(l, 64) {
                    v := add(shr(255, s), 27)
                    s := shr(1, shl(1, s))
                }
                if iszero(lt(s, _HALF_N_PLUS_1)) {
                    v := xor(v, 7)
                    s := sub(N, s)
                }
                mstore(0x21, v)
                mstore(0x20, s)
                result := keccak256(0x00, 0x41)
                mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
                break
            }

            // If the length is neither 64 nor 65, return a uniquely corrupted hash.
            if iszero(lt(sub(l, 64), 2)) {
                // `bytes4(keccak256("InvalidSignatureLength"))`.
                result := xor(keccak256(add(signature, 0x20), l), 0xd62f1ab2)
            }
        }
    }

    /// @dev Returns the canonical hash of `signature`.
    function canonicalHashCalldata(bytes calldata signature)
        internal
        pure
        returns (bytes32 result)
    {
        // @solidity memory-safe-assembly
        assembly {
            let l := signature.length
            for {} 1 {} {
                mstore(0x00, calldataload(signature.offset)) // `r`.
                let s := calldataload(add(signature.offset, 0x20))
                let v := calldataload(add(signature.offset, 0x21))
                if eq(l, 64) {
                    v := add(shr(255, s), 27)
                    s := shr(1, shl(1, s))
                }
                if iszero(lt(s, _HALF_N_PLUS_1)) {
                    v := xor(v, 7)
                    s := sub(N, s)
                }
                mstore(0x21, v)
                mstore(0x20, s)
                result := keccak256(0x00, 0x41)
                mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
                break
            }
            // If the length is neither 64 nor 65, return a uniquely corrupted hash.
            if iszero(lt(sub(l, 64), 2)) {
                calldatacopy(mload(0x40), signature.offset, l)
                // `bytes4(keccak256("InvalidSignatureLength"))`.
                result := xor(keccak256(mload(0x40), l), 0xd62f1ab2)
            }
        }
    }

    /// @dev Returns the canonical hash of `signature`.
    function canonicalHash(bytes32 r, bytes32 vs) internal pure returns (bytes32 result) {
        // @solidity memory-safe-assembly
        assembly {
            mstore(0x00, r) // `r`.
            let v := add(shr(255, vs), 27)
            let s := shr(1, shl(1, vs))
            mstore(0x21, v)
            mstore(0x20, s)
            result := keccak256(0x00, 0x41)
            mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the canonical hash of `signature`.
    function canonicalHash(uint8 v, bytes32 r, bytes32 s) internal pure returns (bytes32 result) {
        // @solidity memory-safe-assembly
        assembly {
            mstore(0x00, r) // `r`.
            if iszero(lt(s, _HALF_N_PLUS_1)) {
                v := xor(v, 7)
                s := sub(N, s)
            }
            mstore(0x21, v)
            mstore(0x20, s)
            result := keccak256(0x00, 0x41)
            mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes.
    function emptySignature() internal pure returns (bytes calldata signature) {
        /// @solidity memory-safe-assembly
        assembly {
            signature.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
///
/// @dev Note:
/// For performance and bytecode compactness, most of the string operations are restricted to
/// byte strings (7-bit ASCII), except where otherwise specified.
/// Usage of byte string operations on charsets with runes spanning two or more bytes
/// can lead to undefined behavior.
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The length of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /// @dev The length of the string is more than 32 bytes.
    error TooBigForSmallString();

    /// @dev The input string must be a 7-bit ASCII.
    error StringNot7BitASCII();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant ALPHANUMERIC_7_BIT_ASCII = 0x7fffffe07fffffe03ff000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant LETTERS_7_BIT_ASCII = 0x7fffffe07fffffe0000000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyz'.
    uint128 internal constant LOWERCASE_7_BIT_ASCII = 0x7fffffe000000000000000000000000;

    /// @dev Lookup for 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant UPPERCASE_7_BIT_ASCII = 0x7fffffe0000000000000000;

    /// @dev Lookup for '0123456789'.
    uint128 internal constant DIGITS_7_BIT_ASCII = 0x3ff000000000000;

    /// @dev Lookup for '0123456789abcdefABCDEF'.
    uint128 internal constant HEXDIGITS_7_BIT_ASCII = 0x7e0000007e03ff000000000000;

    /// @dev Lookup for '01234567'.
    uint128 internal constant OCTDIGITS_7_BIT_ASCII = 0xff000000000000;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c'.
    uint128 internal constant PRINTABLE_7_BIT_ASCII = 0x7fffffffffffffffffffffff00003e00;

    /// @dev Lookup for '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'.
    uint128 internal constant PUNCTUATION_7_BIT_ASCII = 0x78000001f8000001fc00fffe00000000;

    /// @dev Lookup for ' \t\n\r\x0b\x0c'.
    uint128 internal constant WHITESPACE_7_BIT_ASCII = 0x100003e00;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(uint256 value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits.
            result := add(mload(0x40), 0x80)
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end of the memory to calculate the length later.
            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                result := add(result, w) // `sub(result, 1)`.
                // Store the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(result, add(48, mod(temp, 10)))
                temp := div(temp, 10) // Keep dividing `temp` until zero.
                if iszero(temp) { break }
            }
            let n := sub(end, result)
            result := sub(result, 0x20) // Move the pointer 32 bytes back to make room for the length.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory result) {
        if (value >= 0) return toString(uint256(value));
        unchecked {
            result = toString(~uint256(value) + 1);
        }
        /// @solidity memory-safe-assembly
        assembly {
            // We still have some spare memory space on the left,
            // as we have allocated 3 words (96 bytes) for up to 78 digits.
            let n := mload(result) // Load the string length.
            mstore(result, 0x2d) // Store the '-' character.
            result := sub(result, 1) // Move back the string pointer by a byte.
            mstore(result, add(n, 1)) // Update the string length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2 + 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory result)
    {
        result = toHexStringNoPrefix(value, length);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is not prefixed with "0x" and is encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexStringNoPrefix(uint256 value, uint256 length)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, `length * 2` bytes
            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
            // We add 0x20 to the total and round down to a multiple of 0x20.
            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
            result := add(mload(0x40), and(add(shl(1, length), 0x42), not(0x1f)))
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end to calculate the length later.
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let start := sub(result, add(length, length))
            let w := not(1) // Tsk.
            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {} 1 {} {
                result := add(result, w) // `sub(result, 2)`.
                mstore8(add(result, 1), mload(and(temp, 15)))
                mstore8(result, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(xor(result, start)) { break }
            }
            if temp {
                mstore(0x00, 0x2194895a) // `HexLengthInsufficient()`.
                revert(0x1c, 0x04)
            }
            let n := sub(end, result)
            result := sub(result, 0x20)
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x".
    /// The output excludes leading "0" from the `toHexString` output.
    /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.
    function toMinimalHexString(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(result, 0x20))), 0x30) // Whether leading zero is present.
            let n := add(mload(result), 2) // Compute the length.
            mstore(add(result, o), 0x3078) // Store the "0x" prefix, accounting for leading zero.
            result := sub(add(result, o), 2) // Move the pointer, accounting for leading zero.
            mstore(result, sub(n, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output excludes leading "0" from the `toHexStringNoPrefix` output.
    /// `0x00: "0", 0x01: "1", 0x12: "12", 0x123: "123"`.
    function toMinimalHexStringNoPrefix(uint256 value)
        internal
        pure
        returns (string memory result)
    {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(result, 0x20))), 0x30) // Whether leading zero is present.
            let n := mload(result) // Get the length.
            result := add(result, o) // Move the pointer, accounting for leading zero.
            mstore(result, sub(n, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            result := add(mload(0x40), 0x80)
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end to calculate the length later.
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                result := add(result, w) // `sub(result, 2)`.
                mstore8(add(result, 1), mload(and(temp, 15)))
                mstore8(result, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }
            let n := sub(end, result)
            result := sub(result, 0x20)
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksummed(address value) internal pure returns (string memory result) {
        result = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(result, 0x22)
            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
            let t := shl(240, 136) // `0b10001000 << 240`
            for { let i := 0 } 1 {} {
                mstore(add(i, i), mul(t, byte(i, hashed)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
            o := add(o, 0x20)
            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    function toHexString(address value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            // Allocate memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(result, 0x80))
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            result := add(result, 2)
            mstore(result, 40) // Store the length.
            let o := add(result, 0x20)
            mstore(add(o, 40), 0) // Zeroize the slot after the string.
            value := shl(96, value)
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let i := 0 } 1 {} {
                let p := add(o, add(i, i))
                let temp := byte(i, value)
                mstore8(add(p, 1), mload(and(temp, 15)))
                mstore8(p, mload(shr(4, temp)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexString(bytes memory raw) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(raw)
            result := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(result, add(n, n)) // Store the length of the output.

            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.
            let o := add(result, 0x20)
            let end := add(raw, n)
            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RUNE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the number of UTF characters in the string.
    function runeCount(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                mstore(0x00, div(not(0), 255))
                mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for { result := 1 } 1 { result := add(result, 1) } {
                    o := add(o, byte(0, mload(shr(250, mload(o)))))
                    if iszero(lt(o, end)) { break }
                }
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string.
    /// (i.e. all characters codes are in [0..127])
    function is7BitASCII(string memory s) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let mask := shl(7, div(not(0), 255))
            let n := mload(s)
            if n {
                let o := add(s, 0x20)
                let end := add(o, n)
                let last := mload(end)
                mstore(end, 0)
                for {} 1 {} {
                    if and(mask, mload(o)) {
                        result := 0
                        break
                    }
                    o := add(o, 0x20)
                    if iszero(lt(o, end)) { break }
                }
                mstore(end, last)
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string,
    /// AND all characters are in the `allowed` lookup.
    /// Note: If `s` is empty, returns true regardless of `allowed`.
    function is7BitASCII(string memory s, uint128 allowed) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            if mload(s) {
                let allowed_ := shr(128, shl(128, allowed))
                let o := add(s, 0x20)
                for { let end := add(o, mload(s)) } 1 {} {
                    result := and(result, shr(byte(0, mload(o)), allowed_))
                    o := add(o, 1)
                    if iszero(and(result, lt(o, end))) { break }
                }
            }
        }
    }

    /// @dev Converts the bytes in the 7-bit ASCII string `s` to
    /// an allowed lookup for use in `is7BitASCII(s, allowed)`.
    /// To save runtime gas, you can cache the result in an immutable variable.
    function to7BitASCIIAllowedLookup(string memory s) internal pure returns (uint128 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                let o := add(s, 0x20)
                for { let end := add(o, mload(s)) } 1 {} {
                    result := or(result, shl(byte(0, mload(o)), 1))
                    o := add(o, 1)
                    if iszero(lt(o, end)) { break }
                }
                if shr(128, result) {
                    mstore(0x00, 0xc9807e0d) // `StringNot7BitASCII()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, byte string operations are restricted
    // to 7-bit ASCII strings. All offsets are byte offsets, not UTF character offsets.
    // Usage of byte string operations on charsets with runes spanning two or more bytes
    // can lead to undefined behavior.

    /// @dev Returns `subject` all occurrences of `needle` replaced with `replacement`.
    function replace(string memory subject, string memory needle, string memory replacement)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let needleLen := mload(needle)
            let replacementLen := mload(replacement)
            let d := sub(result, subject) // Memory difference.
            let i := add(subject, 0x20) // Subject bytes pointer.
            let end := add(i, mload(subject))
            if iszero(gt(needleLen, mload(subject))) {
                let subjectSearchEnd := add(sub(end, needleLen), 1)
                let h := 0 // The hash of `needle`.
                if iszero(lt(needleLen, 0x20)) { h := keccak256(add(needle, 0x20), needleLen) }
                let s := mload(add(needle, 0x20))
                for { let m := shl(3, sub(0x20, and(needleLen, 0x1f))) } 1 {} {
                    let t := mload(i)
                    // Whether the first `needleLen % 32` bytes of `subject` and `needle` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(i, needleLen), h)) {
                                mstore(add(i, d), t)
                                i := add(i, 1)
                                if iszero(lt(i, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let j := 0 } 1 {} {
                            mstore(add(add(i, d), j), mload(add(add(replacement, 0x20), j)))
                            j := add(j, 0x20)
                            if iszero(lt(j, replacementLen)) { break }
                        }
                        d := sub(add(d, replacementLen), needleLen)
                        if needleLen {
                            i := add(i, needleLen)
                            if iszero(lt(i, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(add(i, d), t)
                    i := add(i, 1)
                    if iszero(lt(i, subjectSearchEnd)) { break }
                }
            }
            let n := add(sub(d, add(result, 0x20)), end)
            // Copy the rest of the string one word at a time.
            for {} lt(i, end) { i := add(i, 0x20) } { mstore(add(i, d), mload(i)) }
            let o := add(i, d)
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(string memory subject, string memory needle, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := not(0) // Initialize to `NOT_FOUND`.
            for { let subjectLen := mload(subject) } 1 {} {
                if iszero(mload(needle)) {
                    result := from
                    if iszero(gt(from, subjectLen)) { break }
                    result := subjectLen
                    break
                }
                let needleLen := mload(needle)
                let subjectStart := add(subject, 0x20)

                subject := add(subjectStart, from)
                let end := add(sub(add(subjectStart, subjectLen), needleLen), 1)
                let m := shl(3, sub(0x20, and(needleLen, 0x1f)))
                let s := mload(add(needle, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLen))) { break }

                if iszero(lt(needleLen, 0x20)) {
                    for { let h := keccak256(add(needle, 0x20), needleLen) } 1 {} {
                        if iszero(shr(m, xor(mload(subject), s))) {
                            if eq(keccak256(subject, needleLen), h) {
                                result := sub(subject, subjectStart)
                                break
                            }
                        }
                        subject := add(subject, 1)
                        if iszero(lt(subject, end)) { break }
                    }
                    break
                }
                for {} 1 {} {
                    if iszero(shr(m, xor(mload(subject), s))) {
                        result := sub(subject, subjectStart)
                        break
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(string memory subject, string memory needle)
        internal
        pure
        returns (uint256 result)
    {
        result = indexOf(subject, needle, 0);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(string memory subject, string memory needle, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := not(0) // Initialize to `NOT_FOUND`.
                let needleLen := mload(needle)
                if gt(needleLen, mload(subject)) { break }
                let w := result

                let fromMax := sub(mload(subject), needleLen)
                if iszero(gt(fromMax, from)) { from := fromMax }

                let end := add(add(subject, 0x20), w)
                subject := add(add(subject, 0x20), from)
                if iszero(gt(subject, end)) { break }
                // As this function is not too often used,
                // we shall simply use keccak256 for smaller bytecode size.
                for { let h := keccak256(add(needle, 0x20), needleLen) } 1 {} {
                    if eq(keccak256(subject, needleLen), h) {
                        result := sub(subject, add(end, 1))
                        break
                    }
                    subject := add(subject, w) // `sub(subject, 1)`.
                    if iszero(gt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(string memory subject, string memory needle)
        internal
        pure
        returns (uint256 result)
    {
        result = lastIndexOf(subject, needle, type(uint256).max);
    }

    /// @dev Returns true if `needle` is found in `subject`, false otherwise.
    function contains(string memory subject, string memory needle) internal pure returns (bool) {
        return indexOf(subject, needle) != NOT_FOUND;
    }

    /// @dev Returns whether `subject` starts with `needle`.
    function startsWith(string memory subject, string memory needle)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let needleLen := mload(needle)
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                iszero(gt(needleLen, mload(subject))),
                eq(
                    keccak256(add(subject, 0x20), needleLen),
                    keccak256(add(needle, 0x20), needleLen)
                )
            )
        }
    }

    /// @dev Returns whether `subject` ends with `needle`.
    function endsWith(string memory subject, string memory needle)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let needleLen := mload(needle)
            // Whether `needle` is not longer than `subject`.
            let inRange := iszero(gt(needleLen, mload(subject)))
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                eq(
                    keccak256(
                        // `subject + 0x20 + max(subjectLen - needleLen, 0)`.
                        add(add(subject, 0x20), mul(inRange, sub(mload(subject), needleLen))),
                        needleLen
                    ),
                    keccak256(add(needle, 0x20), needleLen)
                ),
                inRange
            )
        }
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(string memory subject, uint256 times)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLen := mload(subject)
            if iszero(or(iszero(times), iszero(subjectLen))) {
                result := mload(0x40)
                subject := add(subject, 0x20)
                let o := add(result, 0x20)
                for {} 1 {} {
                    // Copy the `subject` one word at a time.
                    for { let j := 0 } 1 {} {
                        mstore(add(o, j), mload(add(subject, j)))
                        j := add(j, 0x20)
                        if iszero(lt(j, subjectLen)) { break }
                    }
                    o := add(o, subjectLen)
                    times := sub(times, 1)
                    if iszero(times) { break }
                }
                mstore(o, 0) // Zeroize the slot after the string.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
                mstore(result, sub(o, add(result, 0x20))) // Store the length.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(string memory subject, uint256 start, uint256 end)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLen := mload(subject)
            if iszero(gt(subjectLen, end)) { end := subjectLen }
            if iszero(gt(subjectLen, start)) { start := subjectLen }
            if lt(start, end) {
                result := mload(0x40)
                let n := sub(end, start)
                let i := add(subject, start)
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let j := and(add(n, 0x1f), w) } 1 {} {
                    mstore(add(result, j), mload(add(i, j)))
                    j := add(j, w) // `sub(j, 0x20)`.
                    if iszero(j) { break }
                }
                let o := add(add(result, 0x20), n)
                mstore(o, 0) // Zeroize the slot after the string.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
                mstore(result, n) // Store the length.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
    /// `start` is a byte offset.
    function slice(string memory subject, uint256 start)
        internal
        pure
        returns (string memory result)
    {
        result = slice(subject, start, type(uint256).max);
    }

    /// @dev Returns all the indices of `needle` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(string memory subject, string memory needle)
        internal
        pure
        returns (uint256[] memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLen := mload(needle)
            if iszero(gt(searchLen, mload(subject))) {
                result := mload(0x40)
                let i := add(subject, 0x20)
                let o := add(result, 0x20)
                let subjectSearchEnd := add(sub(add(i, mload(subject)), searchLen), 1)
                let h := 0 // The hash of `needle`.
                if iszero(lt(searchLen, 0x20)) { h := keccak256(add(needle, 0x20), searchLen) }
                let s := mload(add(needle, 0x20))
                for { let m := shl(3, sub(0x20, and(searchLen, 0x1f))) } 1 {} {
                    let t := mload(i)
                    // Whether the first `searchLen % 32` bytes of `subject` and `needle` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(i, searchLen), h)) {
                                i := add(i, 1)
                                if iszero(lt(i, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        mstore(o, sub(i, add(subject, 0x20))) // Append to `result`.
                        o := add(o, 0x20)
                        i := add(i, searchLen) // Advance `i` by `searchLen`.
                        if searchLen {
                            if iszero(lt(i, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    i := add(i, 1)
                    if iszero(lt(i, subjectSearchEnd)) { break }
                }
                mstore(result, shr(5, sub(o, add(result, 0x20)))) // Store the length of `result`.
                // Allocate memory for result.
                // We allocate one more word, so this array can be recycled for {split}.
                mstore(0x40, add(o, 0x20))
            }
        }
    }

    /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.
    function split(string memory subject, string memory delimiter)
        internal
        pure
        returns (string[] memory result)
    {
        uint256[] memory indices = indicesOf(subject, delimiter);
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            let indexPtr := add(indices, 0x20)
            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
            mstore(add(indicesEnd, w), mload(subject))
            mstore(indices, add(mload(indices), 1))
            for { let prevIndex := 0 } 1 {} {
                let index := mload(indexPtr)
                mstore(indexPtr, 0x60)
                if iszero(eq(index, prevIndex)) {
                    let element := mload(0x40)
                    let l := sub(index, prevIndex)
                    mstore(element, l) // Store the length of the element.
                    // Copy the `subject` one word at a time, backwards.
                    for { let o := and(add(l, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    mstore(add(add(element, 0x20), l), 0) // Zeroize the slot after the string.
                    // Allocate memory for the length and the bytes, rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(l, 0x3f), w)))
                    mstore(indexPtr, element) // Store the `element` into the array.
                }
                prevIndex := add(index, mload(delimiter))
                indexPtr := add(indexPtr, 0x20)
                if iszero(lt(indexPtr, indicesEnd)) { break }
            }
            result := indices
            if iszero(mload(delimiter)) {
                result := add(indices, 0x20)
                mstore(result, sub(mload(indices), 2))
            }
        }
    }

    /// @dev Returns a concatenated string of `a` and `b`.
    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
    function concat(string memory a, string memory b)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let w := not(0x1f)
            let aLen := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(aLen, 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLen := mload(b)
            let output := add(result, aLen)
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLen, 0x20), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLen := add(aLen, bLen)
            let last := add(add(result, 0x20), totalLen)
            mstore(last, 0) // Zeroize the slot after the string.
            mstore(result, totalLen) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function toCase(string memory subject, bool toUpper)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(subject)
            if n {
                result := mload(0x40)
                let o := add(result, 0x20)
                let d := sub(subject, result)
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                for { let end := add(o, n) } 1 {} {
                    let b := byte(0, mload(add(d, o)))
                    mstore8(o, xor(and(shr(b, flags), 0x20), b))
                    o := add(o, 1)
                    if eq(o, end) { break }
                }
                mstore(result, n) // Store the length.
                mstore(o, 0) // Zeroize the slot after the string.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
            }
        }
    }

    /// @dev Returns a string from a small bytes32 string.
    /// `s` must be null-terminated, or behavior will be undefined.
    function fromSmallString(bytes32 s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let n := 0
            for {} byte(n, s) { n := add(n, 1) } {} // Scan for '\0'.
            mstore(result, n) // Store the length.
            let o := add(result, 0x20)
            mstore(o, s) // Store the bytes of the string.
            mstore(add(o, n), 0) // Zeroize the slot after the string.
            mstore(0x40, add(result, 0x40)) // Allocate memory.
        }
    }

    /// @dev Returns the small string, with all bytes after the first null byte zeroized.
    function normalizeSmallString(bytes32 s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} byte(result, s) { result := add(result, 1) } {} // Scan for '\0'.
            mstore(0x00, s)
            mstore(result, 0x00)
            result := mload(0x00)
        }
    }

    /// @dev Returns the string as a normalized null-terminated small string.
    function toSmallString(string memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(s)
            if iszero(lt(result, 33)) {
                mstore(0x00, 0xec92f9a3) // `TooBigForSmallString()`.
                revert(0x1c, 0x04)
            }
            result := shl(shl(3, sub(32, result)), mload(add(s, result)))
        }
    }

    /// @dev Returns a lowercased copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function lower(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, false);
    }

    /// @dev Returns an UPPERCASED copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function upper(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, true);
    }

    /// @dev Escapes the string to be used within HTML tags.
    function escapeHTML(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let end := add(s, mload(s))
            let o := add(result, 0x20)
            // Store the bytes of the packed offsets and strides into the scratch space.
            // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
            mstore(0x1f, 0x900094)
            mstore(0x08, 0xc0000000a6ab)
            // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
            mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(o, c)
                    o := add(o, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(o, mload(and(t, 0x1f)))
                o := add(o, shr(5, t))
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    /// If `addDoubleQuotes` is true, the result will be enclosed in double-quotes.
    function escapeJSON(string memory s, bool addDoubleQuotes)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(result, 0x20)
            if addDoubleQuotes {
                mstore8(o, 34)
                o := add(1, o)
            }
            // Store "\\u0000" in scratch space.
            // Store "0123456789abcdef" in scratch space.
            // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
            // into the scratch space.
            mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
            // Bitmask for detecting `["\"","\\"]`.
            let e := or(shl(0x22, 1), shl(0x5c, 1))
            for { let end := add(s, mload(s)) } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                if iszero(lt(c, 0x20)) {
                    if iszero(and(shl(c, 1), e)) {
                        // Not in `["\"","\\"]`.
                        mstore8(o, c)
                        o := add(o, 1)
                        continue
                    }
                    mstore8(o, 0x5c) // "\\".
                    mstore8(add(o, 1), c)
                    o := add(o, 2)
                    continue
                }
                if iszero(and(shl(c, 1), 0x3700)) {
                    // Not in `["\b","\t","\n","\f","\d"]`.
                    mstore8(0x1d, mload(shr(4, c))) // Hex value.
                    mstore8(0x1e, mload(and(c, 15))) // Hex value.
                    mstore(o, mload(0x19)) // "\\u00XX".
                    o := add(o, 6)
                    continue
                }
                mstore8(o, 0x5c) // "\\".
                mstore8(add(o, 1), mload(add(c, 8)))
                o := add(o, 2)
            }
            if addDoubleQuotes {
                mstore8(o, 34)
                o := add(1, o)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        result = escapeJSON(s, false);
    }

    /// @dev Encodes `s` so that it can be safely used in a URI,
    /// just like `encodeURIComponent` in JavaScript.
    /// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
    /// See: https://datatracker.ietf.org/doc/html/rfc2396
    /// See: https://datatracker.ietf.org/doc/html/rfc3986
    function encodeURIComponent(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            // Store "0123456789ABCDEF" in scratch space.
            // Uppercased to be consistent with JavaScript's implementation.
            mstore(0x0f, 0x30313233343536373839414243444546)
            let o := add(result, 0x20)
            for { let end := add(s, mload(s)) } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // If not in `[0-9A-Z-a-z-_.!~*'()]`.
                if iszero(and(1, shr(c, 0x47fffffe87fffffe03ff678200000000))) {
                    mstore8(o, 0x25) // '%'.
                    mstore8(add(o, 1), mload(and(shr(4, c), 15)))
                    mstore8(add(o, 2), mload(and(c, 15)))
                    o := add(o, 3)
                    continue
                }
                mstore8(o, c)
                o := add(o, 1)
            }
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small string.
    function eqs(string memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
        }
    }

    /// @dev Packs a single string with its length into a single word.
    /// Returns `bytes32(0)` if the length is zero or greater than 31.
    function packOne(string memory a) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We don't need to zero right pad the string,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes.
                    mload(add(a, 0x1f)),
                    // `length != 0 && length < 32`. Abuses underflow.
                    // Assumes that the length is valid and within the block gas limit.
                    lt(sub(mload(a), 1), 0x1f)
                )
        }
    }

    /// @dev Unpacks a string packed using {packOne}.
    /// Returns the empty string if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packOne}, the output behavior is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40) // Grab the free memory pointer.
            mstore(0x40, add(result, 0x40)) // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(result, 0) // Zeroize the length slot.
            mstore(add(result, 0x1f), packed) // Store the length and bytes.
            mstore(add(add(result, 0x20), mload(result)), 0) // Right pad with zeroes.
        }
    }

    /// @dev Packs two strings with their lengths into a single word.
    /// Returns `bytes32(0)` if combined length is zero or greater than 30.
    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLen := mload(a)
            // We don't need to zero right pad the strings,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    or( // Load the length and the bytes of `a` and `b`.
                    shl(shl(3, sub(0x1f, aLen)), mload(add(a, aLen))), mload(sub(add(b, 0x1e), aLen))),
                    // `totalLen != 0 && totalLen < 31`. Abuses underflow.
                    // Assumes that the lengths are valid and within the block gas limit.
                    lt(sub(add(aLen, mload(b)), 1), 0x1e)
                )
        }
    }

    /// @dev Unpacks strings packed using {packTwo}.
    /// Returns the empty strings if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
    function unpackTwo(bytes32 packed)
        internal
        pure
        returns (string memory resultA, string memory resultB)
    {
        /// @solidity memory-safe-assembly
        assembly {
            resultA := mload(0x40) // Grab the free memory pointer.
            resultB := add(resultA, 0x40)
            // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.
            mstore(0x40, add(resultB, 0x40))
            // Zeroize the length slots.
            mstore(resultA, 0)
            mstore(resultB, 0)
            // Store the lengths and bytes.
            mstore(add(resultA, 0x1f), packed)
            mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))
            // Right pad with zeroes.
            mstore(add(add(resultA, 0x20), mload(resultA)), 0)
            mstore(add(add(resultB, 0x20), mload(resultB)), 0)
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(string memory a) internal pure {
        assembly {
            // Assumes that the string does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retUnpaddedSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retUnpaddedSize), 0)
            mstore(retStart, 0x20) // Store the return offset.
            // End the transaction, returning the string.
            return(retStart, and(not(0x1f), add(0x1f, retUnpaddedSize)))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library MerkleProofLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*            MERKLE PROOF VERIFICATION OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(proof) {
                // Initialize `offset` to the offset of `proof` elements in memory.
                let offset := add(proof, 0x20)
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(offset, shl(5, mload(proof)))
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, mload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), mload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(proof.offset, shl(5, proof.length))
                // Initialize `offset` to the offset of `proof` in the calldata.
                let offset := proof.offset
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, calldataload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), calldataload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - The sum of the lengths of `proof` and `leaves` must never overflow.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The memory offset of `proof` must be non-zero
    ///   (i.e. `proof` is not pointing to the scratch space).
    function verifyMultiProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32[] memory leaves,
        bool[] memory flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // Cache the lengths of the arrays.
            let leavesLength := mload(leaves)
            let proofLength := mload(proof)
            let flagsLength := mload(flags)

            // Advance the pointers of the arrays to point to the data.
            leaves := add(0x20, leaves)
            proof := add(0x20, proof)
            flags := add(0x20, flags)

            // If the number of flags is correct.
            for {} eq(add(leavesLength, proofLength), add(flagsLength, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flagsLength) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    isValid := eq(mload(xor(leaves, mul(xor(proof, leaves), proofLength))), root)
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof, shl(5, proofLength))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                leavesLength := shl(5, leavesLength)
                for { let i := 0 } iszero(eq(i, leavesLength)) { i := add(i, 0x20) } {
                    mstore(add(hashesFront, i), mload(add(leaves, i)))
                }
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, leavesLength)
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flagsLength := add(hashesBack, shl(5, flagsLength))

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(mload(flags)) {
                        // Loads the next proof.
                        b := mload(proof)
                        proof := add(proof, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag.
                    flags := add(flags, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flagsLength)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof)
                    )
                break
            }
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The calldata offset of `proof` must be non-zero
    ///   (i.e. `proof` is from a regular Solidity function with a 4-byte selector).
    function verifyMultiProofCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leaves,
        bool[] calldata flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // If the number of flags is correct.
            for {} eq(add(leaves.length, proof.length), add(flags.length, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flags.length) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    // forgefmt: disable-next-item
                    isValid := eq(
                        calldataload(
                            xor(leaves.offset, mul(xor(proof.offset, leaves.offset), proof.length))
                        ),
                        root
                    )
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof.offset, shl(5, proof.length))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                calldatacopy(hashesFront, leaves.offset, shl(5, leaves.length))
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, shl(5, leaves.length))
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flags.length := add(hashesBack, shl(5, flags.length))

                // We don't need to make a copy of `proof.offset` or `flags.offset`,
                // as they are pass-by-value (this trick may not always save gas).

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(calldataload(flags.offset)) {
                        // Loads the next proof.
                        b := calldataload(proof.offset)
                        proof.offset := add(proof.offset, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag offset.
                    flags.offset := add(flags.offset, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flags.length)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof.offset)
                    )
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes32 array.
    function emptyProof() internal pure returns (bytes32[] calldata proof) {
        /// @solidity memory-safe-assembly
        assembly {
            proof.length := 0
        }
    }

    /// @dev Returns an empty calldata bytes32 array.
    function emptyLeaves() internal pure returns (bytes32[] calldata leaves) {
        /// @solidity memory-safe-assembly
        assembly {
            leaves.length := 0
        }
    }

    /// @dev Returns an empty calldata bool array.
    function emptyFlags() internal pure returns (bool[] calldata flags) {
        /// @solidity memory-safe-assembly
        assembly {
            flags.length := 0
        }
    }
}