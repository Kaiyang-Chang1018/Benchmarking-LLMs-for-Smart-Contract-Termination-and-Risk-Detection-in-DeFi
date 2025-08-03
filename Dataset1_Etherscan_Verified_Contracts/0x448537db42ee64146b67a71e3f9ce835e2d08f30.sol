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
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
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
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
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
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
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
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
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
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
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
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

pragma solidity ^0.8.20;

import {Errors} from "./Errors.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

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
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/Hashes.sol)

pragma solidity ^0.8.20;

/**
 * @dev Library of standard hash functions.
 *
 * _Available since v5.1._
 */
library Hashes {
    /**
     * @dev Commutative Keccak256 hash of a sorted pair of bytes32. Frequently used when working with merkle proofs.
     *
     * NOTE: Equivalent to the `standardNodeHash` in our https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
     */
    function commutativeKeccak256(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? _efficientKeccak256(a, b) : _efficientKeccak256(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientKeccak256(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly ("memory-safe") {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/MerkleProof.sol)
// This file was procedurally generated from scripts/generate/templates/MerkleProof.js.

pragma solidity ^0.8.20;

import {Hashes} from "./Hashes.sol";

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 *
 * IMPORTANT: Consider memory side-effects when using custom hashing functions
 * that access memory in an unsafe way.
 *
 * NOTE: This library supports proof verification for merkle trees built using
 * custom _commutative_ hashing functions (i.e. `H(a, b) == H(b, a)`). Proving
 * leaf inclusion in trees built using non-commutative hashing functions requires
 * additional logic that is not supported by this library.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with the default hashing function.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with the default hashing function.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = Hashes.commutativeKeccak256(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with a custom hashing function.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processProof(proof, leaf, hasher) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with a custom hashing function.
     */
    function processProof(
        bytes32[] memory proof,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = hasher(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with the default hashing function.
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with the default hashing function.
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = Hashes.commutativeKeccak256(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with a custom hashing function.
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processProofCalldata(proof, leaf, hasher) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with a custom hashing function.
     */
    function processProofCalldata(
        bytes32[] calldata proof,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = hasher(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in memory with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProof}.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in memory with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = Hashes.commutativeKeccak256(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in memory with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProof}.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processMultiProof(proof, proofFlags, leaves, hasher) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in memory with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = hasher(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in calldata with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProofCalldata}.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in calldata with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = Hashes.commutativeKeccak256(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in calldata with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProofCalldata}.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves, hasher) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in calldata with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = hasher(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * ██      ███████  ██████  ██  ██████  ███    ██
 * ██      ██      ██       ██ ██    ██ ████   ██
 * ██      █████   ██   ███ ██ ██    ██ ██ ██  ██
 * ██      ██      ██    ██ ██ ██    ██ ██  ██ ██
 * ███████ ███████  ██████  ██  ██████  ██   ████
 *
 * If you find a bug, please contact security(at)legion.cc
 * We will pay a fair bounty for any issue that puts user's funds at risk.
 *
 */
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ILegionAddressRegistry} from "./interfaces/ILegionAddressRegistry.sol";
import {ILegionPreLiquidSale} from "./interfaces/ILegionPreLiquidSale.sol";
import {ILegionLinearVesting} from "./interfaces/ILegionLinearVesting.sol";
import {ILegionVestingFactory} from "./interfaces/ILegionVestingFactory.sol";

/**
 * @title Legion Pre-Liquid Sale.
 * @author Legion.
 * @notice A contract used to execute pre-liquid sales of ERC20 tokens before TGE.
 */
contract LegionPreLiquidSale is ILegionPreLiquidSale, Initializable {
    using SafeERC20 for IERC20;

    /// @dev The refund period duration in seconds.
    uint256 private refundPeriodSeconds;

    /// @dev The vesting schedule duration for the token sold in seconds.
    uint256 private vestingDurationSeconds;

    /// @dev The vesting cliff duration for the token sold in seconds.
    uint256 private vestingCliffDurationSeconds;

    /// @dev The token allocation amount released to investors after TGE with 18 decimals precision.
    uint256 private tokenAllocationOnTGERate;

    /// @dev Legion's fee on capital raised in BPS (Basis Points).
    uint256 private legionFeeOnCapitalRaisedBps;

    /// @dev Legion's fee on tokens sold in BPS (Basis Points).
    uint256 private legionFeeOnTokensSoldBps;

    /// @dev The merkle root for verification of token distribution amounts.
    bytes32 private saftMerkleRoot;

    /// @dev The address of the token used for raising capital.
    address private bidToken;

    /// @dev The admin address of the project raising capital.
    address private projectAdmin;

    /// @dev The address of Legion's Address Registry contract.
    address private addressRegistry;

    /// @dev The admin address of Legion.
    address private legionBouncer;

    /// @dev The address of Legion fee receiver.
    address private legionFeeReceiver;

    /// @dev The address of Legion's Vesting Factory contract.
    address private vestingFactory;

    /// @dev The address of the token being sold to investors.
    address private askToken;

    /// @dev The unix timestamp (seconds) of the block when the vesting starts.
    uint256 private vestingStartTime;

    /// @dev The total supply of the ask token
    uint256 private askTokenTotalSupply;

    /// @dev The total capital invested by investors.
    uint256 private totalCapitalInvested;

    /// @dev The total amount of tokens allocated to investors.
    uint256 private totalTokensAllocated;

    /// @dev The total capital withdrawn by the Project, from the sale.
    uint256 private totalCapitalWithdrawn;

    /// @dev Whether the sale has been canceled or not.
    bool private isCanceled;

    /// @dev Whether the ask tokens have been supplied to the sale.
    bool private askTokensSupplied;

    /// @dev Whether investment is being accepted by the Project.
    bool private investmentAccepted;

    /// @dev Mapping of investor address to investor position.
    mapping(address investorAddress => InvestorPosition investorPosition) public investorPositions;

    /// @dev Constant representing 2 weeks in seconds.
    uint256 private constant TWO_WEEKS = 1209600;

    /// @dev Constant representing the LEGION_BOUNCER unique ID
    bytes32 private constant LEGION_BOUNCER_ID = bytes32("LEGION_BOUNCER");

    /// @dev Constant representing the LEGION_FEE_RECEIVER unique ID
    bytes32 private constant LEGION_FEE_RECEIVER_ID = bytes32("LEGION_FEE_RECEIVER");

    /// @dev Constant representing the LEGION_VESTING_FACTORY unique ID
    bytes32 private constant LEGION_VESTING_FACTORY_ID = bytes32("LEGION_VESTING_FACTORY");

    /**
     * @notice Throws if called by any account other than Legion.
     */
    modifier onlyLegion() {
        if (msg.sender != legionBouncer) revert NotCalledByLegion();
        _;
    }

    /**
     * @notice Throws if called by any account other than the Project.
     */
    modifier onlyProject() {
        if (msg.sender != projectAdmin) revert NotCalledByProject();
        _;
    }

    /**
     * @notice LegionPreLiquidSale constructor.
     */
    constructor() {
        /// Disable initialization
        _disableInitializers();
    }

    /**
     * @notice See {ILegionPreLiquidSale-initialize}.
     */
    function initialize(PreLiquidSaleConfig calldata preLiquidSaleConfig) external initializer {
        /// Initialize pre-liquid sale configuration
        refundPeriodSeconds = preLiquidSaleConfig.refundPeriodSeconds;
        vestingDurationSeconds = preLiquidSaleConfig.vestingDurationSeconds;
        vestingCliffDurationSeconds = preLiquidSaleConfig.vestingCliffDurationSeconds;
        tokenAllocationOnTGERate = preLiquidSaleConfig.tokenAllocationOnTGERate;
        legionFeeOnCapitalRaisedBps = preLiquidSaleConfig.legionFeeOnCapitalRaisedBps;
        legionFeeOnTokensSoldBps = preLiquidSaleConfig.legionFeeOnTokensSoldBps;
        saftMerkleRoot = preLiquidSaleConfig.saftMerkleRoot;
        bidToken = preLiquidSaleConfig.bidToken;
        projectAdmin = preLiquidSaleConfig.projectAdmin;
        addressRegistry = preLiquidSaleConfig.addressRegistry;

        /// Accepting investment is set to true by default
        investmentAccepted = true;

        /// Verify if the sale configuration is valid
        _verifyValidConfig(preLiquidSaleConfig);

        /// Cache Legion addresses from `LegionAddressRegistry`
        legionBouncer = ILegionAddressRegistry(addressRegistry).getLegionAddress(LEGION_BOUNCER_ID);
        legionFeeReceiver = ILegionAddressRegistry(addressRegistry).getLegionAddress(LEGION_FEE_RECEIVER_ID);
        vestingFactory = ILegionAddressRegistry(addressRegistry).getLegionAddress(LEGION_VESTING_FACTORY_ID);
    }

    /**
     * @notice See {ILegionPreLiquidSale-invest}.
     */
    function invest(
        uint256 amount,
        uint256 saftInvestAmount,
        uint256 tokenAllocationRate,
        bytes32 saftHash,
        bytes32[] calldata proof
    ) external {
        /// Verify that the sale is not canceled
        _verifySaleNotCanceled();

        /// Verify that investment is accepted by the Project
        _verifyInvestmentAccepted();

        /// Load the investor position
        InvestorPosition storage position = investorPositions[msg.sender];

        /// Increment total capital invested from investors
        totalCapitalInvested += amount;

        /// Increment total capital for the investor
        position.investedCapital += amount;

        // Cache the capital invest timestamp
        if (position.cachedInvestTimestamp == 0) {
            position.cachedInvestTimestamp = block.timestamp;
        }

        /// Cache the SAFT amount the investor is allowed to invest
        if (position.cachedSAFTInvestAmount != saftInvestAmount) {
            position.cachedSAFTInvestAmount = saftInvestAmount;
        }

        /// Cache the token allocation rate in 18 decimals precision
        if (position.cachedTokenAllocationRate != tokenAllocationRate) {
            position.cachedTokenAllocationRate = tokenAllocationRate;
        }

        /// Cache the hash of the SAFT signed by the investor
        if (position.cachedSAFTHash != saftHash) {
            position.cachedSAFTHash = saftHash;
        }

        /// Verify that the investor position is valid
        _verifyValidPosition(msg.sender, proof);

        /// Emit successfully CapitalInvested
        emit CapitalInvested(amount, msg.sender, tokenAllocationRate, saftHash, block.timestamp);

        /// Transfer the invested capital to the contract
        IERC20(bidToken).safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice See {ILegionPreLiquidSale-refund}.
     */
    function refund() external {
        /// Verify that the sale is not canceled
        _verifySaleNotCanceled();

        /// Verify that the investor can get a refund
        _verifyRefundPeriodIsNotOver(msg.sender);

        /// Load the investor position
        InvestorPosition storage position = investorPositions[msg.sender];

        /// Cache the amount to refund in memory
        uint256 amountToRefund = position.investedCapital;

        /// Revert in case there's nothing to refund
        if (amountToRefund == 0) revert InvalidRefundAmount();

        /// Set the total invested capital for the investor to 0
        position.investedCapital = 0;

        /// Decrement total capital invested from investors
        totalCapitalInvested -= amountToRefund;

        /// Emit successfully CapitalRefunded
        emit CapitalRefunded(amountToRefund, msg.sender);

        /// Transfer the refunded amount back to the investor
        IERC20(bidToken).safeTransfer(msg.sender, amountToRefund);
    }

    /**
     * @notice See {ILegionPreLiquidSale-setTokenDetails}.
     */
    function publishTgeDetails(
        address _askToken,
        uint256 _askTokenTotalSupply,
        uint256 _vestingStartTime,
        uint256 _totalTokensAllocated
    ) external onlyLegion {
        /// Verify that the sale has not been canceled
        _verifySaleNotCanceled();

        /// Set the address of the token ditributed to investors
        askToken = _askToken;

        /// Set the total supply of the token distributed to investors
        askTokenTotalSupply = _askTokenTotalSupply;

        /// Set the vesting start time block timestamp
        vestingStartTime = _vestingStartTime;

        /// Set the total allocated amount of token for distribution.
        totalTokensAllocated = _totalTokensAllocated;

        /// Set `investmentAccepted` status to false
        if (investmentAccepted) investmentAccepted = false;

        /// Emit successfully TgeDetailsPublished
        emit TgeDetailsPublished(_askToken, _askTokenTotalSupply, _vestingStartTime, _totalTokensAllocated);
    }

    /**
     * @notice See {ILegionPreLiquidSale-supplyTokens}.
     */
    function supplyAskTokens(uint256 amount, uint256 legionFee) external onlyProject {
        /// Verify that the sale is not canceled
        _verifySaleNotCanceled();

        /// Verify that tokens can be supplied for distribution
        _verifyCanSupplyTokens(amount);

        /// Calculate and verify Legion Fee
        if (legionFee != (legionFeeOnTokensSoldBps * amount) / 10000) revert InvalidFeeAmount();

        /// Flag that ask tokens have been supplied
        askTokensSupplied = true;

        /// Emit successfully TokensSuppliedForDistribution
        emit TokensSuppliedForDistribution(amount, legionFee);

        /// Transfer the allocated amount of tokens for distribution
        IERC20(askToken).safeTransferFrom(msg.sender, address(this), amount);

        /// Transfer the Legion fee to the Legion fee receiver address
        if (legionFee != 0) IERC20(askToken).safeTransferFrom(msg.sender, legionFeeReceiver, legionFee);
    }

    /**
     * @notice See {ILegionPreLiquidSale-updateSAFTMerkleRoot}.
     */
    function updateSAFTMerkleRoot(bytes32 merkleRoot) external onlyLegion {
        /// Verify that the sale is not canceled
        _verifySaleNotCanceled();

        /// Verify that tokens for distribution have not been allocated
        _verifyTokensNotAllocated();

        /// Set the new SAFT merkle root
        saftMerkleRoot = merkleRoot;

        /// Emit successfully SAFTMerkleRootUpdated
        emit SAFTMerkleRootUpdated(merkleRoot);
    }

    /**
     * @notice See {ILegionPreLiquidSale-updateVestingTerms}.
     */
    function updateVestingTerms(
        uint256 _vestingDurationSeconds,
        uint256 _vestingCliffDurationSeconds,
        uint256 _tokenAllocationOnTGERate
    ) external onlyProject {
        /// Verify that the sale is not canceled
        _verifySaleNotCanceled();

        /// Verify that the project has not withdrawn any capital
        _verifyNoCapitalWithdrawn();

        /// Verify that tokens for distribution have not been allocated
        _verifyTokensNotAllocated();

        /// Set the vesting duration in seconds
        vestingDurationSeconds = _vestingDurationSeconds;

        /// Set the vesting cliff duraation in seconds
        vestingCliffDurationSeconds = _vestingCliffDurationSeconds;

        /// Set the token allocation on TGE
        tokenAllocationOnTGERate = _tokenAllocationOnTGERate;

        /// Emit successfully VestingTermsUpdated
        emit VestingTermsUpdated(_vestingDurationSeconds, _vestingCliffDurationSeconds, _tokenAllocationOnTGERate);
    }

    /**
     * @notice See {ILegionPreLiquidSale-emergencyWithdraw}.
     */
    function emergencyWithdraw(address receiver, address token, uint256 amount) external onlyLegion {
        /// Emit successfully EmergencyWithdraw
        emit EmergencyWithdraw(receiver, token, amount);

        /// Transfer the amount to Legion's address
        IERC20(token).safeTransfer(receiver, amount);
    }

    /**
     * @notice See {ILegionPreLiquidSale-withdrawCapital}.
     */
    function withdrawRaisedCapital(address[] calldata investors) external onlyProject returns (uint256 amount) {
        /// Verify that the sale is not canceled
        _verifySaleNotCanceled();

        /// Loop through the investors positions
        for (uint256 i = 0; i < investors.length; ++i) {
            /// Verify that the refund period is over for the specified position
            _verifyRefundPeriodIsOver(investors[i]);

            /// Verify that the investor has actually invested capital
            _verifyCanWithdrawInvestorPosition(investors[i]);

            /// Load the investor position
            InvestorPosition storage position = investorPositions[investors[i]];

            /// Get the outstanding capital to be withdrawn
            uint256 currentAmount = position.investedCapital - position.withdrawnCapital;

            /// Mark the amount of capital withdrawn
            position.withdrawnCapital += currentAmount;

            /// Increment the total amount to be withdrawn
            amount += currentAmount;
        }

        /// Account for the capital withdrawn
        totalCapitalWithdrawn += amount;

        /// Calculate Legion Fee
        uint256 legionFee = (legionFeeOnCapitalRaisedBps * amount) / 10000;

        /// Emit successfully CapitalWithdrawn
        emit CapitalWithdrawn(amount);

        /// Transfer the amount to the Project's address
        IERC20(bidToken).safeTransfer(msg.sender, (amount - legionFee));

        /// Transfer the Legion fee to the Legion fee receiver address
        if (legionFee != 0) IERC20(bidToken).safeTransfer(legionFeeReceiver, legionFee);
    }

    /**
     * @notice See {ILegionPreLiquidSale-claimTokenAllocation}.
     */
    function claimAskTokenAllocation(bytes32[] calldata proof) external {
        /// Verify that the sale has not been canceled
        _verifySaleNotCanceled();

        /// Verify that the investor can claim the token allocation
        _verifyCanClaimTokenAllocation(msg.sender);

        /// Verify that the investor position is valid
        _verifyValidPosition(msg.sender, proof);

        /// Load the investor position
        InvestorPosition storage position = investorPositions[msg.sender];

        /// Calculate the total token amount to be claimed
        uint256 totalAmount = askTokenTotalSupply * position.cachedTokenAllocationRate / 1e18;

        /// Calculate the amount to be distributed on claim
        uint256 amountToDistributeOnClaim = totalAmount * tokenAllocationOnTGERate / 1e18;

        /// Calculate the remaining amount to be vested
        uint256 amountToBeVested = totalAmount - amountToDistributeOnClaim;

        /// Deploy a linear vesting schedule contract
        address payable vestingAddress = _createVesting(
            msg.sender, uint64(vestingStartTime), uint64(vestingDurationSeconds), uint64(vestingCliffDurationSeconds)
        );

        /// Save the vesting address for the investor
        position.vestingAddress = vestingAddress;

        /// Mark that the token amount has been settled
        position.hasSettled = true;

        /// Emit successfully TokenAllocationClaimed
        emit TokenAllocationClaimed(amountToBeVested, amountToDistributeOnClaim, msg.sender, vestingAddress);

        /// Transfer the allocated amount of tokens for distribution
        IERC20(askToken).safeTransfer(vestingAddress, amountToBeVested);

        if (amountToDistributeOnClaim != 0) {
            /// Transfer the allocated amount of tokens for distribution on claim
            IERC20(askToken).safeTransfer(msg.sender, amountToDistributeOnClaim);
        }
    }

    /**
     * @notice See {ILegionPreLiquidSale-cancelSale}.
     */
    function cancelSale() external onlyProject {
        /// Verify that the sale has not been canceled
        _verifySaleNotCanceled();

        /// Verify that no tokens have been supplied to the sale by the Project
        _verifyAskTokensNotSupplied();

        /// Cache the amount of funds to be returned to the sale
        uint256 capitalToReturn = totalCapitalWithdrawn;

        /// Mark the sale as canceled
        isCanceled = true;

        /// Emit successfully CapitalWithdrawn
        emit SaleCanceled();

        /// In case there's capital to return, transfer the funds back to the contract
        if (capitalToReturn > 0) {
            /// Set the totalCapitalWithdrawn to zero
            totalCapitalWithdrawn = 0;
            /// Transfer the allocated amount of tokens for distribution
            IERC20(bidToken).safeTransferFrom(msg.sender, address(this), capitalToReturn);
        }
    }

    /**
     * @notice See {ILegionPreLiquidSale-claimBackCapitalIfSaleIsCanceled}.
     */
    function withdrawCapitalIfSaleIsCanceled() external {
        /// Verify that the sale has been actually canceled
        _verifySaleIsCanceled();

        /// Cache the amount to refund in memory
        uint256 amountToClaim = investorPositions[msg.sender].investedCapital;

        /// Revert in case there's nothing to claim
        if (amountToClaim == 0) revert InvalidClaimAmount();

        /// Set the total pledged capital for the investor to 0
        investorPositions[msg.sender].investedCapital = 0;

        /// Decrement total capital pledged from investors
        totalCapitalInvested -= amountToClaim;

        /// Emit successfully CapitalRefundedAfterCancel
        emit CapitalRefundedAfterCancel(amountToClaim, msg.sender);

        /// Transfer the refunded amount back to the investor
        IERC20(bidToken).safeTransfer(msg.sender, amountToClaim);
    }

    /**
     * @notice See {ILegionPreLiquidSale-withdrawExcessCapital}.
     */
    function withdrawExcessCapital(
        uint256 amount,
        uint256 saftInvestAmount,
        uint256 tokenAllocationRate,
        bytes32 saftHash,
        bytes32[] calldata proof
    ) external {
        /// Verify that the sale has not been canceled
        _verifySaleNotCanceled();

        /// Load the investor position
        InvestorPosition storage position = investorPositions[msg.sender];

        /// Decrement total capital invested from investors
        totalCapitalInvested -= amount;

        /// Decrement total investor capital for the investor
        position.investedCapital -= amount;

        /// Cache the maximum amount the investor is allowed to invest
        if (position.cachedSAFTInvestAmount != saftInvestAmount) {
            position.cachedSAFTInvestAmount = saftInvestAmount;
        }

        /// Cache the token allocation rate in 18 decimals precision
        if (position.cachedTokenAllocationRate != tokenAllocationRate) {
            position.cachedTokenAllocationRate = tokenAllocationRate;
        }

        /// Cache the hash of the SAFT signed by the investor
        if (position.cachedSAFTHash != saftHash) {
            position.cachedSAFTHash = saftHash;
        }

        /// Verify that the investor position is valid
        _verifyValidPosition(msg.sender, proof);

        /// Emit successfully ExcessCapitalWithdrawn
        emit ExcessCapitalWithdrawn(amount, msg.sender, tokenAllocationRate, saftHash, block.timestamp);

        /// Transfer the excess capital to the investor
        IERC20(bidToken).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice See {ILegionPreLiquidSale-releaseTokens}.
     */
    function releaseTokens() external {
        /// Get the investor position details
        InvestorPosition memory position = investorPositions[msg.sender];

        /// Revert in case there's no vesting for the investor
        if (position.vestingAddress == address(0)) revert ZeroAddressProvided();

        /// Release tokens to the investor account
        ILegionLinearVesting(position.vestingAddress).release(askToken);
    }

    /**
     * @notice See {ILegionPreLiquidSale-toggleInvestmentAccepted}.
     */
    function toggleInvestmentAccepted() external onlyProject {
        /// Verify that tokens for distribution have not been allocated
        _verifyTokensNotAllocated();

        /// Update the `investmentAccepted` status
        investmentAccepted = !investmentAccepted;

        /// Emit successfully ToggleInvestmentAccepted
        emit ToggleInvestmentAccepted(investmentAccepted);
    }

    /**
     * @notice See {ILegionPreLiquidSale-syncLegionAddresses}.
     */
    function syncLegionAddresses() external onlyLegion {
        /// Cache Legion addresses from `LegionAddressRegistry`
        legionBouncer = ILegionAddressRegistry(addressRegistry).getLegionAddress(LEGION_BOUNCER_ID);
        legionFeeReceiver = ILegionAddressRegistry(addressRegistry).getLegionAddress(LEGION_FEE_RECEIVER_ID);
        vestingFactory = ILegionAddressRegistry(addressRegistry).getLegionAddress(LEGION_VESTING_FACTORY_ID);

        /// Emit successfully LegionAddressesSynced
        emit LegionAddressesSynced(legionBouncer, legionFeeReceiver, vestingFactory);
    }

    /**
     * @notice See {ILegionPreLiquidSale-saleConfig}.
     */
    function saleConfig() external view returns (PreLiquidSaleConfig memory preLiquidSaleConfig) {
        /// Get the pre-liquid sale config
        preLiquidSaleConfig = PreLiquidSaleConfig(
            refundPeriodSeconds,
            vestingDurationSeconds,
            vestingCliffDurationSeconds,
            tokenAllocationOnTGERate,
            legionFeeOnCapitalRaisedBps,
            legionFeeOnTokensSoldBps,
            saftMerkleRoot,
            bidToken,
            projectAdmin,
            addressRegistry
        );
    }

    /**
     * @notice See {ILegionPreLiquidSale-saleStatus}.
     */
    function saleStatus() external view returns (PreLiquidSaleStatus memory preLiquidSaleStatus) {
        /// Get the pre-liquid sale status
        preLiquidSaleStatus = PreLiquidSaleStatus(
            askToken,
            vestingStartTime,
            askTokenTotalSupply,
            totalCapitalInvested,
            totalTokensAllocated,
            totalCapitalWithdrawn,
            isCanceled,
            askTokensSupplied,
            investmentAccepted
        );
    }

    /**
     * @notice Create a vesting schedule contract.
     *
     * @param _beneficiary The beneficiary.
     * @param _startTimestamp The start timestamp.
     * @param _durationSeconds The duration in seconds.
     * @param _cliffDurationSeconds The cliff duration in seconds.
     *
     * @return vestingInstance The address of the deployed vesting instance.
     */
    function _createVesting(
        address _beneficiary,
        uint64 _startTimestamp,
        uint64 _durationSeconds,
        uint64 _cliffDurationSeconds
    ) internal returns (address payable vestingInstance) {
        /// Deploy a vesting schedule instance
        vestingInstance = ILegionVestingFactory(vestingFactory).createLinearVesting(
            _beneficiary, _startTimestamp, _durationSeconds, _cliffDurationSeconds
        );
    }

    /**
     * @notice Verify if the sale configuration is valid.
     *
     * @param _preLiquidSaleConfig The configuration for the pre-liquid sale.
     */
    function _verifyValidConfig(PreLiquidSaleConfig calldata _preLiquidSaleConfig) private pure {
        /// Check for zero addresses provided
        if (
            _preLiquidSaleConfig.bidToken == address(0) || _preLiquidSaleConfig.projectAdmin == address(0)
                || _preLiquidSaleConfig.addressRegistry == address(0)
        ) revert ZeroAddressProvided();

        /// Check for zero values provided
        if (_preLiquidSaleConfig.refundPeriodSeconds == 0) {
            revert ZeroValueProvided();
        }

        /// Check if prefund, allocation, sale, refund and lockup periods are within range
        if (_preLiquidSaleConfig.refundPeriodSeconds > TWO_WEEKS) revert InvalidPeriodConfig();
    }

    function _verifyCanWithdrawInvestorPosition(address _investor) private view {
        /// Load the investor position
        InvestorPosition memory position = investorPositions[_investor];

        /// Check if the investor has invested capital
        if (position.investedCapital == 0) revert CapitalNotInvested(_investor);

        /// Check if the capital has not been already withdrawn by the Project
        if (position.withdrawnCapital == position.investedCapital) revert CapitalAlreadyWithdrawn(_investor);
    }

    /**
     * @notice Verify that the refund period is not over.
     *
     * @param _investor The address of the investor
     */
    function _verifyRefundPeriodIsNotOver(address _investor) private view {
        /// Load the investor position
        InvestorPosition memory position = investorPositions[_investor];

        /// Check if the refund period is over
        if (block.timestamp > position.cachedInvestTimestamp + refundPeriodSeconds) revert RefundPeriodIsOver();
    }

    /**
     * @notice Verify that the refund period is over.
     *
     * @param _investor The address of the investor
     */
    function _verifyRefundPeriodIsOver(address _investor) private view {
        /// Load the investor position
        InvestorPosition memory position = investorPositions[_investor];

        /// Check if the refund period is not over
        if (block.timestamp <= position.cachedInvestTimestamp + refundPeriodSeconds) revert RefundPeriodIsNotOver();
    }

    /**
     * @notice Verify if the project can supply tokens for distribution.
     *
     * @param _amount The amount to supply.
     */
    function _verifyCanSupplyTokens(uint256 _amount) private view {
        /// Revert if Legion has not set the total amount of tokens allocated for distribution
        if (totalTokensAllocated == 0) revert TokensNotAllocated();

        /// Revert if tokens have already been supplied
        if (askTokensSupplied) revert TokensAlreadySupplied();

        /// Revert if the amount of tokens supplied is different than the amount set by Legion
        if (_amount != totalTokensAllocated) revert InvalidTokenAmountSupplied(_amount);
    }

    /**
     * @notice Verify if the tokens for distribution have not been allocated.
     */
    function _verifyTokensNotAllocated() private view {
        /// Revert if the tokens for distribution have already been allocated
        if (totalTokensAllocated > 0) revert TokensAlreadyAllocated();
    }

    /**
     * @notice Verify that the sale is not canceled.
     */
    function _verifySaleNotCanceled() internal view {
        if (isCanceled) revert SaleIsCanceled();
    }

    /**
     * @notice Verify that the sale is canceled.
     */
    function _verifySaleIsCanceled() internal view {
        if (!isCanceled) revert SaleIsNotCanceled();
    }

    /**
     * @notice Verify that the Project has not withdrawn any capital.
     */
    function _verifyNoCapitalWithdrawn() internal view {
        if (totalCapitalWithdrawn > 0) revert ProjectHasWithdrawnCapital();
    }

    /**
     * @notice Verify if an investor is eligible to claim token allocation.
     *
     * @param _investor The address of the investor.
     */
    function _verifyCanClaimTokenAllocation(address _investor) internal view {
        /// Load the investor position
        InvestorPosition memory position = investorPositions[_investor];

        /// Check if the askToken has been supplied to the sale
        if (!askTokensSupplied) revert AskTokensNotSupplied();

        /// Check if the investor has already settled their allocation
        if (position.hasSettled) revert AlreadySettled(_investor);

        /// Check if the investor has invested capital
        if (position.investedCapital == 0) revert CapitalNotInvested(msg.sender);
    }

    /**
     * @notice Verify that the Project has not accepted the investment round.
     */
    function _verifyInvestmentAccepted() internal view {
        /// Check if investment is accepted by the Project
        if (!investmentAccepted) revert InvestmentNotAccepted();
    }

    /**
     * @notice Verify that the project has not supplied ask tokens to the sale.
     */
    function _verifyAskTokensNotSupplied() internal view virtual {
        if (askTokensSupplied) revert TokensAlreadySupplied();
    }

    /**
     * @notice Verify if the investor position is valid
     *
     * @param _investor The address of the investor.
     * @param _proof The merkle proof that the investor is part of the whitelist
     */
    function _verifyValidPosition(address _investor, bytes32[] calldata _proof) internal view {
        /// Load the investor position
        InvestorPosition memory position = investorPositions[_investor];

        /// Generate the merkle leaf
        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        _investor,
                        position.cachedSAFTInvestAmount,
                        position.cachedTokenAllocationRate,
                        position.cachedSAFTHash
                    )
                )
            )
        );

        /// Verify that the amount invested is equal to the SAFT amount
        if (position.investedCapital != position.cachedSAFTInvestAmount) {
            revert InvalidPositionAmount(_investor);
        }

        /// Verify the merkle proof
        if (!MerkleProof.verify(_proof, saftMerkleRoot, leaf)) revert InvalidProof(_investor);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * ██      ███████  ██████  ██  ██████  ███    ██
 * ██      ██      ██       ██ ██    ██ ████   ██
 * ██      █████   ██   ███ ██ ██    ██ ██ ██  ██
 * ██      ██      ██    ██ ██ ██    ██ ██  ██ ██
 * ███████ ███████  ██████  ██  ██████  ██   ████
 *
 * If you find a bug, please contact security(at)legion.cc
 * We will pay a fair bounty for any issue that puts user's funds at risk.
 *
 */
interface ILegionAddressRegistry {
    /**
     * @notice This event is emitted when a new Legion address is set or updated.
     *
     * @param id The unique identifier of the address.
     * @param previousAddress The previous address before the update.
     * @param updatedAddress The updated address.
     */
    event LegionAddressSet(bytes32 id, address previousAddress, address updatedAddress);

    /**
     * @notice Sets a Legion address.
     *
     * @param id The unique identifier of the address.
     * @param updatedAddress The updated address.
     */
    function setLegionAddress(bytes32 id, address updatedAddress) external;

    /**
     * @notice Gets a Legion address.
     *
     * @param id The unique identifier of the address.
     *
     * @return The requested address.
     */
    function getLegionAddress(bytes32 id) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * ██      ███████  ██████  ██  ██████  ███    ██
 * ██      ██      ██       ██ ██    ██ ████   ██
 * ██      █████   ██   ███ ██ ██    ██ ██ ██  ██
 * ██      ██      ██    ██ ██ ██    ██ ██  ██ ██
 * ███████ ███████  ██████  ██  ██████  ██   ████
 *
 * If you find a bug, please contact security(at)legion.cc
 * We will pay a fair bounty for any issue that puts user's funds at risk.
 *
 */
interface ILegionLinearVesting {
    /**
     * @notice See {VestingWalletUpgradeable-start}.
     */
    function start() external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-duration}.
     */
    function duration() external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-end}.
     */
    function end() external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-released}.
     */
    function released() external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-released}.
     */
    function released(address token) external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-releasable}.
     */
    function releasable() external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-releasable}.
     */
    function releasable(address token) external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-release}.
     */
    function release() external;

    /**
     * @notice See {VestingWalletUpgradeable-release}.
     */
    function release(address token) external;

    /**
     * @notice See {VestingWalletUpgradeable-vestedAmount}.
     */
    function vestedAmount(uint64 timestamp) external view returns (uint256);

    /**
     * @notice See {VestingWalletUpgradeable-vestedAmount}.
     */
    function vestedAmount(address token, uint64 timestamp) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * ██      ███████  ██████  ██  ██████  ███    ██
 * ██      ██      ██       ██ ██    ██ ████   ██
 * ██      █████   ██   ███ ██ ██    ██ ██ ██  ██
 * ██      ██      ██    ██ ██ ██    ██ ██  ██ ██
 * ███████ ███████  ██████  ██  ██████  ██   ████
 *
 * If you find a bug, please contact security(at)legion.cc
 * We will pay a fair bounty for any issue that puts user's funds at risk.
 *
 */
interface ILegionPreLiquidSale {
    /**
     * @notice This event is emitted when capital is successfully invested.
     *
     * @param amount The amount of capital invested.
     * @param investor The address of the investor.
     * @param tokenAllocationRate The token allocation the investor will receive as percentage of totalSupply, represented in 18 decimals precision.
     * @param saftHash The hash of the SAFT signed by the investor
     * @param investTimestamp The unix timestamp (seconds) of the block when capital has been invested.
     */
    event CapitalInvested(
        uint256 amount, address investor, uint256 tokenAllocationRate, bytes32 saftHash, uint256 investTimestamp
    );

    /**
     * @notice This event is emitted when excess capital is successfully withdrawn.
     *
     * @param amount The amount of capital withdrawn.
     * @param investor The address of the investor.
     * @param tokenAllocationRate The token allocation the investor will receive as percentage of totalSupply, represented in 18 decimals precision.
     * @param saftHash The hash of the SAFT signed by the investor
     * @param investTimestamp The unix timestamp (seconds) of the block when capital has been invested.
     */
    event ExcessCapitalWithdrawn(
        uint256 amount, address investor, uint256 tokenAllocationRate, bytes32 saftHash, uint256 investTimestamp
    );

    /**
     * @notice This event is emitted when capital is successfully refunded to the investor.
     *
     * @param amount The amount of capital refunded to the investor.
     * @param investor The address of the investor who requested the refund.
     */
    event CapitalRefunded(uint256 amount, address investor);

    /**
     * @notice This event is emitted when capital is successfully refunded to the investor after a sale has been canceled.
     *
     * @param amount The amount of capital refunded to the investor.
     * @param investor The address of the investor who requested the refund.
     */
    event CapitalRefundedAfterCancel(uint256 amount, address investor);

    /**
     * @notice This event is emitted when capital is successfully withdrawn by the Project.
     *
     * @param amount The amount of capital withdrawn by the project.
     */
    event CapitalWithdrawn(uint256 amount);

    /**
     * @notice This event is emitted when excess capital results are successfully published by the Legion admin.
     *
     * @param receiver The address of the receiver.
     * @param token The address of the token to be withdrawn.
     * @param amount The amount to be withdrawn.
     */
    event EmergencyWithdraw(address receiver, address token, uint256 amount);

    /**
     * @notice This event is emitted when excess capital results are successfully published by the Legion admin.
     *
     * @param legionBouncer The updated Legion bouncer address.
     * @param legionFeeReceiver The updated fee receiver address of Legion.
     * @param vestingFactory The updated vesting factory address.
     */
    event LegionAddressesSynced(address legionBouncer, address legionFeeReceiver, address vestingFactory);

    /**
     * @notice This event is emitted when the SAFT merkle root is updated by the Legion admin.
     *
     * @param merkleRoot The new SAFT merkle root.
     */
    event SAFTMerkleRootUpdated(bytes32 merkleRoot);

    /**
     * @notice This event is emitted when a sale is successfully canceled.
     */
    event SaleCanceled();

    /**
     * @notice This event is emitted when the token details have been set by the Legion admin.
     *
     * @param tokenAddress The address of the token distributed to investors
     * @param totalSupply The total supply of the token distributed to investors
     * @param vestingStartTime The unix timestamp (seconds) of the block when the vesting starts.
     * @param allocatedTokenAmount The allocated token amount for distribution to investors.
     */
    event TgeDetailsPublished(
        address tokenAddress, uint256 totalSupply, uint256 vestingStartTime, uint256 allocatedTokenAmount
    );

    /**
     * @notice This event is emitted when tokens are successfully claimed by the investor.
     *
     * @param amountToBeVested The amount of tokens distributed to the vesting contract.
     * @param amountOnClaim The amount of tokens to be deiistributed directly to the investor on claim
     * @param investor The address of the investor owning the vesting contract.
     * @param vesting The address of the vesting instance deployed.
     */
    event TokenAllocationClaimed(uint256 amountToBeVested, uint256 amountOnClaim, address investor, address vesting);

    /**
     * @notice This event is emitted when tokens are successfully supplied for distribution by the project admin.
     *
     * @param amount The amount of tokens supplied for distribution.
     * @param legionFee The fee amount collected by Legion.
     */
    event TokensSuppliedForDistribution(uint256 amount, uint256 legionFee);

    /**
     * @notice This event is emitted when tokens are successfully supplied for distribution by the project admin.
     *
     * @param _vestingDurationSeconds The vesting schedule duration for the token sold in seconds.
     * @param _vestingCliffDurationSeconds The vesting cliff duration for the token sold in seconds.
     * @param _tokenAllocationOnTGERate The token allocation amount released to investors after TGE in 18 decimals precision.
     */
    event VestingTermsUpdated(
        uint256 _vestingDurationSeconds, uint256 _vestingCliffDurationSeconds, uint256 _tokenAllocationOnTGERate
    );

    /**
     * @notice This event is emitted when excess capital is successfully refunded by the project admin.
     *
     * @param amount The amount of excess capital refunded to the sale.
     */
    event ExcessCapitalRefunded(uint256 amount);

    /**
     * @notice This event is emitted when `investmentAccepted` status is changed.
     *
     * @param investmentAccepted Wheter investment is accepted by the Project.
     */
    event ToggleInvestmentAccepted(bool investmentAccepted);

    /**
     * @notice Throws when tokens already settled by investor.
     *
     * @param investor The address of the investor trying to invest.
     */
    error AlreadySettled(address investor);

    /**
     * @notice Throws when the ask tokens have not been supplied by the project.
     */
    error AskTokensNotSupplied();

    /**
     * @notice Throws when the Project tries to withdraw more than the allowed capital.
     */
    error CannotWithdrawCapital();

    /**
     * @notice Throws when an invalid amount has been requested for refund.
     */
    error InvalidRefundAmount();

    /**
     * @notice Throws when an invalid time config has been provided.
     */
    error InvalidPeriodConfig();

    /**
     * @notice Throws when an invalid amount of tokens has been supplied by the project.
     *
     * @param amount The amount of tokens supplied.
     */
    error InvalidTokenAmountSupplied(uint256 amount);

    /**
     * @notice Throws when an invalid amount has been requested for fee.
     */
    error InvalidFeeAmount();

    /**
     * @notice Throws when an invalid total supply has been provided.
     */
    error InvalidTotalSupply();

    /**
     * @notice Throws when an invalid amount of tokens has been claimed.
     */
    error InvalidClaimAmount();

    /**
     * @notice Throws when the invested capital amount is not equal to the SAFT amount.
     *
     * @param investor The address of the investor.
     */
    error InvalidPositionAmount(address investor);

    /**
     * @notice Throws when the merkle proof for the investor is inavlid.
     *
     * @param investor The address of the investor.
     */
    error InvalidProof(address investor);

    /**
     * @notice Throws when the Project is not accepting investments.
     */
    error InvestmentNotAccepted();

    /**
     * @notice Throws when not called by Legion.
     */
    error NotCalledByLegion();

    /**
     * @notice Throws when not called by the Project.
     */
    error NotCalledByProject();

    /**
     * @notice Throws when the Project has withdrawn capital.
     */
    error ProjectHasWithdrawnCapital();

    /**
     * @notice Throws when no capital has been invested.
     *
     * @param investor The address of the investor
     */
    error CapitalNotInvested(address investor);

    /**
     * @notice Throws when capital has already been withdrawn for an investor.
     *
     * @param investor The address of the investor
     */
    error CapitalAlreadyWithdrawn(address investor);

    /**
     * @notice Throws when the refund period is over.
     */
    error RefundPeriodIsOver();

    /**
     * @notice Throws when the refund period is not over.
     */
    error RefundPeriodIsNotOver();

    /**
     * @notice Throws when the sale is canceled.
     */
    error SaleIsCanceled();

    /**
     * @notice Throws when the sale is not canceled.
     */
    error SaleIsNotCanceled();

    /**
     * @notice Throws when tokens have not been allocated.
     */
    error TokensNotAllocated();

    /**
     * @notice Throws when tokens have been allocated.
     */
    error TokensAlreadyAllocated();

    /**
     * @notice Throws when tokens have already been supplied.
     */
    error TokensAlreadySupplied();

    /**
     * @notice Throws when investor is unable to claim token allocation.
     */
    error UnableToClaimTokenAllocation();

    /**
     * @notice Throws when zero address has been provided.
     */
    error ZeroAddressProvided();

    /**
     * @notice Throws when zero value has been provided.
     */
    error ZeroValueProvided();

    /// @notice A struct describing the pre-liquid sale period and fee configuration.
    struct PreLiquidSaleConfig {
        /// @dev The refund period duration in seconds.
        uint256 refundPeriodSeconds;
        /// @dev The vesting schedule duration for the token sold in seconds.
        uint256 vestingDurationSeconds;
        /// @dev The vesting cliff duration for the token sold in seconds.
        uint256 vestingCliffDurationSeconds;
        /// @dev The token allocation amount released to investors after TGE in 18 decimals precision.
        uint256 tokenAllocationOnTGERate;
        /// @dev Legion's fee on capital raised in BPS (Basis Points).
        uint256 legionFeeOnCapitalRaisedBps;
        /// @dev Legion's fee on tokens sold in BPS (Basis Points).
        uint256 legionFeeOnTokensSoldBps;
        /// @dev The merkle root for verification of SAFT signers and percentage of token allocations.
        bytes32 saftMerkleRoot;
        /// @dev The address of the token used for raising capital.
        address bidToken;
        /// @dev The admin address of the project raising capital.
        address projectAdmin;
        /// @dev The address of Legion's Address Registry contract.
        address addressRegistry;
    }

    /// @notice A struct describing the pre-liquid sale status.
    struct PreLiquidSaleStatus {
        /// @dev The address of the token being sold to investors.
        address askToken;
        /// @dev The unix timestamp (seconds) of the block when the vesting starts.
        uint256 vestingStartTime;
        /// @dev The total supply of the ask token
        uint256 askTokenTotalSupply;
        /// @dev The total capital invested by investors.
        uint256 totalCapitalInvested;
        /// @dev The total amount of tokens allocated to investors.
        uint256 totalTokensAllocated;
        /// @dev The total capital withdrawn by the Project, from the sale.
        uint256 totalCapitalWithdrawn;
        /// @dev Whether the sale has been canceled or not.
        bool isCanceled;
        /// @dev Whether the ask tokens have been supplied to the sale.
        bool askTokensSupplied;
        /// @dev Whether investment is being accepted by the Project.
        bool investmentAccepted;
    }

    /// @notice A struct describing the investor position during the sale.
    struct InvestorPosition {
        /// @dev The total amount of capital invested by the investor.
        uint256 investedCapital;
        /// @dev The amount of capital withdrawn from the investor position by the Project.
        uint256 withdrawnCapital;
        /// @dev The unix timestamp (seconds) of the block when the latest invest ocurred.
        uint256 cachedInvestTimestamp;
        /// @dev The amount of capital the investor is allowed to invest, according to the SAFT.
        uint256 cachedSAFTInvestAmount;
        /// @dev The token allocation rate the investor will receive as percentage of totalSupply, represented in 18 decimals precision.
        uint256 cachedTokenAllocationRate;
        /// @dev The hash of the SAFT signed by the investor
        bytes32 cachedSAFTHash;
        /// @dev Flag if the investor has claimed the tokens allocated to them.
        bool hasSettled;
        /// @dev The address of the investor's vesting contract.
        address vestingAddress;
    }

    /**
     * @notice Initialized the contract with correct parameters.
     *
     * @param preLiquidSaleConfig The period and fee configuration for the pre-liquid sale.
     */
    function initialize(PreLiquidSaleConfig calldata preLiquidSaleConfig) external;

    /**
     * @notice Invest capital to the pre-liquid sale.
     *
     * @param amount The amount of capital invested.
     * @param saftInvestAmount The amount of capital the investor is allowed to invest, according to the SAFT.
     * @param tokenAllocationRate The token allocation the investor will receive as percentage of totalSupply, represented in 18 decimals precision.
     * @param saftHash The hash of the SAFT signed by the investor
     * @param proof The merkle proof that the investor has signed a SAFT
     */
    function invest(
        uint256 amount,
        uint256 saftInvestAmount,
        uint256 tokenAllocationRate,
        bytes32 saftHash,
        bytes32[] calldata proof
    ) external;

    /**
     * @notice Get a refund from the sale during the applicable time window.
     */
    function refund() external;

    /**
     * @notice Updates the token details after Token Generation Event (TGE).
     *
     * @dev Only callable by Legion.
     *
     * @param tokenAddress The address of the token distributed to investors
     * @param totalSupply The total supply of the token distributed to investors
     * @param vestingStartTime The unix timestamp (seconds) of the block when the vesting starts.
     * @param allocatedTokenAmount The allocated token amount for distribution to investors.
     */
    function publishTgeDetails(
        address tokenAddress,
        uint256 totalSupply,
        uint256 vestingStartTime,
        uint256 allocatedTokenAmount
    ) external;

    /**
     * @notice Supply tokens for distribution after the Token Generation Event (TGE).
     *
     * @dev Only callable by the Project.
     *
     * @param amount The amount of tokens to be supplied for distribution.
     * @param legionFee The Legion fee token amount.
     */
    function supplyAskTokens(uint256 amount, uint256 legionFee) external;

    /**
     * @notice Updates the SAFT merkle root.
     *
     * @dev Only callable by Legion.
     *
     * @param merkleRoot The merkle root used for investing capital.
     */
    function updateSAFTMerkleRoot(bytes32 merkleRoot) external;

    /**
     * @notice Updates the vesting terms.
     *
     * @dev Only callable by Legion, before the token have been supplied by the Project.
     *
     * @param vestingDurationSeconds The vesting schedule duration for the token sold in seconds.
     * @param vestingCliffDurationSeconds The vesting cliff duration for the token sold in seconds.
     * @param tokenAllocationOnTGERate The token allocation amount released to investors after TGE in 18 decimals precision.
     */
    function updateVestingTerms(
        uint256 vestingDurationSeconds,
        uint256 vestingCliffDurationSeconds,
        uint256 tokenAllocationOnTGERate
    ) external;

    /**
     * @notice Withdraw tokens from the contract in case of emergency.
     *
     * @dev Can be called only by the Legion admin address.
     *
     * @param receiver The address of the receiver.
     * @param token The address of the token to be withdrawn.
     * @param amount The amount to be withdrawn.
     */
    function emergencyWithdraw(address receiver, address token, uint256 amount) external;

    /**
     * @notice Withdraw capital from the contract.
     *
     * @dev Can be called only by the Project admin address.
     *
     * @param investors Array of the addresses of the investors' capital which will be withdrawn
     */
    function withdrawRaisedCapital(address[] calldata investors) external returns (uint256 amount);

    /**
     * @notice Claim token allocation by investors
     *
     * @param proof The merkle proof that the investor has signed a SAFT
     */
    function claimAskTokenAllocation(bytes32[] calldata proof) external;

    /**
     * @notice Cancel the sale.
     *
     * @dev Can be called only by the Project admin address.
     */
    function cancelSale() external;

    /**
     * @notice Claim back capital from investors if the sale has been canceled.
     */
    function withdrawCapitalIfSaleIsCanceled() external;

    /**
     * @notice Withdraw back excess capital from investors.
     *
     * @param amount The amount of excess capital to be withdrawn.
     * @param saftInvestAmount The amount of capital the investor is allowed to invest, according to the SAFT.
     * @param tokenAllocationRate The token allocation the investor will receive as percentage of totalSupply, represented in 18 decimals precision.
     * @param saftHash The hash of the SAFT signed by the investor
     * @param proof The merkle proof that the investor has signed a SAFT
     */
    function withdrawExcessCapital(
        uint256 amount,
        uint256 saftInvestAmount,
        uint256 tokenAllocationRate,
        bytes32 saftHash,
        bytes32[] calldata proof
    ) external;

    /**
     * @notice Releases tokens to the investor address.
     */
    function releaseTokens() external;

    /**
     * @notice Toggles the `investmentAccepted` status.
     */
    function toggleInvestmentAccepted() external;

    /**
     * @notice Syncs active Legion addresses from `LegionAddressRegistry.sol`
     */
    function syncLegionAddresses() external;

    /**
     * @notice Returns the configuration for the pre-liquid token sale.
     */
    function saleConfig() external view returns (PreLiquidSaleConfig memory preLiquidSaleConfig);

    /**
     * @notice Returns the status of the pre-liquid token sale.
     */
    function saleStatus() external view returns (PreLiquidSaleStatus memory preLiquidSaleStatus);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * ██      ███████  ██████  ██  ██████  ███    ██
 * ██      ██      ██       ██ ██    ██ ████   ██
 * ██      █████   ██   ███ ██ ██    ██ ██ ██  ██
 * ██      ██      ██    ██ ██ ██    ██ ██  ██ ██
 * ███████ ███████  ██████  ██  ██████  ██   ████
 *
 * If you find a bug, please contact security(at)legion.cc
 * We will pay a fair bounty for any issue that puts user's funds at risk.
 *
 */
interface ILegionVestingFactory {
    /**
     * @notice This event is emitted when a new linear vesting schedule contract is deployed for an investor.
     *
     * @param beneficiary The address of the beneficiary.
     * @param startTimestamp The start timestamp of the vesting period.
     * @param durationSeconds The vesting duration in seconds.
     * @param cliffDurationSeconds The vesting cliff duration in seconds.
     */
    event NewLinearVestingCreated(
        address beneficiary, uint64 startTimestamp, uint64 durationSeconds, uint64 cliffDurationSeconds
    );

    /**
     * @notice Deploy a LegionLinearVesting contract.
     *
     * @dev Can be called only by addresses allowed to deploy.
     *
     * @param beneficiary The beneficiary.
     * @param startTimestamp The start timestamp.
     * @param durationSeconds The duration in seconds.
     * @param cliffDurationSeconds The cliff duration in seconds.
     *
     * @return linearVestingInstance The address of the deployed linearVesting instance.
     */
    function createLinearVesting(
        address beneficiary,
        uint64 startTimestamp,
        uint64 durationSeconds,
        uint64 cliffDurationSeconds
    ) external returns (address payable linearVestingInstance);
}