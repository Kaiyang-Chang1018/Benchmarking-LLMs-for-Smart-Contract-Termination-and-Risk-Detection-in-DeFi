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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

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
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
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
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
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
     * ```
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";
import {Context} from "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys a `value` amount of tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;

import {IERC20Permit} from "./IERC20Permit.sol";
import {ERC20} from "../ERC20.sol";
import {ECDSA} from "../../../utils/cryptography/ECDSA.sol";
import {EIP712} from "../../../utils/cryptography/EIP712.sol";
import {Nonces} from "../../../utils/Nonces.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712, Nonces {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @inheritdoc IERC20Permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override(IERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
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
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
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
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
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
     * {FailedInnerCall} error.
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
            revert AddressInsufficientBalance(address(this));
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
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
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
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract Nonces {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    mapping(address account => uint256) private _nonces;

    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

/**
 * @notice Common type definitions and errors.
 */
interface IZNDBase {
    ///////////////////////////
    //   Type Declarations   //
    ///////////////////////////

    /// @dev 6 possible tiers central platform users can achieve, external users belongs to basic tier
    enum Tier {
        Basic,
        Silver,
        Gold,
        Platinum,
        Diamond,
        Ambassador
    }

    /// @dev 4 possible duration options for staking tokens
    enum Plan {
        ThirtyDays,
        NinetyDays,
        HundredEightyDays,
        ThreeHundredSixtyDays
    }

    ////////////////
    //   Errors   //
    ////////////////

    error Znd_NotEOA();
    error Znd_NotZNDPlatform();
    error Znd_ZeroAddress();
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import {IZNDBase} from "./IZNDBase.sol";

/**
* @notice Interface for staking parameters change functionality.
*/
interface IZNDParameters is IZNDBase {
    ///////////////////////////
    //   Type Declarations   //
    ///////////////////////////

    /// @dev Pending change to tier boost that still hasn't passed it's grace period
    struct TierBoostChange {
        /// @dev tier for which we are changing the boost amount
        uint256 tier;
        /// @dev the value to be changed to when the grace period ends
        uint256 newValue;
        /// @dev block timestamp of when the change was initiated
        uint256 initiated;
    }

    // @dev Pending change to plan boost that still hasn't passed it's grace period
    struct PlanBoostChange {
        /// @dev plan for which we are changing the boost amount
        uint256 plan;
        /// @dev the value to be changed to when the grace period ends
        uint256 newValue;
        /// @dev block timestamp of when the change was initiated
        uint256 initiated;
    }

    // @dev Pending change to penalty fee that still hasn't passed it's grace period
    struct PenaltyChange {
        /// @dev plan for which we are changing the penalty fee
        uint256 plan;
        /// @dev the value to be changed to when the grace period ends
        uint256 newValue;
        /// @dev block timestamp of when the change was initiated
        uint256 initiated;
    }

    ////////////////
    //   Errors   //
    ////////////////

    error Parameters_CooldownNotOver();
    error Parameters_ChangeNotWithinBounds();
    error Parameters_PlanOrTierNotValid();

    ////////////////
    //   Events   //
    ////////////////

    event ParameterChangeRequested(
        string changeType,
        uint256 planOrTier,
        uint256 oldValue,
        uint256 newValue
    );

    ////////////////////////////////////
    //      Parameters Change         //
    ////////////////////////////////////

    /**
     * @notice Initialise the change of tier boost to be set after the grace period
	 * @param _tier tier for which we are changing the boost
	 * @param _newValue the new value to be changed to
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
	*/
    function changeTierBoost(uint256 _tier, uint256 _newValue) external;

    /**
     * @notice Initialise the change of plan boost to be set after the grace period
	 * @param _plan plan for which we are changing the boost
	 * @param _newValue the new value to be changed to
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
	*/
    function changePlanBoost(uint256 _plan, uint256 _newValue) external;

    /**
     * @notice Initialise the change of penalty fee for a specific plan to be set after the grace period
	 * @param _plan plan for which we are changing the penalty fee
	 * @param _newValue the new value to be changed to
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
	*/
    function changePenaltyFee(uint256 _plan, uint256 _newValue) external;
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import {IZNDTreasury} from "./IZNDTreasury.sol";

/**
 * @notice Interface for staking functionality.
 */
interface IZNDStaking is IZNDTreasury {
    ///////////////////////////
    //   Type Declarations   //
    ///////////////////////////

    /// @dev a pool that consists of tier and plan, there can be 24 of pools
    struct Pool {
        Tier tier;
        Plan plan;
    }

    /// @dev payload that describes single stake by providing amount to be staked, tier and plan
    /// @dev used only for central platform staking
    struct StakePayload {
        uint256 amount;
        uint256 tier;
        uint256 plan;
    }

    /// @dev payload that describes signle withdraw intention by providing stake ID and withdraw amount
    /// @dev used only for central platform withdraw
    struct WithdrawCentralPayload {
        uint256 stakeId;
        uint256 amount;
    }

    /// @dev a single stake stored in contract
    struct Stake {
        /// @dev incremental field that uniquely identify stake
        uint256 stakeId;
        /// @dev amount of tokens staked
        uint256 amount;
        /// @dev timestamp when tokens are staked
        uint256 stakedAt;
        /// @dev address that staked tokens, can be the central platform or an EOA
        address stakeholder;
        /// @dev a pool tokens are staked into
        Pool pool;
    }

    /// @dev a single pool log stored after every computation
    struct PoolLog {
        /// @dev the amount of funds staked in pool at the time
        uint256 stakedInPool;
        /// @dev the amount of the reward the pool had at the time
        uint256 poolReward;
    }

    /// @dev reward information stored for each stakeholder
    struct Reward {
        /// @dev total amount of the reward the stakeholder has
        uint256 amount;
        /// @dev timestamp at which the reward was last distributed to the stakeholder
        uint256 lastDistributionTime;
        /// @dev stores the start index from which the distribution is going to start for each pool
        uint256[24] startIdxPerPool;
    }

    ////////////////
    //   Errors   //
    ////////////////

    error Znd_InvalidSigner();
    error Stake_ComprehensiveRewardDistributionOngoing();
    error Stake_NoStakesProvided();
    error Stake_NoWithdrawalsProvided();
    error Stake_NotOwner();
    error Stake_DoesNotExist();
    error Stake_WithdrawInsufficientFunds();
    error Stake_AddressNotFound();
    error Stake_ZeroAmountStakeNotAllowed();
    error Stake_ZeroAmountWithdrawalNotAllowed();
    error Reward_WithdrawInsufficientFunds();
    error Reward_ZeroAmountWithdrawalNotAllowed();
    error Reward_ComputationAlreadyStarted();
    error Reward_NotAStakeholder();
    error Reward_InsufficientFundsInPool();
    error Parameters_PoolsAreNotEmpty();

    ////////////////
    //   Events   //
    ////////////////

    event StakedCentral(
        uint256[] stakeIds,
        uint256 numberOfStakes,
        uint256 totalAmount
    );

    event StakedEOA(
        uint256 stakeId,
        address indexed stakeholder,
        uint256 amount,
        Plan plan
    );

    event RewardComputationStarted();

    event ComputedDailyRewards();

    event DistributedDailyReward(address indexed recipient);

    event BatchSizeChanged(uint256 newSize);

    event FinishedComprehensiveRewardDistribution();

    event WithdrawStakesCentral(
        uint256[] stakeIds,
        uint256 numberOfWithdrawals,
        uint256 totalAmount,
        uint256 totalPenalites
    );

    event WithdrawStakeEOA(
        uint256 indexed stakeId,
        address indexed stakeholder,
        uint256 amountWithdrawn,
        uint256 penatlyFee
    );

    event WithdrawRewardsCentral(uint256 amount);

    event WithdrawRewardsEOA(
        address indexed stakeholder,
        uint256 amountWithdrawn
    );

    event DiscretionaryPoolWithdrawal(
        address account,
        uint256 amount,
        uint256 limit
    );

    event DailyRewardOffsetChanged(uint256 newValue);

    event DailyRewardChanged(uint256 amount);

    event DidNotDistributeAllRewardsToSelf(address indexed stakeholder);

    ////////////////////////////////////////
    //      Staking and Withdrawal        //
    ////////////////////////////////////////

    /**
     * @notice Allows the centralized platform to create a batch of stakes in a single transaction.
     * @param _stakes array of StakePayload structs.
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
     * @dev Requires all amounts to be greater than 0, reverts with Stake_ZeroAmountStakeNotAllowed error otherwise.
     * @dev Requires that input array contains at least one element, reverts with Stake_NoStakesProvided error otherwise.
     * @dev Requires that the comprehensive reward distribution is not ongoing, reverts with Stake_ComprehensiveRewardDistributionOngoing error otherwise.
     * @dev Emits StakedCentral event.
     * @dev Emits DidNotDistributeAllRewardsToSelf event.
     * @dev Transfers total amount of staked tokens from central platform to staking contract.
     * @dev Returns true if staking was successful and false if it failed
     */
    function stakeCentral(
        StakePayload[] calldata _stakes
    ) external returns (bool);

    /**
     * @notice Allows an EOA to create a stake in a Basic tier, with selected plan.
     * @param _plan Plan to be used for the stake.
     * @param _amount Amount of tokens to be staked.
     * @param _signature signature to validate the caller of the action and the validity of data.
     * @dev Requires to be called by EOA, reverts with Znd_NotEOA error otherwise.
     * @dev Requires amount to be greater than 0, reverts with Stake_ZeroAmountStakeNotAllowed error otherwise.
     * @dev Requires to match signature with message sender, reverts with Znd_InvalidSigner error otherwise.
     * @dev Requires that the comprehensive reward distribution is not ongoing, reverts with Stake_ComprehensiveRewardDistributionOngoing error otherwise.
     * @dev Emits StakedCentral event.
     * @dev Emits DidNotDistributeAllRewardsToSelf event.
     * @dev Transfers specified amount of tokens from EOA to staking contract.
     * @dev Returns true if staking was successful and false if it failed
     */
    function stakeEOA(
        uint256 _plan,
        uint256 _amount,
        bytes calldata _signature
    ) external returns (bool);

    /**
     * @notice Allows the centralized platform to create a batch of withdrawals in a single transaction.
     * @param _withdrawals array of WithdrawCentralPayload objects describing the stakes to be withdrawn.
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
     * @dev Requires all amounts to be greater than 0, reverts with Stake_ZeroAmountWithdrawalNotAllowed error otherwise.
     * @dev Requires that input array contains at least one element, reverts with Stake_NoWithdrawalsProvided error otherwise.
     * @dev Requires that the comprehensive reward distribution is not ongoing, reverts with Stake_ComprehensiveRewardDistributionOngoing error otherwise.
     * @dev Emits WithdrawStakesCentral event.
     * @dev Emits DidNotDistributeAllRewardsToSelf event.
     * @dev Transfers total amount of withdrawn tokens from staking contract to central platform.
     * @dev Returns true if withdrawing was successful and false if it failed
     */
    function withdrawStakesCentral(
        WithdrawCentralPayload[] calldata _withdrawals
    ) external returns (bool);

    /**
     * @notice Allows an EOA to withdraw funds from a stake up to staked amount.
     * @param _stakeId ID of stake to be withdrawn.
     * @param _amount amount of ZND tokens to withdraw.
     * @param _signature signature to validate the caller of the action and the validity of data.
     * @dev Requires to be called by EOA, reverts with Znd_NotEOA error otherwise.
     * @dev Requires amount to be greater than 0, reverts with Stake_ZeroAmountWithdrawalNotAllowed error otherwise.
     * @dev Requires to match signature with message sender, reverts with Znd_InvalidSigner error otherwise.
     * @dev Requires that the comprehensive reward distribution is not ongoing, reverts with Stake_ComprehensiveRewardDistributionOngoing error otherwise.
     * @dev Emits WithdrawStakeEOA event.
     * @dev Emits DidNotDistributeAllRewardsToSelf event.
     * @dev Transfers specified amount of tokens from staking contract to the EOA.
     * @dev Returns true if withdrawing was successful and false if it failed
     */
    function withdrawStakeEOA(
        uint256 _stakeId,
        uint256 _amount,
        bytes calldata _signature
    ) external returns (bool);

    ////////////////////////////////////////////////////
    //      Rewards Distribution and Withdrawal       //
    ////////////////////////////////////////////////////

    /**
     * @notice Allows the centralized platform to mark the start of the reward computations.
     * @dev Requires that the caller is the central platform, will revert with Reward_NotCentralPlatform otherwise.
     * @dev Requires that the distribution has not already been started, will revert with Reward_ComputationAlreadyStarted otherwise.
     */
    function startRewardComputation() external;

    /**
     * @notice Allows an EOA to withdraw earned rewards up to the amount earned.
     * @param _amount amount of rewarded ZND tokens to withdraw.
     * @param _signature signature to validate the caller of the action and the validity of data.
     * @dev Requires to be called by an EOA, reverts with Znd_NotEOA error otherwise.
     * @dev Requires amount to be greater than 0, reverts with Reward_ZeroAmountWithdrawalNotAllowed error otherwise.
     * @dev Requires amount to be less or equal to rewards earned, reverts with Reward_WithdrawInsufficientFunds error otherwise.
     * @dev Requires to match signature with message sender, reverts with Znd_InvalidSigner error otherwise.
     * @dev Requires that the comprehensive reward distribution is not ongoing, reverts with Stake_ComprehensiveRewardDistributionOngoing error otherwise.
     * @dev Emits WithdrawRewardsEOA event.
     * @dev Emits DidNotDistributeAllRewardsToSelf event.
     * @dev Transfers requested amount of tokens from staking contract to the EOA.
     */
    function withdrawRewardsEOA(
        uint256 _amount,
        bytes calldata _signature
    ) external;

    /**
     * @notice Allows the centralized platform to withdraw all rewards earned by central platform users.
     * @notice It will further distribute appropriate amounts based on user stakes.
     * @param _amount amount of rewarded ZND tokens to withdraw.
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
     * @dev Requires amount to be greater than 0, reverts with Reward_ZeroAmountWithdrawalNotAllowed error otherwise.
     * @dev Requires amount to be less or equal to rewards earned, reverts with Reward_WithdrawInsufficientFunds error otherwise.
     * @dev Requires that the comprehensive reward distribution is not ongoing, reverts with Stake_ComprehensiveRewardDistributionOngoing error otherwise.
     * @dev Emits WithdrawRewardsCentral event.
     * @dev Emits DidNotDistributeAllRewardsToSelf event.
     * @dev Transfers requested amount of tokens from staking contract to central platform.
     */
    function withdrawRewardsCentral(uint256 _amount) external;

    /**
     * @notice Returns a boolean that says if there are more rewards to distribute to the caller.
     * @dev If event `DidNotDistributeAllRewardsToSelf` has been emitted - after staking,
     * @dev withdrawing stake, or withdrawing reward (token balance affecting functionalities),
     * @dev the caller of the function is supposed to invoke this function in a loop until it returns true.
     * @dev Once all the rewards have been distributed, user can then use token balance affecting functionalities.
     */
    function areAllRewardsDistributed() external returns (bool);

    /////////////////////////////////////
    //               Setters           //
    /////////////////////////////////////

    /**
     * @notice Set the amount of rewards to be distributed daily.
     * @param _amount amount of rewards to be distributed daily.
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
     */
    function setDailyReward(uint256 _amount) external;

    /**
     * @notice Sets new offset (from UTC midnight) for reset point for reward computation.
     * @param _newOffset number of minutes to move reset point from UTC midnight.
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
     * @dev Requires all pools to be empty at the time of the offset change, reverts with Parameters_PoolAreNotEmpty error otherwise.
     */
    function setResetPointOffset(uint256 _newOffset) external;

    /////////////////////////////////////
    //               Getters           //
    /////////////////////////////////////

    /**
     * @notice Fetches a stake by its id.
     * @param _stakeId id of the stake.
     * @dev Requires stake to exist, otherwise revert with Stake_DoesNotExist error.
     * @dev Requires message sender to be stake owner, otherwise revert with Stake_NotOwner error.
     * @return Stake entity that represents the stake.
     */
    function getStake(uint256 _stakeId) external view returns (Stake memory);

    /**
     * @notice Gets amount of ZND tokens awarded to the caller.
     * @dev Requires to be called by an actual stakeholder, reverts with Reward_NotAStakeholder error otherwise.
     * @return amout of ZND tokens awarded to the caller address.
     */
    function getRewardAmount() external view returns (uint256);

    /**
     * @notice Gets amount of ZND tokens awarded to specified address.
     * @param _address address to get reward of.
     * @dev Requires to be called by central platform, reverts with Znd_NotZNDPlatform error otherwise.
     * @return amount of ZND tokens awarded to specified address.
     */
    function getRewardAmountOfAddress(
        address _address
    ) external view returns (uint256);

    /**
     * @notice Gets amount of ZND tokens staked in chosen pool.
     * @param _tier tier of the pool.
     * @param _plan plan of the pool.
     * @return amount of ZND tokens staked in the specified pool.
     */
    function getAmountStakedInPool(
        Tier _tier,
        Plan _plan
    ) external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import {IZNDParameters} from "./IZNDParameters.sol";

/**
 * @notice Interface for treasury functionality.
 */
interface IZNDTreasury is IZNDParameters {
    ///////////////////////////
    //   Type Declarations   //
    ///////////////////////////

    enum TreasuryPool {
        RewardsPool,
        DiscretionaryPool,
        FeesPool,
        VestingPool
    }

    /// @dev payload that describes vesting policy for a recipient.
    /// @dev every vesting, after the first one, is unlocked exactly 30 days after the previous one.
    struct VestingPayload {
        /// @dev wallet that is to receive the vesting
        address recipient;
        /// @dev the amount of funds to be unlocked over time
        uint256 quantityToUnlockOverTime;
        /// @dev the number of days over which the total amount will be unlocked
        uint256 numberOfDays;
        /// @dev time that needs to pass, since deployment, in order for first vesting to be unlocked
        uint256 cliffPeriodEnd;
        /// @dev the amount of funds to be unlocked initially
        uint256 initialUnlock;
    }

    /// @dev vesting data for a single recipient.
    struct VestingData {
        /// @dev the amount of unlocked available to be requested
        uint256 availableTokens;
        /// @dev the amount of times the recepient will receive their vesting
        uint256 numberOfUnlocksLeft;
        /// @dev the amount that is unlocked in a single vesting
        uint256 amountToReceivePerUnlock;
        /// @dev last time a vesting has been unlocked
        uint256 nextUnlockTimestamp;
    }

    ////////////////
    //   Errors   //
    ////////////////

    error Treasury__InvalidAddress();
    error Treasury__NotTreasuryAccount();
    error Treasury__OverLimitWithdrawalNotAllowed();
    error Treasury__AmountNotSpecified();
    error Treasury__InsufficientFunds();
    error Treasury__WithdrawalAccountCanNotBeOwner();
    error Treasury__WithdrawalAccountCanNotBeSpecialAccount();
    error Treasury__SpecialAccountCanNotBeOwner();
    error Treasury__SpecialAccountCanNotBeVestingRecipient();
    error Treasury__OwnerAccountCanNotBeVestingRecipient();
    error Treasury__RenouncingOwnershipIsDisabled();
    error Treasury__QuantityUnlockOverTimeNotDivisibleByNumberOfDays();
    error Treasury__DuplicateVestingAddress();

    ////////////////
    //   Events   //
    ////////////////

    event Treasury__Funding(
        address indexed funder,
        uint256 amount,
        TreasuryPool pool
    );

    event Treasury__Withdrawal(
        address indexed withdrawAccount,
        address indexed withdrawTo,
        uint256 amount,
        TreasuryPool pool
    );

    event Treasury__WithdrawalAccountUpdated(
        address indexed updater,
        address indexed newAccount
    );

    event Treasury__SpecialAccountUpdated(
        address indexed updater,
        address indexed newAccount
    );

    event Treasury__WithdrawalLimitUpdated(
        address indexed updater,
        uint256 newLimit
    );

    event Treasury__VestingPayoutCompleted(
        address indexed recipient,
        uint256 amount
    );

    /////////////////
    //   Funding   //
    /////////////////

    /**
     * @notice Send ZND tokens to rewards pool.
     * @param _amount the amount of tokens to add to the pool.
     * @dev emits Treasury__Funding event.
     */
    function fundRewardsPool(uint256 _amount) external;

    /**
     * @notice Send ZND tokens to discretionary pool.
     * @param _amount the amount of tokens to add to the pool.
     * @dev emits Treasury__Funding event.
     */
    function fundDiscretionaryPool(uint256 _amount) external;

    ///////////////////////////////////////////////////////
    //   Withdrawals from Discretionary and Fees pools   //
    ///////////////////////////////////////////////////////

    /**
     * @notice Withdraw ZND tokens from discretionary pool to provided account.
     * @param _to the address where to send tokens.
     * @param _amount the amount of tokens to withdraw from the pool.
     * @dev requires to be called by owner, regular account, or special account, reverts with Treasury__NotTreasuryAccount error otherwise.
     * @dev requires amount to be greater than 0, reverts with Treasury__AmountNotSpecified error otherwise.
     * @dev requires amount to be less than discretionary pool balance, reverts with Treasury__InsufficientFunds error otherwise.
     * @dev requires amount to be less or equal than withdrawal limit when withdraw with regular account,
     * @dev reverts with Treasury__OverLimitWithdrawalNotAllowed error otherwise.
     * @dev emits Treasury__Withdrawal event.
     */
    function withdrawFromDiscretionaryPool(
        address _to,
        uint256 _amount
    ) external;

    /**
     * @notice Withdraw ZND tokens from fees pool to provided account.
     * @param _to the address where to send tokens.
     * @param _amount the amount of tokens to withdraw from the pool.
     * @dev requires to be called by owner, regular account, or special account, reverts with Treasury__NotTreasuryAccount error otherwise.
     * @dev requires amount to be greater than 0, reverts with Treasury__AmountNotSpecified error otherwise.
     * @dev requires amount to be less than fees pool balance, reverts with Treasury__InsufficientFunds error otherwise.
     * @dev requires amount to be less or equal than withdrawal limit when withdraw with regular account,
     * @dev reverts with Treasury__OverLimitWithdrawalNotAllowed error otherwise.
     * @dev emits Treasury__Withdrawal event.
     */
    function withdrawFromFeesPool(address _to, uint256 _amount) external;

    ///////////////////////
    //   Vesting Payout  //
    ///////////////////////

    /**
     * @notice Dispenses funds to the recipient if the recipient is qualify to receive them.
     * @param _amount the amount of tokens to be dispensed to recipient.
     * @dev Transfers the tokens to the recipient and updates the state, if the recipient is qualified to receive the payout.
     * @dev The recipient qualifies to receive the requested amount if and only if sufficient amount of time has passed to
     * @dev receive it and they have enough tokens available in their vesting to receive it.
     * @dev Required to be called by a valid recipient address, reverts with Treasury__InvalidAddress error otherwise.
     * @dev Required that the amount be less or equal to the amount available for address, reverts with Treasury__InsufficientFunds error otherwise.
     * @dev Emits Treasury__VestingPayoutCompleted event.
     * @return Flag that represents if requested payout was paid out or not.
     */
    function requestPayout(uint256 _amount) external returns (bool);

    /**
     * @notice Returns the amount of tokens that can be claimed by the user.
     * @param _address the adress of the user for who the claimable vesting amount is to be calculated.
     */
    function getClaimableVestingAmount(
        address _address
    ) external view returns (uint256);

    ////////////////
    //   Setters  //
    ////////////////

    /**
     * @notice Set limit for withdrawals from discretionary pool.
     * @param _limit maximal number of tokens that can be withdrawn through limited withdrawals.
     * @dev requires caller to be owner of treasury, reverts with OwnableUnauthorizedAccount error otherwise.
     * @dev emits Treasury__WithdrawalLimitUpdated event.
     */
    function setWithdrawLimit(uint256 _limit) external;

    /**
     * @notice Set account address that can withdraw from discretionary pool up to defined limit.
     * @param _account account address that can withdraw from discretionary pool up to defined limit.
     * @dev requires caller to be owner of treasury, reverts with OwnableUnauthorizedAccount error otherwise.
     * @dev requires account to be non zero address, reverts with Treasury__InvalidAddress error otherwise.
     * @dev requires account not to be owner, reverts with Treasury__WithdrawalAccountCanNotBeOwner error otherwise.
     * @dev requires account not to be special account, reverts with Treasury__WithdrawalAccountCanNotBeSpecialAccount error otherwise.
     * @dev emits Treasury__WithdrawalAccountUpdated event.
     */
    function setWithdrawalAccount(address _account) external;

    /**
     * @notice Set account address that can withdraw from discretionary pool over defined limit.
     * @param _account account address that can withdraw from discretionary pool over defined limit.
     * @dev requires caller to be owner of treasury, reverts with OwnableUnauthorizedAccount error otherwise.
     * @dev requires account to be non zero address, reverts with Treasury__InvalidAddress error otherwise.
     * @dev requires account not to be owner, reverts with Treasury__SpecialAccountCanNotBeOwner error otherwise.
     * @dev requires account not to be regular account, reverts with Treasury__WithdrawalAccountCanNotBeSpecialAccount error otherwise.
     * @dev emits Treasury__SpecialAccountUpdated event.
     */
    function setSpecialAccount(address _account) external;
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IZNDBase} from "./IZNDBase.sol";
import {ZNDToken} from "./ZNDToken.sol";

/**
* @notice Base contract that sets up common state variables and modifiers.
* @notice Deploys ZND token upon deployment and becomes owner of total token supply.
*/
contract ZNDBase is IZNDBase, Ownable2Step {
    ////////////////////////////
    //    State Variables     //
    ////////////////////////////

    /// @dev Token used for vesting, staking, rewards and fees
    ZNDToken public immutable s_zndToken;

    /// @dev ZND platform account that will have elevated privileges
    address public immutable s_zndPlatform;

    ///////////////////////////////
    //         Modifiers         //
    ///////////////////////////////

    modifier onlyCentralPlatform() {
        if (msg.sender != s_zndPlatform) revert Znd_NotZNDPlatform();

        _;
    }

    modifier onlyEOA() {
        if (msg.sender == s_zndPlatform)
            revert Znd_NotEOA();

        _;
    }

    ///////////////////////////////
    //         Constructor       //
    ///////////////////////////////

    constructor(address _zndPlatform) Ownable(msg.sender) {
        if (_zndPlatform == address(0)) revert Znd_ZeroAddress();

        s_zndPlatform = _zndPlatform;

        s_zndToken = new ZNDToken();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {IZNDParameters} from "./IZNDParameters.sol";
import {ZNDBase} from "./ZNDBase.sol";

/**
 * @notice Implements staking parameters change functionality for payout boosts and penalty fees.
 * @notice Parameters can be changed only within the predefined limits set up in constructor.
 * @notice Parameter changes are reflected after grace period pass and can not be changed again until cool down period is over.
 */
contract ZNDParameters is ZNDBase, IZNDParameters {
    ////////////////////////////
    //    State Variables     //
    ////////////////////////////

    /// @dev Plan => duration in days
    mapping(uint256 => uint256) public s_planDuration;

    // Reward boost mappings
    /// @dev Tier => Reward boost
    mapping(uint256 => uint256) public s_tierBoost;

    /// @dev Plan => Reward boost
    mapping(uint256 => uint256) public s_planBoost;

    /// @dev Plan => Penalty fee in bps
    mapping(uint256 => uint256) public s_penaltyFee;

    // Parameter change limitations

    uint256 public immutable s_tierBoostLowerLimit;
    uint256 public immutable s_tierBoostUpperLimit;
    uint256 public immutable s_tierBoostStepLimit;

    uint256 public immutable s_planBoostLowerLimit;
    uint256 public immutable s_planBoostUpperLimit;
    uint256 public immutable s_planBoostStepLimit;

    uint256 public immutable s_penaltyFeeLowerLimit;
    mapping(uint256 => uint256) public s_penaltyFeeUpperLimit;
    uint256 public immutable s_penaltyFeeStepLimit;

    uint256 public immutable s_parameterChangeGrace;
    uint256 public immutable s_parameterChangeCooldown;

    // Parameter change state variables

    // These are all circular buffers, they will be used for storing pending changes to avoid unnecessary removal and
    // addition of elements to a plain array while preserving the order of pending changes for the purpose of simplifying
    // checking for ones that passed their grace period
    // Just in case, explanation of how it works will be provided as they are used

    TierBoostChange[6] internal s_tierBoostChanges;
    PlanBoostChange[4] internal s_planBoostChanges;
    PenaltyChange[4] internal s_penaltyChanges;

    // Start and end indexes for the circular buffers

    uint256 internal s_tbcIdxStart;
    uint256 internal s_tbcIdxEnd;

    uint256 internal s_pbcIdxStart;
    uint256 internal s_pbcIdxEnd;

    uint256 internal s_pcIdxStart;
    uint256 internal s_pcIdxEnd;

    // Timestamps for the last change of each parameter

    mapping(uint256 => uint256) internal s_lastTierBoostChange;

    mapping(uint256 => uint256) internal s_lastPlanBoostChange;

    mapping(uint256 => uint256) internal s_lastPenaltyChange;

    constructor(address _zndPlatform) ZNDBase(_zndPlatform) {
        // Initialize reward boost as scaled integer values for each tier
        s_tierBoost[uint256(Tier.Basic)] = 100; // 1x
        s_tierBoost[uint256(Tier.Silver)] = 200; // 2x
        s_tierBoost[uint256(Tier.Gold)] = 220; // 2.2x
        s_tierBoost[uint256(Tier.Platinum)] = 240; // 2.4x
        s_tierBoost[uint256(Tier.Diamond)] = 260; // 2.6x
        s_tierBoost[uint256(Tier.Ambassador)] = 300; // 3x

        // Initialize reward boost bps for each plan
        s_planBoost[uint256(Plan.ThirtyDays)] = 100; // 1x
        s_planBoost[uint256(Plan.NinetyDays)] = 150; // 1.5x
        s_planBoost[uint256(Plan.HundredEightyDays)] = 200; // 2x
        s_planBoost[uint256(Plan.ThreeHundredSixtyDays)] = 300; // 3x

        // Initialize plan duration in days
        s_planDuration[uint256(Plan.ThirtyDays)] = 30;
        s_planDuration[uint256(Plan.NinetyDays)] = 90;
        s_planDuration[uint256(Plan.HundredEightyDays)] = 180;
        s_planDuration[uint256(Plan.ThreeHundredSixtyDays)] = 360;

        // Initialize penalties bps for each plan
        s_penaltyFee[uint256(Plan.ThirtyDays)] = 100; // 1%
        s_penaltyFee[uint256(Plan.NinetyDays)] = 300; // 3%
        s_penaltyFee[uint256(Plan.HundredEightyDays)] = 600; // 6%
        s_penaltyFee[uint256(Plan.ThreeHundredSixtyDays)] = 1200; // 12%

        // Initialise all parameter change limits

        s_tierBoostLowerLimit = 100; // 1x
        s_tierBoostUpperLimit = 1000; // 10x
        s_tierBoostStepLimit = 1; // 0.01

        s_planBoostLowerLimit = 100; // 1x
        s_planBoostUpperLimit = 1000; // 10x
        s_planBoostStepLimit = 1; // 0.01

        s_penaltyFeeLowerLimit = 0; // 0%
        s_penaltyFeeStepLimit = 1; // 0.01%

        s_penaltyFeeUpperLimit[uint256(Plan.ThirtyDays)] = 500; // 5%
        s_penaltyFeeUpperLimit[uint256(Plan.NinetyDays)] = 1000; // 10%
        s_penaltyFeeUpperLimit[uint256(Plan.HundredEightyDays)] = 1500; // 15%
        s_penaltyFeeUpperLimit[uint256(Plan.ThreeHundredSixtyDays)] = 2500; // 25%

        s_parameterChangeGrace = 1;
        s_parameterChangeCooldown = 3;

        // Set initial change of parameters to contract creation

        s_lastTierBoostChange[uint256(Tier.Basic)] = block.timestamp;
        s_lastTierBoostChange[uint256(Tier.Silver)] = block.timestamp;
        s_lastTierBoostChange[uint256(Tier.Gold)] = block.timestamp;
        s_lastTierBoostChange[uint256(Tier.Platinum)] = block.timestamp;
        s_lastTierBoostChange[uint256(Tier.Diamond)] = block.timestamp;
        s_lastTierBoostChange[uint256(Tier.Ambassador)] = block.timestamp;

        s_lastPlanBoostChange[uint256(Plan.ThirtyDays)] = block.timestamp;
        s_lastPlanBoostChange[uint256(Plan.NinetyDays)] = block.timestamp;
        s_lastPlanBoostChange[uint256(Plan.HundredEightyDays)] = block
            .timestamp;
        s_lastPlanBoostChange[uint256(Plan.ThreeHundredSixtyDays)] = block
            .timestamp;

        s_lastPenaltyChange[uint256(Plan.ThirtyDays)] = block.timestamp;
        s_lastPenaltyChange[uint256(Plan.NinetyDays)] = block.timestamp;
        s_lastPenaltyChange[uint256(Plan.HundredEightyDays)] = block.timestamp;
        s_lastPenaltyChange[uint256(Plan.ThreeHundredSixtyDays)] = block
            .timestamp;

        // Set indexes for the circular buffer

        s_tbcIdxStart = 0;
        s_tbcIdxEnd = 0;

        s_pbcIdxStart = 0;
        s_pbcIdxEnd = 0;

        s_pcIdxStart = 0;
        s_pcIdxEnd = 0;
    }

    ///////////////////////////////////
    //      External Functions       //
    ///////////////////////////////////

    function changeTierBoost(
        uint256 _tier,
        uint256 _newValue
    ) external onlyCentralPlatform {
        // We check if the tier is valid
        if (_tier >= 6) {
            revert Parameters_PlanOrTierNotValid();
        }

        // We check if the cooldown period for the change has expired
        if (
            block.timestamp - s_lastTierBoostChange[_tier] <
            30 days * s_parameterChangeCooldown
        ) revert Parameters_CooldownNotOver();

        _checkPendingBoostChanges();

        // Find the absolute value of the change difference
        uint256 valDif = _newValue > s_tierBoost[_tier]
            ? _newValue - s_tierBoost[_tier]
            : s_tierBoost[_tier] - _newValue;

        // Check if the change is within limitations
        if (
            _newValue > s_tierBoostUpperLimit ||
            _newValue < s_tierBoostLowerLimit ||
            valDif > s_tierBoostStepLimit
        ) revert Parameters_ChangeNotWithinBounds();

        // Save the timestamp of the current change as latest
        s_lastTierBoostChange[_tier] = block.timestamp;

        // Add the current change to the pending changes buffer
        TierBoostChange memory newChange = TierBoostChange({
            tier: _tier,
            newValue: _newValue,
            initiated: block.timestamp
        });

        s_tierBoostChanges[s_tbcIdxEnd] = newChange;
        s_tbcIdxEnd = (s_tbcIdxEnd + 1) % 6; // As we are using a circular buffer, the indexing of the array "wraps around"
        // back to the beginning of the array after adding to the end of the buffer

        emit ParameterChangeRequested(
            "TierBoost",
            _tier,
            s_tierBoost[_tier],
            _newValue
        );
    }

    function changePlanBoost(
        uint256 _plan,
        uint256 _newValue
    ) external onlyCentralPlatform {
        // Check if tier is valid
        if (_plan >= 4) {
            revert Parameters_PlanOrTierNotValid();
        }

        // We check if the cooldown period for the change has expired
        if (
            block.timestamp - s_lastPlanBoostChange[_plan] <
            s_parameterChangeCooldown * 30 days
        ) revert Parameters_CooldownNotOver();

        _checkPendingBoostChanges();

        // Find the absolute value of the change difference
        uint256 valDif = _newValue > s_planBoost[_plan]
            ? _newValue - s_planBoost[_plan]
            : s_planBoost[_plan] - _newValue;

        // Check if the change is within limitations
        if (
            _newValue > s_planBoostUpperLimit ||
            _newValue < s_planBoostLowerLimit ||
            valDif > s_planBoostStepLimit
        ) revert Parameters_ChangeNotWithinBounds();

        // Save the timestamp of the current change as latest
        s_lastPlanBoostChange[_plan] = block.timestamp;

        // Add the current change to the pending changes buffer
        PlanBoostChange memory newChange = PlanBoostChange({
            plan: _plan,
            newValue: _newValue,
            initiated: block.timestamp
        });

        s_planBoostChanges[s_pbcIdxEnd] = newChange;
        s_pbcIdxEnd = (s_pbcIdxEnd + 1) % 4; // As we are using a circular buffer, the indexing of the array "wraps around"
        // back to the beginning of the array after adding to the end of the buffer

        emit ParameterChangeRequested(
            "PlanBoost",
            _plan,
            s_planBoost[_plan],
            _newValue
        );
    }

    function changePenaltyFee(
        uint256 _plan,
        uint256 _newValue
    ) external onlyCentralPlatform {
        // Check if plan is valid
        if (_plan >= 4) {
            revert Parameters_PlanOrTierNotValid();
        }

        // We check if the cooldown period for the change has expired
        if (
            block.timestamp - s_lastPenaltyChange[_plan] <
            30 days * s_parameterChangeCooldown
        ) revert Parameters_CooldownNotOver();

        _checkPendingPenaltyChanges();

        // Find the absolute value of the change difference
        uint256 valDif = _newValue > s_penaltyFee[_plan]
            ? _newValue - s_penaltyFee[_plan]
            : s_penaltyFee[_plan] - _newValue;

        // Check if the change is within limitations
        if (
            _newValue > s_penaltyFeeUpperLimit[_plan] ||
            _newValue < s_penaltyFeeLowerLimit ||
            valDif > s_penaltyFeeStepLimit
        ) revert Parameters_ChangeNotWithinBounds();

        // Save the timestamp of the current change as latest
        s_lastPenaltyChange[_plan] = block.timestamp;

        // Add the current change to the pending changes buffer
        PenaltyChange memory newChange = PenaltyChange({
            plan: _plan,
            newValue: _newValue,
            initiated: block.timestamp
        });

        s_penaltyChanges[s_pcIdxEnd] = newChange;
        s_pcIdxEnd = (s_pcIdxEnd + 1) % 4; // As we are using a circular buffer, the indexing of the array "wraps around"
        // back to the beginning of the array after adding to the end of the buffers

        emit ParameterChangeRequested(
            "PenaltyFee",
            _plan,
            s_penaltyFee[_plan],
            _newValue
        );
    }

    ///////////////////////////////////
    //      Internal Functions       //
    ///////////////////////////////////

    // Function for checking if any pending boost changes have passed their grace period
    function _checkPendingBoostChanges() internal {
        // First check for tier boost changes
        for (uint256 i = s_tbcIdxStart; i != s_tbcIdxEnd; i = (i + 1) % 6) {
            // For loop goes around the circular buffer
            if (
                block.timestamp - s_tierBoostChanges[i].initiated >
                s_parameterChangeGrace * 30 days
            ) {
                s_tierBoost[s_tierBoostChanges[i].tier] = s_tierBoostChanges[i]
                    .newValue;
                s_tbcIdxStart = (s_tbcIdxStart + 1) % 6; // When a pending change has expired, it is deleted by simply moving
                // the start index (which, again, wraps around) past it
            } else {
                break; // The order of addintion to the buffer is temporal, so if we come across a pending change
                // not past the grace period, we know the ones after it are also not past it
            }
        }

        // Then check for plan boost changes
        for (uint256 i = s_pbcIdxStart; i != s_pbcIdxEnd; i = (i + 1) % 4) {
            // For loop goes around the circular buffer
            if (
                block.timestamp - s_planBoostChanges[i].initiated >
                s_parameterChangeGrace * 30 days
            ) {
                s_planBoost[s_planBoostChanges[i].plan] = s_planBoostChanges[i]
                    .newValue;
                s_pbcIdxStart = (s_pbcIdxStart + 1) % 4; // When a pending change has expired, it is deleted by simply moving
                // the start index (which, again, wraps around) past it
            } else {
                break; // The order of addintion to the buffer is temporal, so if we come across a pending change
            } // not past the grace period, we know the ones after it are also not past it
        }
    }

    // Function for checking if any pending penalty fee changes passed their grace period
    function _checkPendingPenaltyChanges() internal {
        for (uint256 i = s_pcIdxStart; i != s_pcIdxEnd; i = (i + 1) % 4) {
            // For loop goes around the circular buffer
            if (
                block.timestamp - s_penaltyChanges[i].initiated >
                s_parameterChangeGrace * 30 days
            ) {
                s_penaltyFee[s_penaltyChanges[i].plan] = s_penaltyChanges[i]
                    .newValue;
                s_pcIdxStart = (s_pcIdxStart + 1) % 4; // When a pending change has expired, it is deleted by simply moving
                // the start index (which, again, wraps around) past it
            } else {
                break; // The order of addintion to the buffer is temporal, so if we come across a pending change
            } // not past the grace period, we know the ones after it are also not past it
        }
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IZNDStaking} from "./IZNDStaking.sol";
import {ZNDTreasury} from "./ZNDTreasury.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @notice Implements staking and withdrawal functionality for central platform and externally owned accounts.
 * @notice Implements rewards distribution functionality.
 * @notice EOA interaction require implementation of EIP-712 for signing messages.
 */
contract ZNDStaking is ZNDTreasury, IZNDStaking, EIP712 {
    using SafeERC20 for IERC20;

    using ECDSA for bytes32;

    using EnumerableSet for EnumerableSet.AddressSet;

    ///////////////////////////
    //   EIP712 Typehashes   //
    ///////////////////////////

    bytes32 private immutable _STAKE_EOA_TYPEHASH =
        keccak256("StakeEOA(uint256 plan,uint256 amount)");

    bytes32 private immutable _WITHDRAW_STAKE_EOA_TYPEHASH =
        keccak256("WithdrawStakeEOA(uint256 stakeId,uint256 amount)");

    bytes32 private immutable _WITHDRAW_REWARDS_EOA_TYPEHASH =
        keccak256("WithdrawRewardsEOA(uint256 amount)");

    ////////////////////////////
    //    State Constants     //
    ////////////////////////////

    /// @dev Number of tiers in the Tier enum
    uint256 private constant NUM_TIERS = 6;

    /// @dev Number of plans in the Plan enum
    uint256 private constant NUM_PLANS = 4;

    /// @dev Number of Pools in total
    uint256 private constant NUM_POOLS = NUM_PLANS * NUM_TIERS;

    /// @dev Flag value to represent false for uint256
    uint256 private constant FALSE = 1;

    /// @dev Flag value to represent true for uint256
    uint256 private constant TRUE = 2;

    /// @dev Max number of logged days of a pool to be processed in a single batch
    uint256 private constant BATCH_DAY_COUNT = 2 * (365 + 1);

    ////////////////////////////
    //    State Variables     //
    ////////////////////////////

    /// @dev Addresses of stakeholders stored
    EnumerableSet.AddressSet private s_stakeholders;

    /// @dev Stores the amount each stakeholder has stakes in each pool
    mapping(address => uint256[NUM_POOLS])
        private s_stakedPerStakeholderAndPool;

    /// @dev How much each stakeholder has staked in total
    mapping(address => uint256) private s_stakedOf;

    /// @dev How many logs already exist for each pool
    uint256[NUM_POOLS] private s_existingPoolLogCount;

    /// @dev Stakes stored
    mapping(uint256 => Stake) private s_stakes;

    /// @dev Incremental counter of stakes, applied as stakeId when creating new stake
    uint256 public s_nextStakeId;

    /// @dev total number of staked ZND tokens
    uint256 public s_totalStaked;

    /// @dev a flag to make the start of reward computation callable only once ever
    uint256 private s_rewardComputationStarted;

    /// @dev timestamp at which the next reward can be computed
    uint256 private s_nextValidRewardComputationTime;

    /// @dev staked per tier and plan
    uint256[NUM_POOLS] private s_stakedPerPool;

    /// @dev Collected pool logs since last comprehensive reward distribution for each pool
    mapping(uint256 => PoolLog[]) private s_poolLogs;

    /// @dev Timestamp at which the last pool log was created
    uint256 private s_lastPoolLogCreationTime;

    /// @dev Amount of ZND tokens rewarded per stakeholder
    mapping(address => Reward) private s_rewardOf;

    /// @dev Number of minutes to move reset point
    uint256 private s_resetPointOffset;

    /// @dev Amount of rewards for daily distribution
    uint256 public s_dailyReward;

    ///////////////////////////////
    //         Constructor       //
    ///////////////////////////////

    constructor(
        address _zndPlatform,
        address _discretionaryWithdrawalAccount,
        address _overLimitWithdrawalAccount,
        uint256 _initialDailyReward,
        uint256 _initialDiscretionaryPoolBalance,
        uint256 _initialRewardsPoolBalance,
        VestingPayload[] memory _vestingPayload
    )
        ZNDTreasury(
            _zndPlatform,
            _discretionaryWithdrawalAccount,
            _overLimitWithdrawalAccount,
            _initialDiscretionaryPoolBalance,
            _initialRewardsPoolBalance,
            _vestingPayload
        )
        EIP712("ZNDStaking", "1")
    {
        if (_zndPlatform == address(0)) revert Znd_ZeroAddress();

        s_zndPlatform = _zndPlatform;

        s_nextStakeId = 1; // stakeIds starts from 1 to avoid mistaking for nonexistent value

        s_totalStaked = 0;

        s_dailyReward = _initialDailyReward;

        s_resetPointOffset = 0;

        s_rewardComputationStarted = FALSE;
    }

    ////////////////////////////////////////
    //      Staking and Withdrawal        //
    ////////////////////////////////////////

    /// @inheritdoc IZNDStaking
    function stakeCentral(
        StakePayload[] calldata _stakes
    ) external onlyCentralPlatform returns (bool) {
        uint256 numberOfStakes = _stakes.length;

        // check if there's anything to stake
        if (numberOfStakes == 0) revert Stake_NoStakesProvided();

        // check for empty stakes
        for (uint256 i = 0; i < numberOfStakes; i++) {
            if (_stakes[i].amount == 0)
                revert Stake_ZeroAmountStakeNotAllowed();
        }

        distributeRewards();

        // if all the pool logs haven't been processed, return
        if (
            s_stakeholders.contains(msg.sender) &&
            s_lastPoolLogCreationTime >
            s_rewardOf[msg.sender].lastDistributionTime
        ) {
            emit DidNotDistributeAllRewardsToSelf(msg.sender);
            return false;
        }

        // set up local variables to track the staked amount and stake ids
        uint256 stakedInBatch = 0;
        uint256[] memory createdStakeIds = new uint256[](numberOfStakes);

        // loop through the array, stake tokens, and track stake ids and total staked amount
        for (uint256 i = 0; i < numberOfStakes; i++) {
            StakePayload calldata stake = _stakes[i];
            stakedInBatch += stake.amount;

            createdStakeIds[i] = _stakeTokens(stake, i);
        }

        // set next stake id
        s_nextStakeId += numberOfStakes;

        // increase total staked amount
        s_totalStaked += stakedInBatch;

        emit StakedCentral(createdStakeIds, _stakes.length, stakedInBatch);

        // transfer funds from central platform to this contract
        IERC20(s_zndToken).safeTransferFrom(
            msg.sender,
            address(this),
            stakedInBatch
        );

        return true;
    }

    /// @inheritdoc IZNDStaking
    function stakeEOA(
        uint256 _plan,
        uint256 _amount,
        bytes calldata _signature
    ) external onlyEOA returns (bool) {
        // revert if nothing to stake
        if (_amount == 0) revert Stake_ZeroAmountStakeNotAllowed();

        // check if the message has been signed by the message sender
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(_STAKE_EOA_TYPEHASH, _plan, _amount))
        );
        address signer = digest.recover(_signature);
        if (signer != msg.sender) revert Znd_InvalidSigner();

        // calls compute rewards distribution to take into account changes from last computation until now
        // that way the consistency of the system state and rewards distribution is preserved
        distributeRewards();

        // if all the pool logs haven't been processed, return
        if (
            s_stakeholders.contains(msg.sender) &&
            s_lastPoolLogCreationTime >
            s_rewardOf[msg.sender].lastDistributionTime
        ) {
            emit DidNotDistributeAllRewardsToSelf(msg.sender);
            return false;
        }

        // the stake will be placed in one of 4 basic tier pools according to specified plan
        Pool memory pool = Pool({tier: Tier.Basic, plan: Plan(_plan)});

        // stake tokens
        StakePayload memory stakePayload = StakePayload({
            amount: _amount,
            tier: uint256(pool.tier),
            plan: uint256(pool.plan)
        });
        uint256 stakeId = _stakeTokens(stakePayload, 0);

        // increase total staked amount
        s_totalStaked += _amount;

        // set next stake id
        s_nextStakeId += 1;

        emit StakedEOA(stakeId, msg.sender, _amount, Plan(_plan));

        // transfer tokens from the EOA to this contract
        IERC20(s_zndToken).safeTransferFrom(msg.sender, address(this), _amount);

        return true;
    }

    /// @inheritdoc IZNDStaking
    function withdrawStakesCentral(
        WithdrawCentralPayload[] calldata _withdrawals
    ) external onlyCentralPlatform returns (bool) {
        uint256 numberOfWithdrawals = _withdrawals.length;

        // check if there's anything in the provided array and revert if not
        if (numberOfWithdrawals == 0) revert Stake_NoWithdrawalsProvided();

        // check for empty stakes
        for (uint256 i = 0; i < numberOfWithdrawals; i++) {
            if (_withdrawals[i].amount == 0)
                revert Stake_ZeroAmountWithdrawalNotAllowed();
        }

        // calls compute rewards distribution to take into account changes from last computation until now
        // that way the consistency of the system state and rewards distribution is preserved
        distributeRewards();

        // if all the pool logs haven't been processed, return
        if (
            s_stakeholders.contains(msg.sender) &&
            s_lastPoolLogCreationTime >
            s_rewardOf[msg.sender].lastDistributionTime
        ) {
            emit DidNotDistributeAllRewardsToSelf(msg.sender);
            return false;
        }

        // set up local variables that track ids of withdrawn stakes, withdrawn amount,
        // and applied fees for early withdrawal
        uint256[] memory stakeIds = new uint256[](numberOfWithdrawals);
        uint256 penaltyFees = 0;
        uint256 totalAmountToWithdraw = 0;

        // loop through the provided array and execute withdrawals
        for (uint256 i = 0; i < numberOfWithdrawals; i++) {
            WithdrawCentralPayload calldata withdrawal = _withdrawals[i];

            (uint256 amountToWithdraw, uint256 penaltyFee) = _withdrawTokens(
                withdrawal.stakeId,
                withdrawal.amount
            );

            stakeIds[i] = withdrawal.stakeId;

            penaltyFees += penaltyFee;

            totalAmountToWithdraw += amountToWithdraw;
        }

        // decrease total staked for the total amount to withdraw and applied penalty fees
        s_totalStaked -= totalAmountToWithdraw + penaltyFees;

        // increase balance of the fees pool
        s_feesPoolBalance += penaltyFees;

        emit WithdrawStakesCentral(
            stakeIds,
            stakeIds.length,
            totalAmountToWithdraw,
            penaltyFees
        );

        // transfer tokens to the central platform
        IERC20(s_zndToken).safeTransfer(msg.sender, totalAmountToWithdraw);

        return true;
    }

    /// @inheritdoc IZNDStaking
    function withdrawStakeEOA(
        uint256 _stakeId,
        uint256 _amount,
        bytes calldata _signature
    ) external onlyEOA returns (bool) {
        // revert if nothing to stake
        if (_amount == 0) revert Stake_ZeroAmountWithdrawalNotAllowed();

        // check if the message has been signed by the message sender
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(_WITHDRAW_STAKE_EOA_TYPEHASH, _stakeId, _amount)
            )
        );
        address signer = digest.recover(_signature);
        if (signer != msg.sender) revert Znd_InvalidSigner();

        // calls compute rewards distribution to take into account changes from last computation until now
        // that way the consistency of the system state and rewards distribution is preserved
        distributeRewards();

        // if all the pool logs haven't been processed, return
        if (
            s_stakeholders.contains(msg.sender) &&
            s_lastPoolLogCreationTime >
            s_rewardOf[msg.sender].lastDistributionTime
        ) {
            emit DidNotDistributeAllRewardsToSelf(msg.sender);
            return false;
        }

        // withdraw tokens and collect how much to withdraw and applied penalty for early withdrawal
        (uint256 amountToWithdraw, uint256 penaltyFee) = _withdrawTokens(
            _stakeId,
            _amount
        );

        // decrease total staked for the amount to withdraw and applied penalty fee
        s_totalStaked -= amountToWithdraw + penaltyFee;

        // increase balance of the fees pool
        s_feesPoolBalance += penaltyFee;

        emit WithdrawStakeEOA(
            _stakeId,
            msg.sender,
            amountToWithdraw,
            penaltyFee
        );

        // transfer tokens from this contract to the EOA
        IERC20(s_zndToken).safeTransfer(msg.sender, amountToWithdraw);

        return true;
    }

    ////////////////////////////////////////////////////
    //      Rewards Computation and Withdrawal        //
    ////////////////////////////////////////////////////

    /// @inheritdoc IZNDStaking
    function startRewardComputation() external onlyCentralPlatform {
        if (TRUE == s_rewardComputationStarted)
            revert Reward_ComputationAlreadyStarted();

        s_rewardComputationStarted = TRUE;
        s_nextValidRewardComputationTime = block.timestamp;

        emit RewardComputationStarted();
    }

    /// @inheritdoc IZNDStaking
    function withdrawRewardsEOA(
        uint256 _amount,
        bytes calldata _signature
    ) external onlyEOA {
        // check if amount to withdraw is greater than 0
        if (_amount == 0) revert Reward_ZeroAmountWithdrawalNotAllowed();

        // check if the message has been signed by the message sender
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(_WITHDRAW_REWARDS_EOA_TYPEHASH, _amount))
        );
        address signer = digest.recover(_signature);
        if (signer != msg.sender) revert Znd_InvalidSigner();

        distributeRewards();

        // if all the pool logs haven't been processed, return
        if (
            s_stakeholders.contains(msg.sender) &&
            s_lastPoolLogCreationTime >
            s_rewardOf[msg.sender].lastDistributionTime
        ) {
            emit DidNotDistributeAllRewardsToSelf(msg.sender);
            return;
        }

        // check if the amount is not higher than available to caller
        if (_amount > s_rewardOf[msg.sender].amount)
            revert Reward_WithdrawInsufficientFunds();

        // decrease amount of rewards caller posses
        s_rewardOf[msg.sender].amount -= _amount;

        // decrease amount of rewards available in the rewards pool
        if (s_rewardsPoolBalance < _amount) {
            revert Reward_InsufficientFundsInPool();
        }
        s_rewardsPoolBalance -= _amount;

        emit WithdrawRewardsEOA(msg.sender, _amount);

        // send tokens to the caller
        IERC20(s_zndToken).safeTransfer(msg.sender, _amount);
    }

    /// @inheritdoc IZNDStaking
    function withdrawRewardsCentral(
        uint256 _amount
    ) external onlyCentralPlatform {
        // check if amount to withdraw is greater than 0
        if (_amount == 0) revert Reward_ZeroAmountWithdrawalNotAllowed();

        distributeRewards();

        // if all the pool logs haven't been processed, return
        if (
            s_stakeholders.contains(msg.sender) &&
            s_lastPoolLogCreationTime >
            s_rewardOf[msg.sender].lastDistributionTime
        ) {
            emit DidNotDistributeAllRewardsToSelf(msg.sender);
            return;
        }

        // check if the amount is not higher than available to caller
        if (_amount > s_rewardOf[msg.sender].amount)
            revert Reward_WithdrawInsufficientFunds();

        // decrease amount of rewards caller posses
        s_rewardOf[msg.sender].amount -= _amount;

        // decrease amount of rewards available in the rewards pool
        if (s_rewardsPoolBalance < _amount) {
            revert Reward_InsufficientFundsInPool();
        }
        s_rewardsPoolBalance -= _amount;

        emit WithdrawRewardsCentral(_amount);

        // send tokens to the caller
        IERC20(s_zndToken).safeTransfer(msg.sender, _amount);
    }

    /// @inheritdoc IZNDStaking
    function areAllRewardsDistributed() external view returns (bool) {
        return
            s_rewardOf[msg.sender].lastDistributionTime >=
            s_lastPoolLogCreationTime;
    }

    /**
     * @notice Distributes all the uncollected rewards to caller based on pool logs.
     * @dev It's being called internally by token balance affecting functionalities:
     * @dev staking or withdrawal or tokens (central or EOA), reward withdrawals (central and EOA).
     * @dev It's necessary to distribute all the rewards to self before proceeding with these functionalities.
     * @dev If the caller has been inactive for extensive periods of time, which would be more
     * @dev than 2 years of inactivity, the token balance affecting functionalities will emit
     * @dev `DidNotDistributeAllRewardsToSelf` event, this means that this functionality has to be invoked explicitly
     * @dev sufficient amount of times, by the stakeholder, in order for to collect all the rewards first.
     * @dev Invoking it sufficient amount of times can be easily achieved by calling it in a loop until
     * @dev `areAllRewardsDistributed` returns true, caller can then use the token balance affecting functionalities again.
     */
    function distributeRewards() public {
        // include all the new logs that happened in the meantime
        _computeReward();

        // if the caller is not a stakeholder return
        if (!s_stakeholders.contains(msg.sender)) return;

        // if the caller has already collected all of the rewards return
        if (
            s_rewardOf[msg.sender].lastDistributionTime >=
            s_lastPoolLogCreationTime
        ) return;

        // convert to local variable to save up on gas cost
        uint256[NUM_POOLS]
            memory stakedByStakeholderPerPool = s_stakedPerStakeholderAndPool[
                msg.sender
            ];

        // local variable to keep track of how much reward the stakeholder has collected
        uint256 newlyCollectedRewards = 0;

        // flag to know if the all the logs have been processed or not
        // in order to know if the last reward distribution time should be modified
        uint256 allLogsProcessed = TRUE;

        // this loop will process at most `BATCH_DAY_COUNT` logs of each pool
        // the stakeholder has funds in and collect the rewards for the processed logs
        for (uint256 plan = 0; plan < NUM_PLANS; plan++) {
            for (uint256 tier = 0; tier < NUM_TIERS; tier++) {
                // calculates linearized index of pool
                uint256 poolIndex = plan * NUM_TIERS + tier;

                uint256 stakeholderFundsInPool = stakedByStakeholderPerPool[
                    poolIndex
                ];

                // if stakeholder has nothing in pool, it will not affect reward
                if (0 == stakeholderFundsInPool) continue;

                // get the pool log range that should be processed
                uint256 poolStartIdx = s_rewardOf[msg.sender].startIdxPerPool[
                    poolIndex
                ];
                uint256 poolEndIdx = poolStartIdx + BATCH_DAY_COUNT;

                if (poolEndIdx >= s_poolLogs[poolIndex].length) {
                    // if it is the last batch, prevent out of bounds access
                    poolEndIdx = s_poolLogs[poolIndex].length;
                } else {
                    // otherwise not all logs can be processed so set the flag to false
                    allLogsProcessed = FALSE;
                }

                for (uint256 i = poolStartIdx; i < poolEndIdx; i++) {
                    // for the current pool log add the reward to the stakeholder based
                    // on the partition of his funds in the pool's total funds
                    newlyCollectedRewards +=
                        (stakeholderFundsInPool *
                            s_poolLogs[poolIndex][i].poolReward) /
                        s_poolLogs[poolIndex][i].stakedInPool;
                }

                // update the index of the next log to read to the log after current last
                s_rewardOf[msg.sender].startIdxPerPool[poolIndex] = poolEndIdx;
            }
        }

        // if all the logs have been processed
        // update the last distribution time to the current time,
        // otherwise do not update distribution time as there are
        // more rewards to be distributed to the stakeholder
        if (TRUE == allLogsProcessed) {
            s_rewardOf[msg.sender].lastDistributionTime = block.timestamp;
        }

        // add the newly collected rewards to the stakeholders rewards
        s_rewardOf[msg.sender].amount += newlyCollectedRewards;

        // emit appropriate event
        emit DistributedDailyReward(msg.sender);
    }

    /**
     * @notice Distributes specific the uncollected rewards to caller based on pool logs, based on parameters
     * @param _user the stakeholder for whom the rewards will be computed
     * @param _plan the plan for whitch the reward will be computed
     * @param _tier the tier for whitch the reward will be computed
     * @param _noLogs the maximum number of logs to go through
     * @dev It is very similar to the distributeRewards, with the difference being
     * @dev that it only distributes a specific number of rewards for a specific user in a specific pool
     */
    function distributeRewardsSpecific(
        address _user,
        uint256 _plan,
        uint256 _tier,
        uint256 _noLogs
    ) public {
        // include all the new logs that happened in the meantime
        _computeReward();

        // if the caller is not a stakeholder return
        if (!s_stakeholders.contains(_user)) return;

        // if the caller has already collected all of the rewards return
        if (s_rewardOf[_user].lastDistributionTime >= s_lastPoolLogCreationTime)
            return;

        // convert to local variable to save up on gas cost
        uint256[NUM_POOLS]
            memory stakedByStakeholderPerPool = s_stakedPerStakeholderAndPool[
                _user
            ];

        // local variable to keep track of how much reward the stakeholder has collected
        uint256 newlyCollectedRewards = 0;

        // calculates linearized index of pool
        uint256 poolIndex = _plan * NUM_TIERS + _tier;

        uint256 stakeholderFundsInPool = stakedByStakeholderPerPool[poolIndex];

        // if stakeholder has nothing in pool, it will not affect reward
        if (0 != stakeholderFundsInPool) {
            // get the pool log range that should be processed
            uint256 poolStartIdx = s_rewardOf[_user].startIdxPerPool[poolIndex];
            uint256 poolEndIdx = poolStartIdx + _noLogs;

            if (poolEndIdx >= s_poolLogs[poolIndex].length) {
                // if it is the last batch, prevent out of bounds access
                poolEndIdx = s_poolLogs[poolIndex].length;
            }

            for (uint256 i = poolStartIdx; i < poolEndIdx; i++) {
                // for the current pool log add the reward to the stakeholder based
                // on the partition of his funds in the pool's total funds
                newlyCollectedRewards +=
                    (stakeholderFundsInPool *
                        s_poolLogs[poolIndex][i].poolReward) /
                    s_poolLogs[poolIndex][i].stakedInPool;
            }

            // update the index of the next log to read to the log after current last
            s_rewardOf[_user].startIdxPerPool[poolIndex] = poolEndIdx;
        }

        // add the newly collected rewards to the stakeholders rewards
        s_rewardOf[_user].amount += newlyCollectedRewards;

        // emit appropriate event
        emit DistributedDailyReward(_user);
    }

    /////////////////////////////////////
    //               Getters           //
    /////////////////////////////////////

    /// @inheritdoc IZNDStaking
    function getStake(uint256 _stakeId) external view returns (Stake memory) {
        Stake storage stake = s_stakes[_stakeId];

        if (stake.stakeholder == address(0)) revert Stake_DoesNotExist();

        return stake;
    }

    /// @inheritdoc IZNDStaking
    function getRewardAmount() external view returns (uint256) {
        if (!s_stakeholders.contains(msg.sender))
            revert Reward_NotAStakeholder();

        return s_rewardOf[msg.sender].amount;
    }

    /// @inheritdoc IZNDStaking
    function getRewardAmountOfAddress(
        address _address
    ) external view onlyCentralPlatform returns (uint256) {
        return s_rewardOf[_address].amount;
    }

    /// @inheritdoc IZNDStaking
    function getAmountStakedInPool(
        Tier _tier,
        Plan _plan
    ) external view returns (uint256) {
        return s_stakedPerPool[uint256(_plan) * NUM_TIERS + uint256(_tier)];
    }

    /////////////////////////////////////
    //               Setters           //
    /////////////////////////////////////

    /// @inheritdoc IZNDStaking
    function setDailyReward(uint256 _amount) external onlyCentralPlatform {
        _computeReward();

        s_dailyReward = _amount;

        emit DailyRewardChanged(_amount);
    }

    /// @inheritdoc IZNDStaking
    function setResetPointOffset(
        uint256 _newOffset
    ) external onlyCentralPlatform {
        if (s_totalStaked > 0) revert Parameters_PoolsAreNotEmpty();

        s_resetPointOffset = _newOffset;

        emit DailyRewardOffsetChanged(_newOffset);
    }

    //////////////////////////
    //  Internal Functions  //
    //////////////////////////

    // Creates any missing logs for all the pools based on the token stakings and withdrawals
    // that happened between the current block timestamp and `s_nextValidRewardComputationTime`.
    function _computeReward() internal {
        // if the computation has not been enabled by the platform, exit
        if (FALSE == s_rewardComputationStarted) return;

        // if already computed since the last reward computation reset, exit
        if (s_nextValidRewardComputationTime > block.timestamp) return;

        // if there is nothing to distribute, exit
        if (s_dailyReward == 0) return;

        // apply parameter changes if any have happened in the meantime
        _checkPendingBoostChanges();

        // calculates the number of rewards to be distributed,
        // in case some days have been missed (because the function
        // was not invoked), they will be calculated too
        uint256 rewardsToDistributeCount = 1 +
            (block.timestamp - s_nextValidRewardComputationTime) /
            1 days;

        // Calculates pool share and total share

        // set up local variables to track the total share of tokens in all pools,
        // share of tokens per pool, and reward per pool
        uint256 totalShare = 0;
        uint256[] memory poolShares = new uint256[](NUM_POOLS);
        uint256[NUM_POOLS] memory stakedPerPool = s_stakedPerPool;

        for (uint8 plan = 0; plan < NUM_PLANS; plan++) {
            for (uint8 tier = 0; tier < NUM_TIERS; tier++) {
                // calculates linearized index of pool
                uint256 poolIndex = plan * NUM_TIERS + tier;

                // if the pool is empty then the shares are also 0
                if (0 == stakedPerPool[poolIndex]) continue;

                // apply pool bonuses to the number of tokens
                uint256 sharesInPool = (stakedPerPool[poolIndex] *
                    s_planBoost[plan] *
                    s_tierBoost[tier]) / 10000;

                // save share calculation of the current pool
                poolShares[poolIndex] = sharesInPool;

                // add share of the current pool to the total share
                totalShare += sharesInPool;
            }
        }

        // if all shares are 0, there is no need to continue,
        // as no stakes will result in no rewards, just update
        // the timestamp for the next computation
        if (totalShare == 0) {
            // `block.timestamp - (block.timestamp % 1 days)` is midnight of the current day,
            // eg: if now is 10:36 am, this will be 10 hours and 36 minutes earlier
            // `+1 days` gets the next midnight, and then the offset is applied
            s_nextValidRewardComputationTime =
                block.timestamp -
                (block.timestamp % 1 days) +
                1 days +
                s_resetPointOffset;

            return;
        }

        // convert to a local variable to save up on gas costs
        uint256 dailyReward = s_dailyReward;

        // Log creation

        // stores a new pool log for each pool
        for (uint8 plan = 0; plan < NUM_PLANS; plan++) {
            for (uint8 tier = 0; tier < NUM_TIERS; tier++) {
                uint256 poolIndex = plan * NUM_TIERS + tier;
                uint256 sharesInPool = poolShares[poolIndex];

                // if the pool has no shares then its log will also contain
                // no stakes and no reward, hence it can be skipped
                if (sharesInPool == 0) continue;

                PoolLog memory poolLog;

                // for each pool calculate its reward based on the daily reward,
                // number of rewards to be distributed and the participation of the
                // current pool share in total share
                poolLog.poolReward =
                    (dailyReward * rewardsToDistributeCount * sharesInPool) /
                    totalShare;
                poolLog.stakedInPool = stakedPerPool[poolIndex];

                // store the log
                s_poolLogs[poolIndex].push(poolLog);

                // increase the number of existing logs for the pool
                s_existingPoolLogCount[poolIndex]++;
            }
        }

        // store the new last log creation timestamp
        s_lastPoolLogCreationTime = block.timestamp;

        // math has already been explained in the same function a few lines above
        s_nextValidRewardComputationTime =
            block.timestamp -
            (block.timestamp % 1 days) +
            1 days +
            s_resetPointOffset;

        // emit appropriate event
        emit ComputedDailyRewards();
    }

    function _stakeTokens(
        StakePayload memory _payload,
        uint256 _index
    ) internal returns (uint256 stakeId) {
        // create appropriate pool
        Pool memory pool = Pool({
            tier: Tier(_payload.tier),
            plan: Plan(_payload.plan)
        });

        // calculate stake id for the stake
        stakeId = s_nextStakeId + _index;

        // create and store Stake struct
        s_stakes[stakeId] = Stake(
            stakeId,
            _payload.amount,
            block.timestamp,
            msg.sender,
            pool
        );

        // increase the amount staked by the stakeholder in total
        s_stakedOf[msg.sender] += _payload.amount;

        // increase amount staked in appropriate pool
        s_stakedPerPool[_poolToIndex(pool)] += _payload.amount;

        // increase the amount staked by the stakeholder in appropriate pool
        s_stakedPerStakeholderAndPool[msg.sender][
            _poolToIndex(pool)
        ] += _payload.amount;

        // add stakeholder to the set of stakeholder if not already present
        if (s_stakeholders.add(msg.sender)) {
            s_rewardOf[msg.sender].startIdxPerPool = s_existingPoolLogCount;
            s_rewardOf[msg.sender].lastDistributionTime = block.timestamp;
        }

        return stakeId;
    }

    function _withdrawTokens(
        uint256 _stakeId,
        uint256 _amount
    ) internal returns (uint256 amountToWithdraw, uint256 penaltyFee) {
        // Check if any changes to parametrs should take effect
        _checkPendingPenaltyChanges();

        // storage pointer to the stake specified by stake id
        Stake storage stake = s_stakes[_stakeId];

        // revert if stake doesn't exist
        if (stake.stakeholder == address(0)) revert Stake_DoesNotExist();

        // revert if try to withdraw more than staked
        if (stake.amount < _amount) revert Stake_WithdrawInsufficientFunds();

        // revert if message sender is not owner of the stake
        if (msg.sender != stake.stakeholder) revert Stake_NotOwner();

        // set up local variables to track amount to withdraw and penalty fees for early withdrawal
        penaltyFee = 0;
        amountToWithdraw = _amount;

        // check if it's an early withdrawal
        if (_shouldApplyPenalty(stake.stakedAt, stake.pool.plan)) {
            // if yes apply penalty fee based on staking plan
            penaltyFee =
                (amountToWithdraw * s_penaltyFee[uint256(stake.pool.plan)]) /
                10_000;

            // lower the amount that will be withdrawn by penalty fee
            amountToWithdraw -= penaltyFee;
        }

        // decrease the amount staked by the stakeholder in total
        s_stakedOf[msg.sender] -= _amount;

        // decrease the amount of tokens staked in the pool from which withdraw
        s_stakedPerPool[_poolToIndex(stake.pool)] -= _amount;

        // decrease the amount staked by the stakeholder in appropriate pool
        s_stakedPerStakeholderAndPool[msg.sender][
            _poolToIndex(stake.pool)
        ] -= _amount;

        // if stakeholder does not have any funds staked anymore, remove the stakeholder
        // wrapped in require because of static analysis
        if (0 == s_stakedOf[msg.sender]) {
            require(s_stakeholders.remove(msg.sender));
        }

        // decrease amount of staked in the stake that's withdrawn from
        s_stakes[_stakeId].amount -= _amount;

        // if staked amount in stake is dropped to 0
        if (s_stakes[_stakeId].amount == 0) {
            // and delete stake struct
            delete s_stakes[_stakeId];
        }

        return (amountToWithdraw, penaltyFee);
    }

    // Function to check if a given timestamp is more than 'periodInDays' days ago.
    // In that case penalty should be applied.
    function _shouldApplyPenalty(
        uint256 timestampToCheck,
        Plan plan
    ) internal view returns (bool) {
        uint256 currentTimestamp = block.timestamp;

        uint256 periodInDays = s_planDuration[uint256(plan)];

        uint256 daysAgoTimestamp = currentTimestamp - (periodInDays * 1 days);

        return (timestampToCheck > daysAgoTimestamp);
    }

    function _poolToIndex(Pool memory pool) internal pure returns (uint256) {
        return uint256(pool.plan) * NUM_TIERS + uint256(pool.tier);
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
* @notice ERC20 token that implements EIP-2612 permit functionality.
* @notice Total supply of tokens is minted upon deployment and none of the tokens can be minted ever again.
* @notice Token owners can burn their tokens.
*/
contract ZNDToken is ERC20, Ownable2Step, ERC20Permit, ERC20Burnable {
    error RenouncingOwnershipIsDisabled();

    /**
     * @dev Initial and final supply of tokens. Tokens can not be minted after this contract is deployed.
     */
    uint256 constant public TOTAL_SUPPLY = 700_000_000;

    constructor() ERC20("ZNDToken", "ZND") ERC20Permit("ZNDToken") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY * 10 ** decimals());
    }

    /**
     * @notice Always reverts in order to prevent losing ownership.
     */
    function renounceOwnership() public view override onlyOwner {
        revert RenouncingOwnershipIsDisabled();
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import {ZNDParameters} from "./ZNDParameters.sol";
import {IZNDTreasury} from "./IZNDTreasury.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @notice Implements treasury related functionality.
 * @notice Enables funding of rewards and discretionary pools.
 * @notice Enables withdrawing from discretionary and fees pools.
 * @notice Implements vesting schedule and controls payouts to token recipients.
 */
contract ZNDTreasury is ZNDParameters, IZNDTreasury {
    using SafeERC20 for IERC20;

    using EnumerableSet for EnumerableSet.AddressSet;

    ///////////////////////////////////
    //     Treasury related accounts //
    ///////////////////////////////////

    // Discretionary payments withdrawal account
    address public s_withdrawalAccount;

    // Discretionary over-limit withdrawal account
    address public s_specialAccount;

    ///////////////////////////////////
    //     Treasury pool balances    //
    ///////////////////////////////////

    // Amount of ZND tokens in the rewards pool
    uint256 public s_rewardsPoolBalance;

    // Amount of ZND tokens in the fees pool
    uint256 public s_feesPoolBalance;

    // Amount of ZND tokens in the discretionary pool
    uint256 public s_discretionaryPoolBalance;

    // Struct which keeps track of vesting policy
    mapping(address => VestingData) private s_recipients;

    ///////////////////////////////////
    //     Treasury parameters       //
    ///////////////////////////////////

    /// @dev withdrawal limit for discretionary and fees pools
    uint256 public s_withdrawalLimit;

    ///////////////////////////////
    //         Modifiers         //
    ///////////////////////////////

    modifier onlyTreasuryAccount() {
        if (
            msg.sender != s_withdrawalAccount &&
            msg.sender != s_specialAccount &&
            msg.sender != owner()
        ) revert Treasury__NotTreasuryAccount();

        _;
    }

    ///////////////////////////////
    //         Constructor       //
    ///////////////////////////////

    /// @notice this will deploy the vesting table.
    constructor(
        address _zndPlatform,
        address _withdrawalAccount,
        address _specialAccount,
        uint256 _initialDiscretionaryPoolBalance,
        uint256 _initialRewardsPoolBalance,
        VestingPayload[] memory _vestingPayload
    ) ZNDParameters(_zndPlatform) {
        if (_withdrawalAccount == address(0)) revert Treasury__InvalidAddress();

        if (_specialAccount == address(0)) revert Treasury__InvalidAddress();

        if (_withdrawalAccount == owner())
            revert Treasury__WithdrawalAccountCanNotBeOwner();

        if (_withdrawalAccount == _specialAccount)
            revert Treasury__WithdrawalAccountCanNotBeSpecialAccount();

        if (_specialAccount == owner())
            revert Treasury__SpecialAccountCanNotBeOwner();

        s_withdrawalAccount = _withdrawalAccount;

        s_specialAccount = _specialAccount;

        s_discretionaryPoolBalance = _initialDiscretionaryPoolBalance;

        s_rewardsPoolBalance = _initialRewardsPoolBalance;

        // Vesting Policy Deployment

        for (uint256 i = 0; i < _vestingPayload.length; i++) {
            // get the vesting recipient
            address recipient = _vestingPayload[i].recipient;

            // cannot be special account
            if (recipient == _specialAccount)
                revert Treasury__SpecialAccountCanNotBeVestingRecipient();

            // also cannot be owner
            if (recipient == owner())
                revert Treasury__OwnerAccountCanNotBeVestingRecipient();

            // making sure the address is not duplicate,
            // if there was no initial unlock, and therefore `availableTokens`
            // are 0, there will be some non-0 number of unlocks left
            // on the other hand, if all the funds are meant to be available
            // immmediately, `availableTokens` will be non-0
            if (
                s_recipients[recipient].availableTokens > 0 ||
                s_recipients[recipient].numberOfUnlocksLeft > 0
            ) revert Treasury__DuplicateVestingAddress();

            uint256 amountToReceivePerUnlock = 0;

            if (_vestingPayload[i].numberOfDays > 0) {
                // making sure that quantity is divisible by number of days
                if (
                    _vestingPayload[i].quantityToUnlockOverTime %
                        _vestingPayload[i].numberOfDays >
                    0
                )
                    revert Treasury__QuantityUnlockOverTimeNotDivisibleByNumberOfDays();

                amountToReceivePerUnlock =
                    _vestingPayload[i].quantityToUnlockOverTime /
                    _vestingPayload[i].numberOfDays;
            }

            s_recipients[recipient] = VestingData({
                availableTokens: _vestingPayload[i].initialUnlock,
                numberOfUnlocksLeft: _vestingPayload[i].numberOfDays,
                amountToReceivePerUnlock: amountToReceivePerUnlock,
                nextUnlockTimestamp: block.timestamp +
                    _vestingPayload[i].cliffPeriodEnd
            });
        }
    }

    ///////////////////////////////////
    //      External Functions       //
    ///////////////////////////////////

    /// @inheritdoc IZNDTreasury
    function fundRewardsPool(uint256 _amount) external {
        s_rewardsPoolBalance += _amount;

        emit Treasury__Funding(msg.sender, _amount, TreasuryPool.RewardsPool);

        IERC20(s_zndToken).safeTransferFrom(msg.sender, address(this), _amount);
    }

    /// @inheritdoc IZNDTreasury
    function fundDiscretionaryPool(uint256 _amount) external {
        s_discretionaryPoolBalance += _amount;

        emit Treasury__Funding(
            msg.sender,
            _amount,
            TreasuryPool.DiscretionaryPool
        );

        IERC20(s_zndToken).safeTransferFrom(msg.sender, address(this), _amount);
    }

    /// @inheritdoc IZNDTreasury
    function withdrawFromDiscretionaryPool(
        address _to,
        uint256 _amount
    ) external onlyTreasuryAccount {
        _checkWithdrawalValidity(_amount);
        // amount is less than or equal limit, or the sender is owner or special account, execute payment

        // check available funds
        if (_amount > s_discretionaryPoolBalance)
            revert Treasury__InsufficientFunds();

        s_discretionaryPoolBalance -= _amount;

        emit Treasury__Withdrawal(
            msg.sender,
            _to,
            _amount,
            TreasuryPool.DiscretionaryPool
        );

        IERC20(s_zndToken).safeTransfer(_to, _amount);
    }

    /// @inheritdoc IZNDTreasury
    function withdrawFromFeesPool(
        address _to,
        uint256 _amount
    ) external onlyTreasuryAccount {
        _checkWithdrawalValidity(_amount);
        // amount is less than or equal limit, or the sender is owner or special account, execute payment

        // check available funds
        if (_amount > s_feesPoolBalance) revert Treasury__InsufficientFunds();

        s_feesPoolBalance -= _amount;

        emit Treasury__Withdrawal(
            msg.sender,
            _to,
            _amount,
            TreasuryPool.FeesPool
        );

        IERC20(s_zndToken).safeTransfer(_to, _amount);
    }

    /// @inheritdoc IZNDTreasury
    function setWithdrawLimit(uint256 _limit) external onlyOwner {
        s_withdrawalLimit = _limit;

        emit Treasury__WithdrawalLimitUpdated(msg.sender, _limit);
    }

    /// @inheritdoc IZNDTreasury
    function setWithdrawalAccount(address _account) external onlyOwner {
        if (_account == address(0)) revert Treasury__InvalidAddress();

        if (_account == owner())
            revert Treasury__WithdrawalAccountCanNotBeOwner();

        if (_account == s_specialAccount)
            revert Treasury__WithdrawalAccountCanNotBeSpecialAccount();

        s_withdrawalAccount = _account;

        emit Treasury__WithdrawalAccountUpdated(msg.sender, _account);
    }

    /// @inheritdoc IZNDTreasury
    function setSpecialAccount(address _account) external onlyOwner {
        if (_account == address(0)) revert Treasury__InvalidAddress();

        if (_account == owner()) revert Treasury__SpecialAccountCanNotBeOwner();

        if (_account == s_withdrawalAccount)
            revert Treasury__WithdrawalAccountCanNotBeSpecialAccount();

        s_specialAccount = _account;

        emit Treasury__SpecialAccountUpdated(msg.sender, _account);
    }

    /**
     * @notice Changes the owner of the contract.
     * @notice owner can not withdraw from vesting pool.
     * @notice owner can update parameters of the treasury.
     * @param _account address of the new owner.
     * @dev requires caller to be owner, reverts with OwnableUnauthorizedAccount error otherwise.
     * @dev requires account to be non zero address, reverts with Treasury__InvalidAddress error otherwise.
     * @dev requires account not to be special account, reverts with Treasury__SpecialAccountCanNotBeOwner error otherwise.
     * @dev requires account not to be regular account, reverts with Treasury__WithdrawalAccountCanNotBeOwner error otherwise.
     * @dev emits Treasury__OwnerUpdated event.
     */
    function transferOwnership(address _account) public override onlyOwner {
        if (_account == address(0)) revert Treasury__InvalidAddress();

        if (_account == s_specialAccount)
            revert Treasury__SpecialAccountCanNotBeOwner();

        if (_account == s_withdrawalAccount)
            revert Treasury__WithdrawalAccountCanNotBeOwner();

        super.transferOwnership(_account);
    }

    /**
     * @notice Always reverts in order to prevent losing ownership.
     */
    function renounceOwnership() public view override onlyOwner {
        revert Treasury__RenouncingOwnershipIsDisabled();
    }

    /// @inheritdoc IZNDTreasury
    function requestPayout(uint256 _amount) external returns (bool) {
        // Update recipients available tokens based on vesting policy for recipient
        VestingData memory recipientVestingPolicy = s_recipients[msg.sender];

        uint256 unlockCount = 0;
        uint256 lastUnlockTimestamp = recipientVestingPolicy
            .nextUnlockTimestamp;

        // if enough time has passed get the number of unlocks
        if (block.timestamp > lastUnlockTimestamp) {
            // since division floors, `+1` is necessary to get the corret unlockCount
            // e.g.: if one more hour than it's necessary for the next unlock
            // to occur has passed, that would give the `block.timestamp - lastUnlockTimestamp`
            // of 3600, and divided by 1 days, would be 0, even though enough time has passed
            unlockCount = (block.timestamp - lastUnlockTimestamp) / 1 days + 1;
        }

        // if there are unlocks, update the vesting data
        if (unlockCount > 0) {
            unlockCount = _min(
                unlockCount,
                recipientVestingPolicy.numberOfUnlocksLeft
            );

            // update the last unlocked timestamp
            s_recipients[msg.sender].nextUnlockTimestamp += (1 days *
                unlockCount);

            // update the number of unlocks left
            s_recipients[msg.sender].numberOfUnlocksLeft -= unlockCount;

            // update the available tokens
            s_recipients[msg.sender].availableTokens +=
                unlockCount *
                recipientVestingPolicy.amountToReceivePerUnlock;
        }

        // Transfer the requested amount to the recipient if the sufficient funds are available
        // if there are insufficient funds, stop the transaction with success flag set to false
        if (s_recipients[msg.sender].availableTokens < _amount) return false;

        s_recipients[msg.sender].availableTokens -= _amount;

        emit Treasury__VestingPayoutCompleted(msg.sender, _amount);

        // transfer the tokens to the recipient
        IERC20(s_zndToken).safeTransfer(msg.sender, _amount);

        // flag payout as a successful one
        return true;
    }

    /// @inheritdoc IZNDTreasury
    function getClaimableVestingAmount(
        address _address
    ) external view returns (uint256) {
        VestingData memory recipientVestingPolicy = s_recipients[_address];

        uint256 claimableTokenAmount = recipientVestingPolicy.availableTokens;
        uint256 unlockCount = 0;
        uint256 lastUnlockTimestamp = recipientVestingPolicy
            .nextUnlockTimestamp;

        // if enough time has passed get the number of unlocks
        if (block.timestamp > lastUnlockTimestamp) {
            // since division floors, `+1` is necessary to get the corret unlockCount
            // e.g.: if one more hour than it's necessary for the next unlock
            // to occur has passed, that would give the `block.timestamp - lastUnlockTimestamp`
            // of 3600, and divided by 1 days, would be 0, even though enough time has passed
            unlockCount = (block.timestamp - lastUnlockTimestamp) / 1 days + 1;
        }

        // if there are unlocks, add them to the claimable amount
        if (unlockCount > 0) {
            unlockCount = _min(
                unlockCount,
                recipientVestingPolicy.numberOfUnlocksLeft
            );

            claimableTokenAmount +=
                unlockCount *
                recipientVestingPolicy.amountToReceivePerUnlock;
        }

        return claimableTokenAmount;
    }

    ///////////////////////////////////////////
    //           Internal Functions          //
    ///////////////////////////////////////////

    function _checkWithdrawalValidity(uint256 _amount) internal view {
        // amount must be greater than 0
        if (_amount == 0) revert Treasury__AmountNotSpecified();

        // if amount is over withdrawal limit
        if (_amount > s_withdrawalLimit) {
            // check if caller is neither owner nor special account
            if (msg.sender != owner() && msg.sender != s_specialAccount) {
                // revert
                revert Treasury__OverLimitWithdrawalNotAllowed();
            }
        }
    }

    function _min(
        uint256 _first,
        uint256 _second
    ) internal pure returns (uint256) {
        return _first < _second ? _first : _second;
    }
}