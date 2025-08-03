// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "../utils/ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation = 0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

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
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner) internal onlyInitializing {
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
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
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
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

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
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
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
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
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
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {ContextUpgradeable} from "../../utils/ContextUpgradeable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165Upgradeable} from "../../utils/introspection/ERC165Upgradeable.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721, IERC721Metadata, IERC721Errors {
    using Strings for uint256;

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721
    struct ERC721Storage {
        // Token name
        string _name;

        // Token symbol
        string _symbol;

        mapping(uint256 tokenId => address) _owners;

        mapping(address owner => uint256) _balances;

        mapping(uint256 tokenId => address) _tokenApprovals;

        mapping(address owner => mapping(address operator => bool)) _operatorApprovals;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721StorageLocation = 0x80bb2b638cc20bc4d0a60d66940f3ab4a00c1d7b313497ca82fb0b4ab0079300;

    function _getERC721Storage() private pure returns (ERC721Storage storage $) {
        assembly {
            $.slot := ERC721StorageLocation
        }
    }

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC721Storage storage $ = _getERC721Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        ERC721Storage storage $ = _getERC721Storage();
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return $._balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        unchecked {
            $._balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                $._balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                $._balances[to] += 1;
            }
        }

        $._owners[tokenId] = to;

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }
        }

        $._tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        $._operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) internal {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.20;

import {ERC721Upgradeable} from "../ERC721Upgradeable.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds enumerability
 * of all the token ids in the contract as well as all token ids owned by each account.
 *
 * CAUTION: `ERC721` extensions that implement custom `balanceOf` logic, such as `ERC721Consecutive`,
 * interfere with enumerability and should not be used together with `ERC721Enumerable`.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721Enumerable {
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721Enumerable
    struct ERC721EnumerableStorage {
        mapping(address owner => mapping(uint256 index => uint256)) _ownedTokens;
        mapping(uint256 tokenId => uint256) _ownedTokensIndex;

        uint256[] _allTokens;
        mapping(uint256 tokenId => uint256) _allTokensIndex;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721Enumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721EnumerableStorageLocation = 0x645e039705490088daad89bae25049a34f4a9072d398537b1ab2425f24cbed00;

    function _getERC721EnumerableStorage() private pure returns (ERC721EnumerableStorage storage $) {
        assembly {
            $.slot := ERC721EnumerableStorageLocation
        }
    }

    /**
     * @dev An `owner`'s token query was out of bounds for `index`.
     *
     * NOTE: The owner being `address(0)` indicates a global out of bounds index.
     */
    error ERC721OutOfBoundsIndex(address owner, uint256 index);

    /**
     * @dev Batch mint is not allowed.
     */
    error ERC721EnumerableForbiddenBatchMint();

    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        if (index >= balanceOf(owner)) {
            revert ERC721OutOfBoundsIndex(owner, index);
        }
        return $._ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        return $._allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        if (index >= totalSupply()) {
            revert ERC721OutOfBoundsIndex(address(0), index);
        }
        return $._allTokens[index];
    }

    /**
     * @dev See {ERC721-_update}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address previousOwner = super._update(to, tokenId, auth);

        if (previousOwner == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            _removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        return previousOwner;
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        uint256 length = balanceOf(to) - 1;
        $._ownedTokens[to][length] = tokenId;
        $._ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        $._allTokensIndex[tokenId] = $._allTokens.length;
        $._allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from);
        uint256 tokenIndex = $._ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = $._ownedTokens[from][lastTokenIndex];

            $._ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            $._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete $._ownedTokensIndex[tokenId];
        delete $._ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = $._allTokens.length - 1;
        uint256 tokenIndex = $._allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = $._allTokens[lastTokenIndex];

        $._allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        $._allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete $._allTokensIndex[tokenId];
        $._allTokens.pop();
    }

    /**
     * See {ERC721-_increaseBalance}. We need that to account tokens that were minted in batch
     */
    function _increaseBalance(address account, uint128 amount) internal virtual override {
        if (amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        super._increaseBalance(account, amount);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
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
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 */
interface IERC2981 is IERC165 {
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.20;

import {IERC721Metadata} from "../token/ERC721/extensions/IERC721Metadata.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.20;

import {IERC721} from "./IERC721.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC721Metadata} from "./extensions/IERC721Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {Strings} from "../../utils/Strings.sol";
import {IERC165, ERC165} from "../../utils/introspection/ERC165.sol";
import {IERC721Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Errors {
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;

    mapping(address owner => uint256) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Base64.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import { ERC721EnumerableUpgradeable } from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import { Errors } from "src/libraries/Errors.sol";
import { IMembership } from "src/types/IMembership.sol";
import { NFTRoyalties } from "src/utils/NFTRoyalties.sol";
import { ERC721DynamicIdsUpgradeable } from "src/utils/ERC721DynamicIdsUpgradeable.sol";
import { DynamicIds } from "src/libraries/DynamicIds.sol";
import { IMembershipDescriptor } from "src/utils/MembershipDescriptor.sol";
import { NFTRoyalties } from "src/utils/NFTRoyalties.sol";
import { Errors } from "src/libraries/Errors.sol";

/**
 * @title Membership
 * @author
 * @notice
 */
contract Membership is ERC721DynamicIdsUpgradeable, IMembership, NFTRoyalties, OwnableUpgradeable {
    /// @notice Collection of the metadata.
    Metadata internal _metadata;

    /// @notice Reference to external descriptor contract.
    IMembershipDescriptor internal _descriptor;

    /// @notice Information about the usage by membership.
    mapping(uint256 mintId => Usage) internal _usages;

    /// @notice Information about the membership round.
    mapping(uint256 mintId => uint256) internal _rounds;

    /// @notice Collection of the attributes of each membership.
    mapping(uint256 mintId => Attributes) internal _attributes;

    constructor() {
        _disableInitializers();
    }

    /// @inheritdoc IMembership
    function initialize(address presale_, Metadata memory metadata, IMembershipDescriptor descriptor)
        external
        virtual
        initializer
    {
        __Ownable_init(presale_);
        __NFTRoyalties_init(presale_);
        __ERC721_init(descriptor.name(metadata), descriptor.symbol(metadata));

        _metadata = metadata;
        _descriptor = descriptor;
    }

    /**
     * Increases the usage.current
     * @notice This function does no validation except for the valid id.
     * It’s up to the consumer to ensure any invariants.
     * @param publicId publicId of an NFT
     * @param amount usage.current increases by amount
     */
    function consume(uint256 publicId, uint256 amount) public onlyOwner returns (uint256) {
        uint256 mintId = _requireValidPublicId(publicId);
        _usages[mintId].current += amount;

        return _updatePublicId(publicId, mintId);
    }

    /**
     * Increases the usage.max
     * @notice This function does no validation except for the valid id.
     * It’s up to the consumer to ensure any invariants.
     * @param publicId publicId of an NFT
     * @param amount usage.max increases by amount
     */
    function extend(uint256 publicId, uint256 amount) public onlyOwner returns (uint256) {
        uint256 mintId = _requireValidPublicId(publicId);
        _usages[mintId].max += amount;
        return _updatePublicId(publicId, mintId);
    }

    /**
     * Decreases the usage.max
     * @notice This function does no validation except for the valid id.
     * It’s up to the consumer to ensure any invariants.
     * @param publicId publicId of an NFT
     * @param amount usage.max subtrahend
     */
    function reduce(uint256 publicId, uint256 amount) public onlyOwner returns (uint256) {
        uint256 mintId = _requireValidPublicId(publicId);
        _usages[mintId].max -= amount;
        return _updatePublicId(publicId, mintId);
    }

    /// @inheritdoc IMembership
    function getRoundId(uint256 publicId) external view returns (uint256) {
        uint256 mintId = _requireValidPublicId(publicId);
        return _rounds[mintId];
    }

    /// @inheritdoc IMembership
    function unlocked(uint256 publicId) external view returns (uint256) {
        uint256 mintId = _requireValidPublicId(publicId);
        uint256 start = getStart();
        uint256 allocation = _usages[mintId].max;
        IMembership.Attributes memory attributes = _attributes[mintId];

        return unlocked(start, allocation, attributes);
    }

    /// @inheritdoc IMembership
    function getStart() public view returns (uint256) {
        return presale.getTgeTimestamp();
    }

    /// @inheritdoc IMembership
    function unlocked(uint256 start, uint256 allocation, IMembership.Attributes memory attributes)
        public
        view
        returns (uint256)
    {
        uint256 timestamp = block.timestamp;

        if (timestamp < start) return 0;

        uint256 duration = attributes.vestingPeriodCount * attributes.vestingPeriodDuration + attributes.cliffDuration;

        if (timestamp >= start + duration) return allocation;

        uint256 tge = (allocation * attributes.tgeNumerator) / attributes.tgeDenominator;

        if (timestamp < start + attributes.cliffDuration) return tge;

        uint256 amountA = allocation - tge;
        uint256 timeSinceStart = timestamp - (start + attributes.cliffDuration);
        uint256 periodsSinceStart = timeSinceStart / attributes.vestingPeriodDuration;

        if (attributes.cliffDuration != 0) periodsSinceStart = periodsSinceStart + 1;

        return tge + (amountA * periodsSinceStart) / attributes.vestingPeriodCount;
    }

    /// @inheritdoc IMembership
    function mint(address owner_, uint256 roundId, uint256 currentUsage, uint256 maxUsage, Attributes memory attributes)
        public
        virtual
        onlyOwner
        returns (uint256 publicId)
    {
        uint256 mintId = DynamicIds.createMintId(abi.encodePacked(owner_, roundId, maxUsage, block.timestamp));

        Usage memory usage = Usage({ current: currentUsage, max: maxUsage });
        _rounds[mintId] = roundId;
        _usages[mintId] = usage;
        _attributes[mintId] = attributes;

        bytes memory data = abi.encode(usage, roundId, attributes);
        publicId = _mintDynamicIdNFT(owner_, mintId, data);
    }

    /// @inheritdoc IMembership
    function getUsage(uint256 publicId) public view returns (Usage memory) {
        uint256 mintId = _requireValidPublicId(publicId);
        return _usages[mintId];
    }

    /// @inheritdoc IMembership
    function getAttributes(uint256 publicId) public view returns (Attributes memory) {
        uint256 mintId = _requireValidPublicId(publicId);
        return _attributes[mintId];
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 publicId) public view override returns (string memory) {
        uint256 mintId = _requireValidPublicId(publicId);

        _requireOwned(mintId);

        return _descriptor.tokenURI(getStart(), _usages[mintId], _metadata, _attributes[mintId]);
    }

    /// @inheritdoc OwnableUpgradeable
    function owner() public view virtual override(OwnableUpgradeable, IMembership) returns (address) {
        return super.owner();
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable, IERC165, NFTRoyalties)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _getPayload(uint256 mintId) internal view override returns (bytes memory payload) {
        return abi.encode(_usages[mintId]);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

/**
 * Low-level utility library for manipulating Dynamic NFT ids.
 */
library DynamicIds {
    /**
     * Creates a public id of an NFT by hashing a payload and using its first 16 bytes as an id suffix.
     * @param id mint or public id of an NFT
     * @param payload abi.encode() of properties fundamental for assesing NFT value
     */
    function createPublicId(uint256 id, bytes memory payload) internal pure returns (uint256) {
        return uint256(bytes32(abi.encodePacked(getFirst16Bytes(id), getFirst16Bytes(keccak256(payload)))));
    }

    /**
     * Creates a mint id of an NFT with the last 16 bytes equal to zero.
     * @param mintPreimage abi.encode() of values uniquely identifying this NFT during minting.
     * It’s advised to include block.timestamp to prevent DOS.
     */
    function createMintId(bytes memory mintPreimage) internal pure returns (uint256) {
        return uint256(zeroLast16Bytes(keccak256(mintPreimage)));
    }

    /**
     * Returns the first 16 bytes of a number
     * @param value any 32-bytes long number
     */
    function getFirst16Bytes(uint256 value) internal pure returns (bytes16) {
        return getFirst16Bytes(bytes32(value));
    }

    /**
     * Returns the first 16 bytes of a value
     * @param value any 32-bytes long value
     */
    function getFirst16Bytes(bytes32 value) internal pure returns (bytes16) {
        return bytes16(value);
    }

    /**
     * Returns the last 16 bytes of a number
     * @param value any 32-bytes long number
     */
    function getLast16Bytes(uint256 value) internal pure returns (bytes16) {
        return getLast16Bytes(bytes32(value));
    }

    /**
     * Returns the last 16 bytes of a value
     * @param value any 32-bytes long value
     */
    function getLast16Bytes(bytes32 value) internal pure returns (bytes16) {
        return bytes16(value << 128);
    }

    /**
     * Zeros the last 16 bytes of a number
     * @param value any 32-bytes long number
     */
    function zeroLast16Bytes(uint256 value) internal pure returns (uint256) {
        return uint256(zeroLast16Bytes(bytes32(value)));
    }

    /**
     * Zeros the last 16 bytes of a value
     * @param value any 32-bytes long value
     */
    function zeroLast16Bytes(bytes32 value) internal pure returns (bytes32) {
        return value >> 128 << 128;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

library Errors {
    /// @notice Given value is out of safe bounds.
    error UnacceptableValue();

    /// @notice Given reference is `address(0)`.
    error UnacceptableReference();

    /// @notice The caller account is not authorized to perform an operation.
    /// @param account Address of the account.
    error Unauthorized(address account);

    /// @notice The caller account is not authorized to perform an operation.
    /// @param account Address of the account.
    error AccountMismatch(address account);

    /// @notice Denominators cannot equal zero because division by zero is not allowed.
    error DenominatorZero();
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MembershipSVG
 * @notice A library for generating the membership SVG.
 */
library MembershipSVG {
    using Strings for uint256;

    struct Params {
        string color;
        string title;
        uint256 max;
        uint256 current;
    }

    string internal constant ELEMENT_OPENING =
        '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 1500 1500" style="enable-background:new 0 0 1500 1500;" xml:space="preserve">';

    string internal constant ELEMENT_CLOSING = "</svg>";

    string internal constant BACKGROUND =
        '<rect fill="#171D24" width="1500" height="1500"/><path fill="#20262F" d="M479.2,371.4h-51.6v31.2l-31.2-31.2h-31.5l62.7,62.7v547.2L217.1,771v-51.2l203.3,203.3v-31.5l-182-182v-51.2l182,182V809L49.2,437.8v31.6l94.6,94.6v51.2l-94.6-94.6v31.5l94.6,94.6v51.2l-57.7-57.7v31.5l57.7,57.7v51.3L49.2,686v31.5l94.6,94.6v51.2l-94.6-94.6v31.5l323,323.1H321L49.2,851.4v31.5l94.6,94.6v51.2l94.6,94.7v31.5l-94.6-94.6v51.2l-94.6-94.6v31.5l234.4,234.4h31.5l-25.5-25.5h133.9l3.9,3.9l21.7,21.7h31.5l-41.3-41.3l25.6-25.6l66.9,66.9h31.3l-82.6-82.6l25.6-25.6L614.4,1283h31.5l-124-124V776.9l122.8,122.8l66.4-66.4V603.6L479.2,371.4z M282.6,950.8l144.9,144.9v27.5h-23.7L282.6,1002V950.8L282.6,950.8zM427.6,1013.1v51.2L238.4,875v-51.2L427.6,1013.1z M522,611.4l65.5,65.5v51.2L522,662.5V611.4z M552.2,558.8l131,130.8v51.2L552.2,610V558.8z M522,445.9l94.6,94.6v51.2L522,497.1V445.9z M232.6,1282.9L49.2,1099.5v31.5l94.6,94.6l57.3,57.3H232.6zM529.2,1114.7l168,168h14v-17.5l-182-182V1114.7z M711.2,1131.4v-31.5l-182-182v31.5L711.2,1131.4z M659,1161.8v-31.5l-129.7-129.7v31.5L659,1161.8z M529.2,866.6l182,182v-31.5l-182-182V866.6z M65.5,371.4H49.2v15.2l371.2,371.2v-31.6L65.5,371.4z M118.3,1282.9l31.6,0.1L49.2,1182.3v31.5L118.3,1282.9L118.3,1282.9z M711.2,469.7v-31.5l-66.8-66.8H613L711.2,469.7L711.2,469.7z M616.6,426.3l-55-55h-31.5l86.4,86.4l94.6,94.6v-31.5L616.6,426.3z M711.2,371.4h-15.6l15.6,15.6V371.4z M230.9,371.4h-31.5l220.9,220.9v-31.5L230.9,371.4z M313.6,371.4h-31.5l138.3,138.2v-31.5L313.6,371.4z M233.8,488.4L420.4,675v-31.5L265.3,488.4H233.8z"/>';

    string internal constant LOGO =
        '<polygon style="fill:none;stroke-miterlimit:10;" points="194.9,791.3 194.9,990.5 368.1,1088 539.3,990.5 539.3,791.3 368.1,691.8 "/><polyline style="fill:none;stroke-miterlimit:10;" points="458.6,1066.1 565.1,1005.5 565.1,776.6 553.6,770 "/><line style="fill:none;stroke-miterlimit:10;" x1="279.2" y1="954" x2="294.4" y2="938.8"/><line style="fill:none;stroke-miterlimit:10;" x1="257.5" y1="991.7" x2="300.3" y2="948.9"/><line style="fill:none;stroke-miterlimit:10;" x1="235.7" y1="1029.4" x2="306.1" y2="959"/><line style="fill:none;stroke-miterlimit:10;" x1="224" y1="1057" x2="311.9" y2="969.1"/><line style="fill:none;stroke-miterlimit:10;" x1="239.9" y1="1057" x2="317.8" y2="979.2"/><line style="fill:none;stroke-miterlimit:10;" x1="255.9" y1="1057" x2="323.6" y2="989.3"/><line style="fill:none;stroke-miterlimit:10;" x1="271.8" y1="1057" x2="329.4" y2="999.4"/><line style="fill:none;stroke-miterlimit:10;" x1="287.7" y1="1057" x2="335.3" y2="1009.5"/><line style="fill:none;stroke-miterlimit:10;" x1="303.7" y1="1057" x2="341.1" y2="1019.6"/><line style="fill:none;stroke-miterlimit:10;" x1="319.6" y1="1057" x2="346.9" y2="1029.7"/><line style="fill:none;stroke-miterlimit:10;" x1="335.5" y1="1057" x2="352.8" y2="1039.8"/><line style="fill:none;stroke-miterlimit:10;" x1="358.6" y1="1049.9" x2="351.5" y2="1057"/>';

    string internal constant DECORATORS =
        '<path style="fill:none;stroke:#383838;stroke-width:2;stroke-miterlimit:10;stroke-dasharray:4.0182,10.0455;" d="M799.2,1357c-13.1-21.2-20.8-47.4-20.8-75.6c0-20.8,4.2-40.4,11.6-57.8"/><polygon style="fill:#FFFFFF;" points="92.9,78.2 72.6,97.5 72.6,139.5 81.4,148.2 135.1,148.2 144.8,158 144.8,254.2 138.5,247.8 138.5,173.8 133,179.3 133,246.1 133,261.5 212.7,341.3 267.8,341.3 338,411.7 262.6,411.7 297.7,446.8 278.9,446.8 233.2,401.1 196.1,401.1 62.8,267.8 62.8,211.9 73.4,201.5 115.6,201.5 102,187.9 63.4,187.9 63.4,94.3 81,78.2 "/><polyline style="fill:none;stroke:#FFFFFF;stroke-miterlimit:10;" points="280.3,446.3 716.9,446.3 755.4,407.8 973.2,407.8 "/><circle style="fill:none;stroke:#FFFFFF;stroke-miterlimit:10;" cx="978" cy="407.8" r="4.8"/><circle style="fill:none;stroke:#FFFFFF;stroke-miterlimit:10;" cx="674.8" cy="65.7" r="4.8"/><polyline style="fill:none;stroke:#FFFFFF;stroke-miterlimit:10;" points="69.8,100.3 105.2,66.4 280.3,66.4 305.4,91.5 649,91.5 671.6,69 "/><path style="fill:#FFFFFF;" d="M1408.7,290.1L1209.4,90.8l-28.5-0.2L1380.3,290h28.4L1408.7,290.1L1408.7,290.1z M1387.1,299.7h-12.2l-186.8-186.8h-34.7L1110.5,70h-17.7l32.9,32.9h-70.5l65.7,66h51.5l74.7,74.7V258l135.1,135.1h55.5l13.6-13.6V364L1387.1,299.7z"/>';

    /// @notice Generate the svg markup.
    /// @param params Params with the svg configuration.
    function generate(Params memory params) internal pure returns (string memory) {
        uint256 percentage = params.max > 0 ? params.current * 100 / params.max : 0;

        uint256 progress = 10000 - (percentage * 100);

        return string.concat(
            ELEMENT_OPENING,
            BACKGROUND,
            cards(params.color, 100 - percentage),
            elements(params.color, progress),
            DECORATORS,
            labels(params.title, params.max, params.current),
            ELEMENT_CLOSING
        );
    }

    /// @notice Generate the cards markup.
    /// @param color Color of the elements.
    /// @param percentage Percentage value to print.
    function cards(string memory color, uint256 percentage) internal pure returns (string memory) {
        return string.concat(
            string.concat('<g fill="', color, '">'),
            '<path d="M1343.7,522.3v-10.9l-24.9-24.9h-13.6l-3.3,3.1h-195.7l-18.6,18.6h-12.8l-3.5,3.1h-87.6l-2.9-2.9h-35.9l-2.9,2.9H829l-3.1-3.1h-9.1l-24.2,24.2v11.2l3,3v64.3l-3.1-2.5v4.9l3.1,2.6v6.4l-3.1-2.5v4.9l3.1,2.6v6.4l-3.1-2.5v4.9l3.1,2.6v61l-3.1-5.6V715l24.3,24.3h24.9l-3.3-3.1h175.8l-3.1,3.1h11.1l22.5,22.5h6.5l-3.3-3.1h248.4l9.8-9.8h4.4l13.1-13.1v-78.6l20.2-20.2v-23.9l-3.1-3.3v-84L1343.7,522.3z M1295.2,756.3H1047l-22.5-22.5H819.2l-21-21v-178l21-21h270.7l21.7-21.7h204.7l21.6,21.6v121.1l-20.2,20.2v78.6L1295.2,756.3z"/>',
            '<path d="M1343.7,848.9V838l-24.9-24.9h-13.6l-3.3,3.1h-195.7l-18.6,18.6h-12.8l-3.5,3.1h-87.6l-2.9-2.9h-35.9l-2.9,2.9H829l-3.1-3.1h-9.1L792.6,859v11.2l3,3v64.3l-3.1-2.5v4.9l3.1,2.6v6.4l-3.1-2.5v4.9l3.1,2.6v6.4l-3.1-2.5v4.9l3.1,2.6v61l-3.1-5.6v20.9l24.3,24.3h24.9l-3.3-3.1h175.8l-3.1,3.1h11.1l22.5,22.5h6.5l-3.3-3.1h248.4l9.8-9.8h4.4l13.1-13.1v-78.6l20.2-20.2v-23.9l-3.1-3.3v-84L1343.7,848.9z M1295.2,1082.9H1047l-22.5-22.5H819.2l-21-21v-178l21-21h270.7l21.7-21.7h204.7l21.6,21.6v121.1l-20.2,20.2v78.6L1295.2,1082.9z"/>',
            '<path d="M1337.8,1279.1L1337.8,1279.1c-2,0-3.7-1.6-3.7-3.7l0,0c0-2,1.6-3.7,3.7-3.7l0,0c2,0,3.7,1.6,3.7,3.7l0,0C1341.5,1277.5,1339.8,1279.1,1337.8,1279.1z"/>',
            '<text transform="matrix(1 0 0 1 1066.4193 1071.1001)" style="font-size:28px; text-transform:uppercase; font-family:Futura,Arial,monospace; font-weight: 900">claimed</text>',
            '<text transform="matrix(1 0 0 1 1057.7942 744.2)" style="font-size:28px; text-transform:uppercase; font-family:Futura,Arial,monospace; font-weight: 900">purchased</text>',
            string.concat(
                '<text transform="matrix(1 0 0 1 1066.1456 1290.5452)" style="font-size:28px; text-transform:uppercase; font-family:Futura,Arial,monospace; font-weight: 900">',
                percentage.toString(),
                "% left</text>"
            ),
            "</g>"
        );
    }

    /// @notice Generate the elements markup.
    /// @param color Color of the elements.
    /// @param progress Progress value to print.
    function elements(string memory color, uint256 progress) internal pure returns (string memory) {
        return string.concat(
            string.concat('<g stroke="', color, '">'),
            '<path style="fill:none;stroke-width:2;stroke-miterlimit:10;" d="M999.4,1354.6c-21.1,25.2-52.8,41.1-88.2,41.1c-63.5,0-115.1-51.6-115.1-115.1s51.6-115.1,115.1-115.1c8,0,15.7,0.8,23.2,2.4"/>',
            '<path style="fill:none;stroke-width:2;stroke-miterlimit:10;" d="M954.2,1396.8c-57.4,21.3-123.2-2.8-152.5-58.4c-4-7.6-7.1-15.3-9.4-23.2"/>',
            '<path style="fill:none;stroke-width:2;stroke-miterlimit:10;" d="M991,1186c11.9,10,22,22.4,29.8,36.9c14.7,28,17.7,59.1,10.6,87.7"/>',
            '<path style="fill:none;stroke-width:2;stroke-miterlimit:10;" d="M1337.8,1285.2L1337.8,1285.2c-5.4,0-9.8-4.4-9.8-9.8l0,0c0-5.4,4.4-9.8,9.8-9.8l0,0c5.4,0,9.8,4.4,9.8,9.8l0,0C1347.6,1280.8,1343.2,1285.2,1337.8,1285.2z"/>',
            '<polyline style="fill:none;stroke-width:2;stroke-miterlimit:10;" points="991,1363.6 1022.7,1395.2 1305.8,1395.2 1337.8,1363.2 1337.8,1275.4 "/>',
            '<path style="fill:none;stroke-width:2;stroke-miterlimit:10;stroke-dasharray:6.1193,6.1193;" d="M943.5,1170.1c47.9,13.9,82.9,58.1,82.9,110.5c0,26-8.6,49.9-23.1,69.2"/>',
            '<path style="fill:none;stroke-width:2;stroke-miterlimit:10;stroke-dasharray:6.0368,6.0368;" d="M861.9,1167.2c22.5-9.8,46.7-12.4,69.6-8.6"/>',
            '<circle cx="911.3" cy="1280.6" r="84.8" style="fill:none;stroke:#393E4A;stroke-width:28;stroke-miterlimit:10;"/>',
            string.concat(
                '<circle cx="911.3" cy="1280.6" r="84.8" style="fill:none;stroke-width:28;stroke-miterlimit:10;" pathLength="10000" stroke-dasharray="10000" stroke-dashoffset="',
                progress.toString(),
                '" transform="rotate(-90)" transform-origin="911.3 1280.6"/>'
            ),
            LOGO,
            "</g>"
        );
    }

    /// @notice Generate the labels markup.
    /// @param title Label to print.
    /// @param max Value to print.
    /// @param current Value to print.
    function labels(string memory title, uint256 max, uint256 current) internal pure returns (string memory) {
        return string.concat(
            string.concat(
                '<text transform="matrix(1 0 0 1 259.3455 289.9893)" style="fill:#FFFFFF; font-family:Futura,Arial,monospace; font-weight: 900;" font-size="65px">',
                title,
                "</text>"
            ),
            string.concat(
                '<text transform="matrix(1 0 0 1 872.9004 644.1)" style="fill:#FFFFFF; font-family:Futura,Arial,monospace; font-weight: 900;" font-size="50px">',
                max.toString(),
                "</text>"
            ),
            string.concat(
                '<text transform="matrix(1 0 0 1 872.9005 966.0894)" style="fill:#FFFFFF; font-family:Futura,Arial,monospace; font-weight: 900;" font-size="50px">',
                current.toString(),
                "</text>"
            )
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { IMembership } from "./IMembership.sol";

import { IMembershipDescriptor } from "src/utils/MembershipDescriptor.sol";

struct MembershipConfiguration {
    address factory;
    IMembershipDescriptor descriptor;
    IMembership.Metadata metadata;
}

struct Configuration {
    IERC20 tokenA;
    IERC20 tokenB;
    address manager;
    address beneficiary;
    uint256 listingTimestamp;
    uint256 claimbackPeriod;
    MembershipConfiguration membership;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

struct Fees {
    uint16 tokenAFeeNumerator;
    uint16 tokenAFeeDenominator;
    uint16 tokenBFeeNumerator;
    uint16 tokenBFeeDenominator;
    uint16 nftFeeNumerator;
    uint16 nftFeeDenominator;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import { IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import { IMembershipDescriptor } from "src/utils/MembershipDescriptor.sol";

/**
 * @title Membership
 * @author
 * @notice
 */
interface IMembership is IERC2981, IERC721, IERC721Enumerable {
    struct Usage {
        uint256 max;
        uint256 current;
    }

    struct Metadata {
        address token;
        string color;
        string description;
    }

    struct Attributes {
        uint256 price;
        uint256 allocation;
        uint256 claimableBackUnit;
        uint32 tgeNumerator;
        uint32 tgeDenominator;
        uint32 cliffDuration;
        uint32 cliffNumerator;
        uint32 cliffDenominator;
        uint32 vestingPeriodCount;
        uint32 vestingPeriodDuration;
    }

    /// @notice Creates new membership and transfers it to given owner.
    /// @param owner_ Address of new address owner.
    /// @param roundId Id of the assigned round.
    /// @param maxUsage Max usage of the new membership.
    /// @param attributes Attributes attached to the membership.
    function mint(address owner_, uint256 roundId, uint256 currentUsage, uint256 maxUsage, Attributes memory attributes)
        external
        returns (uint256);

    /// @notice Contract state initialization.
    /// @param presale_ Address of the presale.
    /// @param metadata Metadata of the membership.
    /// @param descriptor Address to external descriptor.
    function initialize(address presale_, Metadata memory metadata, IMembershipDescriptor descriptor) external;

    function extend(uint256 publicId, uint256 amount) external returns (uint256 newId);
    function reduce(uint256 publicId, uint256 amount) external returns (uint256 newId);
    function consume(uint256 publicId, uint256 amount) external returns (uint256 newId);

    /// @notice Returns the start timestamp.
    function getStart() external view returns (uint256);

    /// @notice Returns the usage by given membership id.
    function getUsage(uint256 membershipId) external view returns (Usage memory);

    /// @notice Returns the round by given membership id.
    function getRoundId(uint256 membershipId) external view returns (uint256);

    /// @notice Returns the attributes by given membership id.
    function getAttributes(uint256 membershipId) external view returns (Attributes memory);

    /// @notice Returns releasable amount in the given timestamp.
    /// @param membershipId Id of the membership.
    function unlocked(uint256 membershipId) external view returns (uint256);
    function unlocked(uint256 start, uint256 allocation, IMembership.Attributes memory attributes)
        external
        view
        returns (uint256);

    function owner() external view returns (address);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { Fees } from "./Fees.sol";
import { Configuration } from "./Configuration.sol";
import { Round, RoundState } from "./Round.sol";
import { IVest } from "./IVest.sol";
import { IMembership } from "./IMembership.sol";

interface IPresale {
    /// @notice Event emitted when the funds has been claimed with SaleMembership
    /// @param membershipId an id of the SaleMembership used to claim funds
    event ClaimedWithSaleMembership(uint256 indexed membershipId);

    /// @notice Event emitted when the funds has been claimed.
    /// @param vMembershipId Id of the membership.
    /// @param amountA Amount of the claimed funds.
    event Claimed(uint256 indexed vMembershipId, uint256 amountA);

    /// @notice Event emitted when the funds has been claimbacked.
    /// @param vMembershipId Id of the membership.
    /// @param amountA Amount of the claimbacked funds.
    event Claimbacked(uint256 indexed vMembershipId, uint256 amountA);

    /// @notice Event emitted when the funds has been deposited.
    /// @param amount Amount of the deposited funds.
    event DepositedA(uint256 amount);

    /// @notice Event emitted when the funds has been withdrawn.
    /// @param amount Amount of the withdrawn funds.
    event WithdrawnA(uint256 amount);

    /// @notice Event emitted when the funds has been withdrawn.
    /// @param amount Amount of the withdrawn funds.
    event WithdrawnB(uint256 amount);

    /// @notice Event emitted when the round has been updated.
    event RoundUpdated(uint256 indexed id);

    /// @notice Event emitted when the tge start timestamp has been updated.
    /// @param timestamp The new timestamp.
    event ListingTimestampUpdated(uint256 timestamp);

    //-------------------------------------------------------------------------
    // Errors

    /// @notice Cannot update the locked round.
    /// @param id Id of the round.
    error RoundIsLocked(uint256 id);

    /// @notice The round with given id does not exist.
    /// @param id Id of the round.
    error RoundNotExists(uint256 id);

    /// @notice Round is in a different state.
    /// @param id The id of updated round.
    /// @param current Current state of the round.
    /// @param expected Expected state of the round.
    error RoundStateMismatch(uint256 id, RoundState current, RoundState expected);

    /// @notice Claim not allowed by given membership.
    /// @param membershipId Id of the membership.
    error ClaimNotAllowed(uint256 membershipId);

    /// @notice Claimback not allowed for given membership.
    /// @param membershipId Id of the membership.
    error ClaimbackNotAllowed(uint256 membershipId);

    /// @notice Listing timestamp is not set.
    error UnacceptableListingTimestamp();

    /// @notice Cliffs that unblock tokens immediately are not allowed
    error CliffWithImmediateUnlock();

    /// @notice Vesting periods with duration 0 are not allowed
    error VestingWithImmediateUnlock();

    /// @notice Vesting with only one period is too short. Either use cliff or increase period count.
    error CliffLikeVesting();

    /// @notice The vesting is configured such that it would never unlock any tokens.
    error VestingWithoutUnlocks();

    /// @notice Cliff height is specified but no vesting periods follow. In that case, all tokens will be unlocked at cliff end so cliffNumerator should equal zero.
    error CliffHeightWithoutSubsequentUnlocks();

    /// @notice When vesting is configured such that it will never release 100% tokens or it will release more than 100% of tokens.
    error VestingSize();

    /// @notice This protocol does not support tokens with transfer fees
    error TokenWithTransferFees(address tokenAddress);

    /// @notice Proofs can’t be used twice
    error ProofsUsedUp(uint256 roundId, address whitelistedAddress);

    /// @notice Remaining usage of the membership is zero.
    /// @param membershipId Id of the membership.
    error MembershipUsed(uint256 membershipId);

    /// @notice `LiquidityA` is lower than needed.
    error OutOfLiquidityA();

    error InvalidDeployer();

    function tokenA() external view returns (IERC20);
    function tokenB() external view returns (IERC20);
    function manager() external view returns (address);
    function parentVest() external view returns (IVest);
    function beneficiary() external view returns (address);
    function membership() external view returns (IMembership);
    function claimbackPeriod() external view returns (uint256);
    function getFees() external view returns (Fees memory fees);
    function liquidityA() external view returns (uint256);
    function liquidityB() external view returns (uint256);
    function listingTimestamp() external view returns (uint256);
    function getTgeTimestamp() external view returns (uint256);
    function nonClaimableBackTokenB() external view returns (uint256);
    function getFeeCollector() external view returns (address feeCollector);
    function getRound(uint256 roundId) external view returns (Round memory);
    function getRounds()
        external
        view
        returns (uint256[] memory ids, Round[] memory rounds, RoundState[] memory states);
    function getRoundState(uint256 roundId) external view returns (RoundState);
    function initialize(Configuration memory configuration, Round[] memory rounds_, Fees memory fees_) external;
    function addRound(Round memory round) external;
    function updateRound(uint256 roundId, Round memory round) external;
    function removeRound(uint256 roundId) external;
    function updateWhitelist(uint256 roundId, bytes32 whitelistRoot, string memory proofsUri) external;
    function updateListingTimestamp(uint256 listingTimestamp) external;
    function depositTokenA(uint256 tokenA) external;
    function withdrawTokenA(uint256 tokenA) external;
    function withdrawTokenB() external;
    function withdrawToken(address to, IERC20 token, uint256 amount) external;
    function buy(uint256 roundId, uint256 amountA, IMembership.Attributes memory attributes, bytes32[] calldata proof)
        external
        returns (uint256 membershipId);
    function extend(uint256 membershipId, uint256 amountA) external returns (uint256 newId);
    function claim(uint256 membershipId) external returns (uint256 newMembershipId);
    function claimback(uint256 membershipId, uint256 amountA) external returns (uint256 newId);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Fees } from "./Fees.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IVest is IERC165 {
    event FeesUpdated(Fees);

    error FeesDontMatch();

    function setFees(Fees memory) external;

    function getFees() external view returns (Fees memory);

    function owner() external view returns (address);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

enum RoundState {
    PENDING,
    SALE,
    VESTING
}

struct Round {
    string name;
    uint256 startTimestamp;
    uint256 endTimestamp;
    bytes32 whitelistRoot;
    string proofsUri;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { ERC721EnumerableUpgradeable } from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { DynamicIds } from "src/libraries/DynamicIds.sol";

/**
 * @dev ERC721DynamicIdsUpgradeable is a clever trick to make trading NFTs with dynamic traits safe.
 *
 * Stable value represented by an NFT is a prerequisite for safe trading today.
 *
 * If the value of an NFT can be changed by the seller, they can rug the buyer by using up the NFT before they accept they buy offer.
 *
 * Dynamic ids solve that problem by burning the old NFT and minting a new one every time the value of an NFT changes.
 * That invalidates all offers made for an NFT before the value changed.
 *
 * A naive implementation would perform literal burn and mint every time but that’s extremely gas-inefficient.
 *
 * A clever implementation changes NFT id every time its value changes, emits Transfer events as if the NFT was
 * burned and minted, while in reality no storage writes are performed.
 *
 * For this to work, we use 32-byte numbers as ids where:
 * - the first 16 bytes are calculated during the mint and never change again.
 * - the last 16 bytes are calculated every time the value changes.
 *
 * This results in a new id being issued every time the value changes while keeping some unique part of it (the first 16 bytes)
 * constant so that we can keep track of owners, allowances, and other properties.
 *
 * An id emitted in Transfer events and visible to the outside world is called a publicId.
 * An id used internally to keep track of things is called a mintId.
 *
 * The last 16 bytes of mintId MUST equal zero.
 *
 * A watchful reader will notice that by splitting ids in two 16-bytes long parts, we increase the risk of id collision.
 * This risk is described by The Birthday Problem.
 * For 16-bytes long ids, the risk of collision raises above 1% after generating 52 * 10^18 perfectly random ids.
 * That makes a collision unlikely for most protocols using this technique.
 *
 * Note that _safeMint function prevents minting NFTs with an id that already exists.
 *
 * To prevent DOS due to id collision, it’s advised protocols mix in block.timestamp into the mintId payload.
 *
 * Note: this contract requires a patch on OpenZeppelin ERC721 implementation such that the _update function does not emit
 * the Transfer event because it only has access to a mintId while Transfer events should be emitted using publicId.
 *
 * @notice This contract is marked as abstract because inheriting contract MUST override _getPayload function so that it returns
 * a unique payload every time the value of the NFT changes.
 */
abstract contract ERC721DynamicIdsUpgradeable is ERC721EnumerableUpgradeable {
    /**
     * An event emited during the NFT minting that allows for efficient querying of an arbitrary data attached to the NFT.
     * @param mintId an immutable id with last 16 bytes zeroed. The same that is used internally.
     * @param data arbitrary data assigned to the NFT. This can include data that is either immutable or does not cause public id to change when updated.
     */
    event DynamicIdNFTMinted(uint256 indexed mintId, address indexed owner, bytes data);

    /**
     * This is a special event that allows for easy tracking of the NFT across value changes.
     * @param mintId an immutable id with last 16 bytes zeroed. The same that is used internally.
     * @param newPublicId new public id after the update happened.
     * @param payload payload resulting in the new public id.
     */
    event DynamicIdNFTUpdated(uint256 indexed mintId, uint256 indexed newPublicId, bytes payload);

    error InvalidMintId(uint256 mintId);

    /**
     * This mint function SHOULD be used instead of _safeMint as it takes care of emitting the right events.
     * @param to an address receiving an NFT
     * @param mintId an immutable id with last 16 bytes zeroed. The same that is used internally.
     * @param data arbitrary data assigned to the NFT. This can include data that is either immutable or does not cause public id to change when updated.
     */
    function _mintDynamicIdNFT(address to, uint256 mintId, bytes memory data) internal returns (uint256) {
        bytes memory payload = _getPayload(mintId);
        uint256 publicId = DynamicIds.createPublicId(mintId, payload);
        _safeMint(to, publicId, data);
        emit DynamicIdNFTMinted(mintId, to, data);
        emit DynamicIdNFTUpdated(mintId, publicId, payload);
        return publicId;
    }

    /**
     * This MUST be used every time a publicId is consumed as a parameter to:
     * - validate given publicId is valid
     * - get mintId to perform access storage correctly
     *
     * It is similar to _requireOwned from OpenZeppelin’s ERC721 implementation.
     *
     * @param publicId a public id of an NFT
     */
    function _requireValidPublicId(uint256 publicId) internal view returns (uint256 mintId) {
        mintId = DynamicIds.zeroLast16Bytes(publicId);
        bytes16 publicIdLast16Bytes = DynamicIds.getLast16Bytes(publicId);
        if (DynamicIds.getFirst16Bytes(keccak256(_getPayload(mintId))) != publicIdLast16Bytes) {
            revert ERC721NonexistentToken(publicId);
        }
    }

    /**
     * This MUST be used once in every transaction that changes the value of an NFT such that
     * the payload returned by the _getPayload function is diffrent than before.
     *
     * This lets the outside world know the old NFT has been burned and the new NFT has been minted.
     *
     * @param prevPublicId a public id of an NFT
     * @param mintId a mint id of an NFT
     */
    function _updatePublicId(uint256 prevPublicId, uint256 mintId) internal returns (uint256 newId) {
        bytes memory payload = _getPayload(mintId);
        newId = _getPublicId(mintId, payload);
        address owner = _ownerOf(mintId);

        _checkOnERC721Received(address(0), owner, newId, "");

        emit IERC721.Transfer(owner, address(0), prevPublicId);
        emit IERC721.Transfer(address(0), owner, newId);
        emit DynamicIdNFTUpdated(mintId, newId, payload);
    }

    /**
     * This function MUST be overriten by an inheriting smart contract such that the payload
     * changes every time the value of an underlying NFT changes.
     * @param mintId a mint id of an NFT
     */
    function _getPayload(uint256 mintId) internal view virtual returns (bytes memory payload);

    /**
     * Translates mintId to publicId. Useful for overriding functions that return mintId.
     * @param mintId a mint id of an NFT
     * @param payload the result of the _getPayload function
     */
    function _getPublicId(uint256 mintId, bytes memory payload) private pure returns (uint256 publicId) {
        return DynamicIds.createPublicId(mintId, payload);
    }

    /*
     * ERC721Upgradeable overrides.
     *
     * We override all public methods that take tokenId as a parameter
     * except safeTransferFrom(address from, address to, uint256 tokenId)
     * because it calls
     * function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
     * so translating tokenId twice would be wasteful.
     *
     * All internal transactions must receive mintId to work correctly.
     *
     * We also override _safeMint to validate mintId and emit a proper Transfer event.
     */

    function ownerOf(uint256 publicId) public view override(ERC721Upgradeable, IERC721) returns (address) {
        uint256 mintId = _requireValidPublicId(publicId);
        return super.ownerOf(mintId);
    }

    function tokenURI(uint256 publicId) public view virtual override returns (string memory) {
        uint256 mintId = _requireValidPublicId(publicId);
        return super.tokenURI(mintId);
    }

    function approve(address to, uint256 publicId) public override(ERC721Upgradeable, IERC721) {
        uint256 mintId = _requireValidPublicId(publicId);
        super.approve(to, mintId);
        emit IERC721.Approval(_msgSender(), to, publicId);
    }

    function getApproved(uint256 publicId) public view override(ERC721Upgradeable, IERC721) returns (address) {
        uint256 mintId = _requireValidPublicId(publicId);
        return super.getApproved(mintId);
    }

    function transferFrom(address from, address to, uint256 publicId) public override(ERC721Upgradeable, IERC721) {
        uint256 mintId = _requireValidPublicId(publicId);
        super.transferFrom(from, to, mintId);
        emit IERC721.Transfer(from, to, publicId);
    }

    function safeTransferFrom(address from, address to, uint256 publicId, bytes memory data)
        public
        override(ERC721Upgradeable, IERC721)
    {
        transferFrom(from, to, publicId);
        _checkOnERC721Received(from, to, publicId, data);
    }

    function _safeMint(address to, uint256 publicId, bytes memory data) internal override {
        if (DynamicIds.getLast16Bytes(publicId) == 0) revert InvalidMintId(publicId);
        uint256 mintId = _requireValidPublicId(publicId);
        super._safeMint(to, mintId, data);
        emit IERC721.Transfer(address(0), to, publicId);
    }

    /*
     * ERC721UpgradeableEnumerable overrides.
     *
     * We override all public methods that take tokenId as a parameter or return tokenId.
     *
     * All internal transactions must receive mintId to work correctly.
     */

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        uint256 mintId = super.tokenOfOwnerByIndex(owner, index);

        return _getPublicId(mintId, _getPayload(mintId));
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        uint256 mintId = super.tokenByIndex(index);

        return _getPublicId(mintId, _getPayload(mintId));
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IMembership } from "src/types/IMembership.sol";
import { MembershipSVG } from "src/libraries/MembershipSVG.sol";

interface IMembershipDescriptor {
    /// @notice Generates the name of the membership.
    /// @param metadata Metadata of the membership.
    function name(IMembership.Metadata memory metadata) external view returns (string memory);

    /// @notice Generates the symbol of the membership.
    /// @param metadata Metadata of the membership.
    function symbol(IMembership.Metadata memory metadata) external view returns (string memory);

    /// @notice Generates encoded JSON metadata.
    /// @param start Date of the start.
    /// @param usage Usage of the membership.
    /// @param metadata Metadata of the membership.
    /// @param attributes Attributes of the membership.
    /// @return encoded JSON metadata in base64.
    function tokenURI(
        uint256 start,
        IMembership.Usage memory usage,
        IMembership.Metadata memory metadata,
        IMembership.Attributes memory attributes
    ) external view returns (string memory);
}

contract MembershipDescriptor is IMembershipDescriptor {
    using Strings for address;
    using Strings for uint32;
    using Strings for uint256;

    /// @inheritdoc IMembershipDescriptor
    function name(IMembership.Metadata memory metadata) public view returns (string memory) {
        string memory name_ = IERC20Metadata(address(metadata.token)).name();

        return string.concat(name_, " Vesting");
    }

    /// @inheritdoc IMembershipDescriptor
    function symbol(IMembership.Metadata memory metadata) public view returns (string memory) {
        string memory symbol_ = IERC20Metadata(address(metadata.token)).symbol();

        return string.concat("v", symbol_);
    }

    /// @inheritdoc IMembershipDescriptor
    function tokenURI(
        uint256 start,
        IMembership.Usage memory usage,
        IMembership.Metadata memory metadata,
        IMembership.Attributes memory attributes
    ) public view virtual returns (string memory) {
        string memory json = string.concat(
            '{"attributes":',
            _traits(start, usage, metadata, attributes),
            ',"description":"',
            metadata.description,
            '","name":"',
            _title(metadata),
            '","image":"',
            _image(usage, metadata),
            '"}'
        );

        return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
    }

    /// @notice Generates title for given membership.
    /// @param metadata Metadata of the membership.
    function _title(IMembership.Metadata memory metadata) internal view returns (string memory) {
        string memory symbol_ = IERC20Metadata(address(metadata.token)).symbol();

        return string.concat("Vesting of ", symbol_);
    }

    /// @notice Generates encoded image.
    /// @param usage Usage of the membership.
    /// @param metadata Metadata of the membership.
    /// @return encoded image.
    function _image(IMembership.Usage memory usage, IMembership.Metadata memory metadata)
        internal
        view
        returns (string memory)
    {
        uint256 denominator = 10 ** IERC20Metadata(address(metadata.token)).decimals();

        string memory svg = MembershipSVG.generate(
            MembershipSVG.Params({
                color: metadata.color,
                title: name(metadata),
                max: usage.max / denominator,
                current: usage.current / denominator
            })
        );

        return string.concat("data:image/svg+xml;base64,", Base64.encode(bytes(svg)));
    }

    /// @notice Generates traits metadata.
    /// @param start Date of the start.
    /// @param usage Usage of the membership.
    /// @param metadata Metadata of the membership.
    /// @return encoded image.
    function _traits(
        uint256 start,
        IMembership.Usage memory usage,
        IMembership.Metadata memory metadata,
        IMembership.Attributes memory attributes
    ) internal view returns (string memory) {
        uint256 denominator = 10 ** IERC20Metadata(address(metadata.token)).decimals();

        string memory traits0 = string.concat(
            '[{"trait_type":"Usage","display_type":"boost_percentage","value":',
            (usage.max > 0 ? usage.current * 100 / usage.max : 0).toString(),
            '},{"trait_type":"Vested tokens","display_type":"number","value":',
            Strings.toString(usage.max / denominator),
            '},{"trait_type":"Claimed tokens","display_type":"number","value":',
            Strings.toString(usage.current / denominator),
            '},{"trait_type":"TGE","display_type":"boost_percentage","value":',
            (attributes.tgeDenominator > 0 ? attributes.tgeNumerator * 100 / attributes.tgeDenominator : 0).toString(),
            '},{"trait_type":"Vesting start","display_type":"date","value":',
            start.toString(),
            '},{"trait_type":"Vesting end","display_type":"date","value":',
            (start + attributes.cliffDuration + (attributes.vestingPeriodCount * attributes.vestingPeriodDuration))
                .toString()
        );

        /// @dev split to avoid the stack too deep error
        string memory traits1 = string.concat(
            '},{"trait_type":"Cliff duration","value":"',
            _getCliffDurationText(attributes.cliffDuration),
            '"},{"trait_type":"Cliff unlock","display_type":"boost_percentage","value":',
            (attributes.cliffDenominator > 0 ? attributes.cliffNumerator * 100 / attributes.cliffDenominator : 0)
                .toString(),
            '},{"trait_type":"Unlock frequency","value":"',
            _getUnlockFrequencyText(attributes.vestingPeriodDuration),
            '"},{"trait_type":"Vested token name","value":"',
            IERC20Metadata(address(metadata.token)).name(),
            '"},{"trait_type":"Vested token symbol","value":"',
            IERC20Metadata(address(metadata.token)).symbol(),
            '"},{"trait_type":"Vested token address","value":"',
            Strings.toHexString(uint160(metadata.token), 20),
            '"}]'
        );

        return string.concat(traits0, traits1);
    }

    /// @notice Convert the cliff duration to human-readable value.
    /// @param value Value of the cliff duration.
    /// @return Human-readable value.
    function _getCliffDurationText(uint256 value) internal pure virtual returns (string memory) {
        if (value == 0) return "no cliff";

        (uint256 period, string memory label) = _humanize(value);

        return string.concat(period.toString(), " ", label);
    }

    /// @notice Convert the unlock frequency to human-readable value.
    /// @param value Value of the unlock frequency.
    /// @return Human-readable value.
    function _getUnlockFrequencyText(uint256 value) internal pure virtual returns (string memory) {
        if (value == 0) return "none";

        (uint256 period, string memory label) = _humanize(value);

        if (period == 1) return string.concat("every ", label);

        return string.concat("every ", period.toString(), " ", label);
    }

    /// @notice Convert the period to a human-readable value.
    /// @param value Period to humanize.
    /// @return Period in as text value.
    function _humanize(uint256 value) internal pure virtual returns (uint256, string memory) {
        if (value < 1 hours) return _pluralize(value / 1 minutes, "minute", "minutes");

        if (value < 1 days) return _pluralize(value / 1 hours, "hour", "hours");

        return _pluralize(value / 1 days, "day", "days");
    }

    /// @notice Returns a label based on the given value.
    /// @param value The value on which the selection of the label is based.
    /// @param singular Singular label.
    /// @param plural Plural label.
    /// @return Generated label.
    function _pluralize(uint256 value, string memory singular, string memory plural)
        internal
        pure
        virtual
        returns (uint256, string memory)
    {
        return (value, value == 1 ? singular : plural);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IPresale } from "src/types/IPresale.sol";
import { Fees } from "src/types/Fees.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { ERC165Upgradeable } from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

abstract contract NFTRoyalties is IERC2981, ERC165Upgradeable {
    IPresale internal presale;

    error InvalidPresale(address presale);

    constructor() {
        _disableInitializers();
    }

    function __NFTRoyalties_init(address presale_) internal onlyInitializing {
        presale = IPresale(presale_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256, uint256 salePrice) public view virtual returns (address, uint256) {
        Fees memory fees = presale.getFees();
        address feeCollector = presale.getFeeCollector();

        uint256 royaltyAmount = (salePrice * fees.nftFeeNumerator) / fees.nftFeeDenominator;

        return (feeCollector, royaltyAmount);
    }
}