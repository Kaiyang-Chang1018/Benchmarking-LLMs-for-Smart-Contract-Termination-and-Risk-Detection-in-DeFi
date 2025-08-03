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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
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
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

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

        (bool success,) = recipient.call{value: amount}("");
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
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata)
        internal
        view
        returns (bytes memory)
    {
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

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
 */
library MerkleProof {
    /**
     * @dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerify(bytes32[] memory proof, bool[] memory proofFlags, bytes32 root, bytes32[] memory leaves)
        internal
        pure
        returns (bool)
    {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
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
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(bytes32[] memory proof, bool[] memory proofFlags, bytes32[] memory leaves)
        internal
        pure
        returns (bytes32 merkleRoot)
    {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b =
                proofFlags[i] ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]) : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(bytes32[] calldata proof, bool[] calldata proofFlags, bytes32[] memory leaves)
        internal
        pure
        returns (bytes32 merkleRoot)
    {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b =
                proofFlags[i] ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]) : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IDragonX.sol";
import "./lib/FullMath.sol";
import "./lib/constants.sol";

contract SCALE is ERC20, Ownable2Step, IERC165 {
    using SafeERC20 for IERC20;

    // --------------------------- STATE VARIABLES --------------------------- //

    address public heliosVault;
    address public dragonXVault;
    address public devWallet;
    address public marketingWallet;
    address public shedContract;
    address public bdxBuyBurnAddress;

    /// @notice Basis point percentage of SCALE tokens sent to caller as a reward for calling distributeReserve.
    uint16 public incentiveFee = 30;

    /// @notice Basis point percentage of SCALE token reflections.
    uint16 public reflectionFee = 150;

    /// @notice Total SCALE tokens burned to date.
    uint256 public totalBurned;

    /// @notice Minimum size of the Reserve to be available for distribution.
    uint256 public minReserveDistribution = 1_000_000 * 10 ** 9;

    /// @notice <aximum size of the Reserve to be used for distribution.
    uint256 public maxReserveDistribution = 500_000_000 * 10 ** 9;

    /// @notice TitanX tokens allocated for ecosystem token purchases.
    uint256 public titanLpPool;

    /// @notice TitanX tokens used in ecosystem token purchases.
    uint256 public totalLpPoolUsed;

    /// @notice Scale tokens allocated for creation of the LPs.
    uint256 public scaleLpPool;

    /// @notice TitanX tokens allocated for swaps to DragonX and transfer to BDX Buy & Burn.
    uint256 public bdxBuyBurnPool;

    /// @notice DragonX tokens allocated for transfer to BDX Buy & Burn.
    uint256 public buyBurnDragonXAllocation;

    /// @notice Total LPs created.
    uint8 public totalLPsCreated;

    /// @notice Number of performed purchases for the BDX Buy & Burn.
    uint8 public buyBurnPurchases;

    /// @notice Number of purchases required for TitanX/DragonX & TitanX/BDX swaps.
    /// @dev Can only be changed before the presale is finalized.
    uint8 public purchasesRequired = 10;

    /// @notice Timestamp in seconds of the presale end date.
    uint256 public presaleEnd;

    /// @notice Has the presale been finalized.
    bool public presaleFinalized;

    /// @notice Have all token purchases for the LPs been performed.
    bool public lpPurchaseFinished;

    /// @notice Is trading enabled.
    bool public tradingEnabled;

    /// @notice Returns the total amount of ecosystem tokens purchased for LP creation for a specific token.
    mapping(address token => uint256) public tokenPool;

    /// @notice Total number of purchases performed per each ecosystem token.
    mapping(address token => uint8) public lpPurchases;

    /// @notice Percent of the lpPool to calculate the allocation per ecosystem token purchases.
    mapping(address token => uint8) public tokenLpPercent;

    uint256 private _totalMinted;
    bytes32 private _merkleRoot;

    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;
    mapping(address => bool) private _isExcludedFromReflections;
    address[] private _excluded;

    uint256 private _tTotal = 100 * 10 ** 12 * 10 ** 9;
    uint256 private _rTotal = (MAX_VALUE - (MAX_VALUE % _tTotal));

    // --------------------------- ERRORS --------------------------- //

    error ZeroInput();
    error ZeroAddress();
    error PresaleInactive();
    error PresaleActive();
    error MaxSupply();
    error TradingDisabled();
    error Prohibited();
    error DuplicateToken();
    error IncorrectPercentage();
    error IncorrectTokenNumber();
    error IncorrectBonus();
    error InsuffucientBalance();
    error ExcludedAddress();

    // ------------------------ EVENTS & MODIFIERS ----------------------- //

    event PresaleStarted();
    event TradingEnabled();
    event ReserveDistributed();

    modifier onlyPresale() {
        if (!isPresaleActive()) revert PresaleInactive();
        _;
    }

    // --------------------------- CONSTRUCTOR --------------------------- //

    constructor(
        address _owner,
        address _devWallet,
        address _marketingWallet,
        address _heliosVault,
        address _dragonxVault,
        address _bdxBuyBurnAddress,
        address[] memory _ecosystemTokens,
        uint8[] memory _lpPercentages
    ) ERC20("SCALE", "SCALE") Ownable(_owner) {
        if (_ecosystemTokens.length != NUM_ECOSYSTEM_TOKENS) revert IncorrectTokenNumber();
        if (_lpPercentages.length != NUM_ECOSYSTEM_TOKENS) revert IncorrectTokenNumber();
        if (_owner == address(0)) revert ZeroAddress();
        if (_devWallet == address(0)) revert ZeroAddress();
        if (_marketingWallet == address(0)) revert ZeroAddress();
        if (_heliosVault == address(0)) revert ZeroAddress();
        if (_dragonxVault == address(0)) revert ZeroAddress();
        if (_bdxBuyBurnAddress == address(0)) revert ZeroAddress();

        _rOwned[address(this)] = _rTotal;
        devWallet = _devWallet;
        marketingWallet = _marketingWallet;
        heliosVault = _heliosVault;
        dragonXVault = _dragonxVault;
        bdxBuyBurnAddress = _bdxBuyBurnAddress;

        uint8 totalPercentage;
        for (uint256 i = 0; i < _ecosystemTokens.length; i++) {
            address token = _ecosystemTokens[i];
            uint8 allocation = _lpPercentages[i];
            if (token == address(0)) revert ZeroAddress();
            if (allocation == 0) revert ZeroInput();
            if (tokenLpPercent[token] != 0) revert DuplicateToken();
            tokenLpPercent[token] = allocation;
            totalPercentage += allocation;
        }
        if (totalPercentage != 100) revert IncorrectPercentage();
    }

    // --------------------------- PUBLIC FUNCTIONS --------------------------- //

    /// @notice Allows users to mint tokens during the presale using TitanX tokens.
    /// @param amount The amount of SCALE tokens to mint.
    /// @param bonus Bonus percentage for the user.
    /// @param merkleProof Proof for the user.
    function mintWithTitanX(uint256 amount, uint16 bonus, bytes32[] memory merkleProof) external onlyPresale {
        if (amount == 0) revert ZeroInput();
        IERC20(TITANX).safeTransferFrom(msg.sender, address(this), amount * 10 ** 9);
        amount = _processBonus(amount, bonus, merkleProof);
        if ((_totalMinted + amount) * 135 / 100 > _tTotal) revert MaxSupply();
        _rMint(msg.sender, amount);
    }

    /// @notice Allows users to purchase tokens during the presale using ETH.
    /// @param amount The amount of SCALE tokens to mint.
    /// @param bonus Bonus percentage for the user.
    /// @param merkleProof Proof for the user.
    /// @param deadline Deadline for executing the swap.
    function mintWithETH(uint256 amount, uint16 bonus, bytes32[] memory merkleProof, uint256 deadline)
        external
        payable
        onlyPresale
    {
        if (amount == 0) revert ZeroInput();
        uint256 titanXAmount = amount * 10 ** 9;
        uint256 swappedAmount = _swapETHForTitanX(titanXAmount, deadline);
        if (swappedAmount > titanXAmount) IERC20(TITANX).safeTransfer(msg.sender, swappedAmount - titanXAmount);
        amount = _processBonus(amount, bonus, merkleProof);
        if ((_totalMinted + amount) * 135 / 100 > _tTotal) revert MaxSupply();
        _rMint(msg.sender, amount);
    }

    /// @notice Burns SCALE from user's wallet.
    /// @param amount The amount of SCALE tokens to burn.
    function burn(uint256 amount) public {
        if (!tradingEnabled) revert TradingDisabled();
        _rBurn(msg.sender, amount);
    }

    /// @notice Reflects SCALE tokens to all holders from user's wallet.
    /// @param amount The amount of SCALE tokens to reflect.
    function reflect(uint256 amount) public {
        if (!tradingEnabled) revert TradingDisabled();
        address sender = msg.sender;
        if (_isExcludedFromReflections[sender]) revert ExcludedAddress();
        uint256 rAmount = amount * _getRate();
        _balanceCheck(sender, rAmount, amount);
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
    }

    /// @notice Distributes the accumulated reserve.
    /// @param minDragonXAmount The minimum amount of DragonX tokens received for BDX Buy & Burn.
    /// @param deadline Deadline for executing the swap.
    function distributeReserve(uint256 minDragonXAmount, uint256 deadline) external {
        if (!tradingEnabled) revert TradingDisabled();
        uint256 balance = balanceOf(address(this));
        if (balance < minReserveDistribution) revert InsuffucientBalance();
        uint256 distribution = balance > maxReserveDistribution ? maxReserveDistribution : balance;
        distribution = _processIncentiveFee(msg.sender, distribution);

        uint256 buyBurnShare = distribution / 2;
        _swapScaleToDragonX(buyBurnShare, minDragonXAmount, deadline);

        uint256 quarter = distribution / 4;

        uint256 rTransferAmount = reflectionFromToken(quarter);
        _rOwned[address(this)] -= rTransferAmount;
        _rOwned[marketingWallet] += rTransferAmount;
        if (_isExcludedFromReflections[marketingWallet]) _tOwned[marketingWallet] += quarter;
        _rBurn(address(this), quarter);
        emit ReserveDistributed();
    }

    // --------------------------- PRESALE MANAGEMENT FUNCTIONS --------------------------- //

    /// @notice Starts the presale for the SCALE token.
    function startPresale() external onlyOwner {
        if (presaleEnd != 0) revert Prohibited();
        if (_merkleRoot == bytes32(0)) revert IncorrectBonus();
        unchecked {
            presaleEnd = block.timestamp + PRESALE_LENGTH;
        }
        emit PresaleStarted();
    }

    /// @notice Finalizes the presale and distributes liquidity pool tokens.
    function finalizePresale() external onlyOwner {
        if (presaleEnd == 0) revert PresaleInactive();
        if (isPresaleActive()) revert PresaleActive();
        if (shedContract == address(0)) revert ZeroAddress();
        if (presaleFinalized) revert Prohibited();

        _distributeTokens();

        // burn not minted
        uint256 tBurn = _tTotal - _totalMinted - scaleLpPool;
        uint256 rBurn = tBurn * _getRate();
        _rOwned[address(this)] -= rBurn;
        _rTotal -= rBurn;
        _tTotal = _totalMinted + scaleLpPool;

        presaleFinalized = true;
        emit Transfer(address(0), address(this), scaleLpPool);
    }

    /// @notice Allows the owner to purchase tokens for liquidity pool allocation.
    /// @param token The address of the token to purchase.
    /// @param minAmountOut The minimum amount of tokens to receive from the swap.
    /// @param deadline The deadline for the swap transaction.
    function purchaseTokenForLP(address token, uint256 minAmountOut, uint256 deadline) external onlyOwner {
        if (!presaleFinalized) revert PresaleActive();
        if (lpPurchaseFinished) revert Prohibited();
        uint256 requiredAmount = token == BDX_ADDRESS ? purchasesRequired : 1;
        if (lpPurchases[token] == requiredAmount) revert Prohibited();
        uint256 allocation = tokenLpPercent[token];
        if (allocation == 0) revert Prohibited();
        uint256 amountToSwap = FullMath.mulDiv(titanLpPool, allocation, 100 * requiredAmount);
        totalLpPoolUsed += amountToSwap;
        uint256 swappedAmount = _swapTitanXToToken(token, amountToSwap, minAmountOut, deadline);
        unchecked {
            tokenPool[token] += swappedAmount;
            lpPurchases[token]++;
            // account for rounding error
            if (totalLpPoolUsed >= titanLpPool - NUM_ECOSYSTEM_TOKENS - purchasesRequired) lpPurchaseFinished = true;
        }
    }

    /// @notice Allows the owner to purchase DragonX tokens for the BDX Buy & Burn contract.
    /// @param minAmountOut The minimum amount of DragonX tokens to receive from the swap.
    /// @param deadline The deadline for the swap transaction.
    function purchaseDragonXForBuyBurn(uint256 minAmountOut, uint256 deadline) external onlyOwner {
        if (!presaleFinalized) revert PresaleActive();
        if (buyBurnPurchases == purchasesRequired) revert Prohibited();

        uint256 amountToSwap = bdxBuyBurnPool / purchasesRequired;
        uint256 swappedAmount = _swapTitanXToToken(DRAGONX_ADDRESS, amountToSwap, minAmountOut, deadline);
        unchecked {
            buyBurnDragonXAllocation += swappedAmount;
            buyBurnPurchases++;
        }
        if (buyBurnPurchases == purchasesRequired) {
            IERC20(DRAGONX_ADDRESS).safeTransfer(bdxBuyBurnAddress, buyBurnDragonXAllocation);
        }
    }

    /// @notice Deploys a liquidity pool for SCALE tokens paired with another token.
    /// @param tokenAddress The address of the token to pair with SCALE in the liquidity pool.
    function deployLiquidityPool(address tokenAddress) external onlyOwner {
        if (!lpPurchaseFinished) revert Prohibited();
        uint256 tokenAmount = tokenPool[tokenAddress];
        if (tokenAmount == 0) revert Prohibited();
        uint256 scaleAllocation = FullMath.mulDiv(scaleLpPool, tokenLpPercent[tokenAddress], 100);

        _addLiquidity(tokenAddress, tokenAmount, scaleAllocation);
        tokenPool[tokenAddress] = 0;
        unchecked {
            totalLPsCreated++;
        }
        if (totalLPsCreated == NUM_ECOSYSTEM_TOKENS) _enableTrading();
    }

    /// @notice Claim any leftover dust from divisions when performing TitanX swaps.
    /// @dev Can only be claimed after all purchases have been made.
    function claimDust() external onlyOwner {
        if (!tradingEnabled || buyBurnPurchases != purchasesRequired) revert Prohibited();
        IERC20 titanX = IERC20(TITANX);
        titanX.safeTransfer(msg.sender, titanX.balanceOf(address(this)));
    }

    // --------------------------- ADMINISTRATIVE FUNCTIONS --------------------------- //

    /// @notice Excludes the account from receiving reflections.
    /// @param account Address of the account to be excluded.
    function excludeAccountFromReflections(address account) public onlyOwner {
        if (_isExcludedFromReflections[account]) revert ExcludedAddress();
        if (_excluded.length == 22) revert Prohibited();
        if (account == address(this)) revert Prohibited();
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReflections[account] = true;
        _excluded.push(account);
    }

    /// @notice Includes the account back to receiving reflections.
    /// @param account Address of the account to be included.
    function includeAccountToReflections(address account) public onlyOwner {
        if (!_isExcludedFromReflections[account]) revert ExcludedAddress();
        uint256 difference = _rOwned[account] - (_getRate() * _tOwned[account]);
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _rOwned[account] -= difference;
                _rTotal -= difference;
                _isExcludedFromReflections[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    /// @notice Sets the amount of purchases for tokens.
    /// @param amount Number of purchases needed for each token.
    /// @dev Can only be called by the owner before presale if finalized.
    function setPurchasesRequired(uint8 amount) external onlyOwner {
        if (amount == 0) revert ZeroInput();
        if (amount > 50) revert Prohibited();
        if (presaleFinalized) revert Prohibited();
        purchasesRequired = amount;
    }

    /// @notice Sets the DragonX Vault address.
    /// @param _address The address of the DragonX Vault.
    /// @dev Can only be called by the owner.
    function setDragonXVault(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        dragonXVault = _address;
    }

    /// @notice Sets the Helios Vault address.
    /// @param _address The address of the Helios Vault.
    /// @dev Can only be called by the owner.
    function setHeliosVault(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        heliosVault = _address;
    }

    /// @notice Sets the Developer wallet address.
    /// @param _address The address of the Developer wallet.
    /// @dev Can only be called by the owner.
    function setDevWallet(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        devWallet = _address;
    }

    /// @notice Sets the Marketing wallet address.
    /// @param _address The address of the Marketing wallet.
    /// @dev Can only be called by the owner.
    function setMarketingWallet(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        marketingWallet = _address;
    }

    /// @notice Sets the SHED contract address.
    /// @param _address The address of the SHED contract.
    /// @dev Can only be called by the owner.
    function setSHED(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        shedContract = _address;
    }

    /// @notice Sets the BDX Buy & Burn contract address.
    /// @param _address The address of the BDX Buy & Burn contract.
    /// @dev Can only be called by the owner.
    function setBDXBuyBurn(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        bdxBuyBurnAddress = _address;
    }

    /// @notice Sets the merkle root for minting bonuses.
    /// @param root The merkle root.
    /// @dev Can only be called by the owner.
    function setMerkleRoot(bytes32 root) external onlyOwner {
        if (root == bytes32(0)) revert ZeroInput();
        _merkleRoot = root;
    }

    /// @notice Sets the reflection fee size.
    /// @param bps Reflection fee in basis points (150 = 1.5%).
    /// @dev Can only be called by the owner.
    function setReflectionFee(uint16 bps) external onlyOwner {
        if (bps != 150 && bps != 300 && bps != 450 && bps != 600) revert Prohibited();
        reflectionFee = bps;
    }

    /// @notice Sets the Incentive fee size.
    /// @param bps Incentive fee in basis points (30 = 0.3%).
    /// @dev Can only be called by the owner.
    function setIncentiveFee(uint16 bps) external onlyOwner {
        if (bps < 30 || bps > 500) revert Prohibited();
        incentiveFee = bps;
    }

    /// @notice Sets the minimum Reserve distribution size.
    /// @param limit Reserve limit size.
    /// @dev Can only be called by the owner.
    function setMinReserveDistribution(uint256 limit) external onlyOwner {
        if (limit < 100 || limit > maxReserveDistribution) revert Prohibited();
        minReserveDistribution = limit;
    }

    /// @notice Sets the maximum Reserve distribution size.
    /// @param limit Reserve limit size.
    /// @dev Can only be called by the owner.
    function setMaxReserveDistribution(uint256 limit) external onlyOwner {
        if (limit < minReserveDistribution || limit > _tTotal) revert Prohibited();
        maxReserveDistribution = limit;
    }

    // --------------------------- VIEW FUNCTIONS --------------------------- //

    /// @notice Checks if the presale is currently active.
    /// @return A boolean indicating whether the presale is active.
    function isPresaleActive() public view returns (bool) {
        return presaleEnd > block.timestamp;
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function totalSupply() public view override returns (uint256) {
        if (!presaleFinalized) return _totalMinted;
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (!presaleFinalized && account == address(this)) return 0;
        if (_isExcludedFromReflections[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcludedFromReflections[account];
    }

    function reflectionFromToken(uint256 tAmount) public view returns (uint256) {
        if (tAmount > _tTotal) revert MaxSupply();
        uint256 rAmount = tAmount * _getRate();
        return rAmount;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        if (rAmount > _rTotal) revert MaxSupply();
        return rAmount / _getRate();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC20).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    // --------------------------- INTERNAL FUNCTIONS --------------------------- //

    function _processBonus(uint256 amount, uint16 bonus, bytes32[] memory merkleProof)
        internal
        view
        returns (uint256)
    {
        if (bonus > 0) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, bonus));
            if (!MerkleProof.verify(merkleProof, _merkleRoot, leaf)) revert IncorrectBonus();
            uint256 bonusAmount = amount * bonus / 10000;
            amount += bonusAmount;
        }
        return amount;
    }

    function _processIncentiveFee(address receiver, uint256 amount) internal returns (uint256) {
        uint256 rValue = reflectionFromToken(amount);
        uint256 rIncentive = FullMath.mulDiv(rValue, incentiveFee, 10000);
        uint256 tIncentive = FullMath.mulDiv(amount, incentiveFee, 10000);
        _rOwned[address(this)] -= rIncentive;
        _rOwned[receiver] += rIncentive;
        if (_isExcludedFromReflections[receiver]) _tOwned[receiver] += tIncentive;
        return amount - tIncentive;
    }

    function _distributeTokens() internal {
        IERC20 titanX = IERC20(TITANX);
        uint256 availableTitanX = titanX.balanceOf(address(this));
        titanLpPool = availableTitanX * LP_POOL_PERCENT / 100;
        scaleLpPool = titanLpPool / 10 ** 9;
        bdxBuyBurnPool = availableTitanX * BDX_BUY_BURN_PERCENT / 100;
        uint256 dragonVaultAmount = availableTitanX * DRAGONX_VAULT_PERCENT / 100;
        uint256 heliosVaultAmount = availableTitanX * HELIOS_VAULT_PERCENT / 100;
        uint256 devAmount = availableTitanX * DEV_PERCENT / 100;
        uint256 genesisAmount = availableTitanX * GENESIS_PERCENT / 100;
        uint256 shedAmount = availableTitanX - titanLpPool - bdxBuyBurnPool - dragonVaultAmount - heliosVaultAmount
            - devAmount - genesisAmount;

        titanX.safeTransfer(dragonXVault, dragonVaultAmount);
        titanX.safeTransfer(heliosVault, heliosVaultAmount);
        titanX.safeTransfer(devWallet, devAmount);
        titanX.safeTransfer(owner(), genesisAmount);
        titanX.safeTransfer(shedContract, shedAmount);
        IDragonX(dragonXVault).updateVault();
    }

    function _addLiquidity(address tokenAddress, uint256 tokenAmount, uint256 scaleAmount) internal {
        (uint256 pairBalance, address pairAddress) = _checkPoolValidity(tokenAddress);
        if (pairBalance > 0) _fixPool(pairAddress, tokenAmount, scaleAmount, pairBalance);

        if (tokenAddress == BDX_ADDRESS) {
            if (pairAddress == address(0)) {
                pairAddress = IUniswapV2Factory(UNISWAP_V2_FACTORY).createPair(address(this), tokenAddress);
            }
            excludeAccountFromReflections(pairAddress);
        }
        if (pairBalance > 0) {
            _update(address(this), pairAddress, scaleAmount);
            IERC20(tokenAddress).transfer(pairAddress, tokenAmount);
            IUniswapV2Pair(pairAddress).mint(address(0));
        } else {
            IERC20(address(this)).safeIncreaseAllowance(UNISWAP_V2_ROUTER, scaleAmount);
            IERC20(tokenAddress).safeIncreaseAllowance(UNISWAP_V2_ROUTER, tokenAmount);
            IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(
                address(this),
                tokenAddress,
                scaleAmount,
                tokenAmount,
                scaleAmount,
                tokenAmount,
                address(0), //send governance tokens directly to zero address
                block.timestamp
            );
        }
    }

    function _checkPoolValidity(address target) internal returns (uint256, address) {
        address pairAddress = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(address(this), target);
        if (pairAddress == address(0)) return (0, pairAddress);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        pair.skim(owner());
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        if (reserve0 != 0) return (reserve0, pairAddress);
        if (reserve1 != 0) return (reserve1, pairAddress);
        return (0, pairAddress);
    }

    function _fixPool(address pairAddress, uint256 tokenAmount, uint256 scaleAmount, uint256 currentBalance) internal {
        uint256 requiredScale = currentBalance * scaleAmount / tokenAmount;
        if (requiredScale == 0) requiredScale = 1;
        uint256 rAmount = requiredScale * _getRate();
        _rOwned[pairAddress] += rAmount;
        if (_isExcludedFromReflections[pairAddress]) _tOwned[pairAddress] += requiredScale;
        _rTotal += rAmount;
        _tTotal += requiredScale;
        emit Transfer(address(0), pairAddress, requiredScale);
        IUniswapV2Pair(pairAddress).sync();
    }

    function _enableTrading() internal {
        tradingEnabled = true;
        emit TradingEnabled();
    }

    // --------------------------- SWAP FUNCTIONS --------------------------- //

    function _swapETHForTitanX(uint256 minAmountOut, uint256 deadline) internal returns (uint256) {
        IWETH9(WETH9).deposit{value: msg.value}();

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH9,
            tokenOut: TITANX,
            fee: POOL_FEE_1PERCENT,
            recipient: address(this),
            deadline: deadline,
            amountIn: msg.value,
            amountOutMinimum: minAmountOut,
            sqrtPriceLimitX96: 0
        });
        IERC20(WETH9).safeIncreaseAllowance(UNISWAP_V3_ROUTER, msg.value);
        uint256 amountOut = ISwapRouter(UNISWAP_V3_ROUTER).exactInputSingle(params);
        return amountOut;
    }

    function _swapScaleToDragonX(uint256 amountIn, uint256 minAmountOut, uint256 deadline) internal {
        IERC20(address(this)).safeIncreaseAllowance(UNISWAP_V2_ROUTER, amountIn);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = DRAGONX_ADDRESS;

        IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, minAmountOut, path, bdxBuyBurnAddress, deadline
        );
    }

    function _swapTitanXToToken(address outputToken, uint256 amount, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256)
    {
        if (outputToken == DRAGONX_ADDRESS) return _swapUniswapV3Pool(outputToken, amount, minAmountOut, deadline);
        if (outputToken == E280_ADDRESS) return _swapUniswapV2Pool(outputToken, amount, minAmountOut, deadline);
        return _swapMultihop(outputToken, DRAGONX_ADDRESS, amount, minAmountOut, deadline);
    }

    function _swapUniswapV3Pool(address outputToken, uint256 amountIn, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256)
    {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: TITANX,
            tokenOut: outputToken,
            fee: POOL_FEE_1PERCENT,
            recipient: address(this),
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: minAmountOut,
            sqrtPriceLimitX96: 0
        });
        IERC20(TITANX).safeIncreaseAllowance(UNISWAP_V3_ROUTER, amountIn);
        uint256 amountOut = ISwapRouter(UNISWAP_V3_ROUTER).exactInputSingle(params);
        return amountOut;
    }

    function _swapUniswapV2Pool(address outputToken, uint256 amountIn, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256)
    {
        IERC20(TITANX).safeIncreaseAllowance(UNISWAP_V2_ROUTER, amountIn);
        uint256 previous = IERC20(outputToken).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = TITANX;
        path[1] = outputToken;

        IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, minAmountOut, path, address(this), deadline
        );

        return IERC20(outputToken).balanceOf(address(this)) - previous;
    }

    function _swapMultihop(
        address outputToken,
        address midToken,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) internal returns (uint256) {
        bytes memory path = abi.encodePacked(TITANX, POOL_FEE_1PERCENT, midToken, POOL_FEE_1PERCENT, outputToken);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: minAmountOut
        });
        IERC20(TITANX).safeIncreaseAllowance(UNISWAP_V3_ROUTER, amountIn);
        uint256 amoutOut = ISwapRouter(UNISWAP_V3_ROUTER).exactInput(params);
        return amoutOut;
    }

    // --------------------------- REFLECTIONS FUNCTIONS --------------------------- //

    function _rMint(address account, uint256 tAmount) internal {
        uint256 rAmount = tAmount * _getRate();
        _rOwned[address(this)] -= rAmount;
        _rOwned[msg.sender] += rAmount;
        if (_isExcludedFromReflections[account]) _tOwned[msg.sender] += tAmount;
        _totalMinted += tAmount;
        emit Transfer(address(0), account, tAmount);
    }

    function _rBurn(address account, uint256 tAmount) internal {
        uint256 rBurn = tAmount * _getRate();
        _balanceCheck(account, rBurn, tAmount);
        _rOwned[account] -= rBurn;
        if (_isExcludedFromReflections[account]) _tOwned[account] -= tAmount;
        _rTotal -= rBurn;
        _tTotal -= tAmount;
        totalBurned += tAmount;
        emit Transfer(account, address(0), tAmount);
    }

    function _update(address from, address to, uint256 value) internal override {
        if (tradingEnabled) {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rReserve, uint256 tTransferAmount) =
                _getValues(value);
            _balanceCheck(from, rAmount, value);
            _rOwned[from] -= rAmount;
            if (_isExcludedFromReflections[from]) _tOwned[from] -= value;
            _rOwned[to] += rTransferAmount;
            if (_isExcludedFromReflections[to]) _tOwned[to] += tTransferAmount;
            _rOwned[address(this)] += rReserve;
            _reflectFee(rFee);
            emit Transfer(from, to, tTransferAmount);
        } else {
            if (from != address(this)) revert TradingDisabled();
            // no fees during LP deployment
            uint256 rValue = value * _getRate();
            _rOwned[from] -= rValue;
            _rOwned[to] += rValue;
            if (_isExcludedFromReflections[to]) _tOwned[to] += value;
            emit Transfer(from, to, value);
        }
    }

    function _balanceCheck(address from, uint256 rAmount, uint256 value) internal view {
        uint256 fromBalance = _rOwned[from];
        if (fromBalance < rAmount) {
            revert ERC20InsufficientBalance(from, tokenFromReflection(fromBalance), value);
        }
    }

    function _reflectFee(uint256 rFee) private {
        _rTotal -= rFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tReserve) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rReserve) =
            _getRValues(tAmount, tFee, tReserve, currentRate);
        return (rAmount, rTransferAmount, rFee, rReserve, tTransferAmount);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = FullMath.mulDivRoundingUp(tAmount, reflectionFee, 10000);
        uint256 tReserve = tAmount / 100;
        uint256 tTransferAmount = tAmount - tFee - tReserve;
        return (tTransferAmount, tFee, tReserve);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tReserve, uint256 currentRate)
        private
        pure
        returns (uint256, uint256, uint256, uint256)
    {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rReserve = tReserve * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rReserve;
        return (rAmount, rTransferAmount, rFee, rReserve);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            address account = _excluded[i];
            uint256 rValue = _rOwned[account];
            uint256 tValue = _tOwned[account];
            if (rValue > rSupply || tValue > tSupply) return (_rTotal, _tTotal);
            rSupply -= rValue;
            tSupply -= tValue;
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDragonX {
    function updateVault() external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (0 - denominator) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ===================== Contract Addresses =====================================
uint8 constant NUM_ECOSYSTEM_TOKENS = 5;

address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant TITANX = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant DRAGONX_ADDRESS = 0x96a5399D07896f757Bd4c6eF56461F58DB951862;
address constant BDX_ADDRESS = 0x9f278Dc799BbC61ecB8e5Fb8035cbfA29803623B;
address constant HYDRA_ADDRESS = 0xCC7ed2ab6c3396DdBc4316D2d7C1b59ff9d2091F;
address constant E280_ADDRESS = 0xe9A53C43a0B58706e67341C4055de861e29Ee943;

address constant DRAGONX_HYDRA_POOL = 0xF8F0Ef9f6A12336A1e035adDDbD634F3B0962F54;
address constant TITANX_DRAGONX_POOL = 0x25215d9ba4403b3DA77ce50606b54577a71b7895;

// ===================== Presale ================================================
uint256 constant MAX_VALUE = ~uint256(0);
uint256 constant PRESALE_LENGTH = 14 days;

// ===================== Presale Allocations ====================================
uint256 constant LP_POOL_PERCENT = 35;
uint256 constant BDX_BUY_BURN_PERCENT = 35;
uint256 constant DRAGONX_VAULT_PERCENT = 5;
uint256 constant HELIOS_VAULT_PERCENT = 5;
uint256 constant SHED_PERCENT = 11;
uint256 constant DEV_PERCENT = 8;
uint256 constant GENESIS_PERCENT = 1;

// ===================== HYDRA Interface ========================================
uint256 constant START_MAX_MINT_COST = 1e11 ether;
uint256 constant MAX_MINT_POWER_CAP = 10_000;
uint256 constant MAX_MINT_LENGTH = 88;
uint256 constant MAX_MINT_PER_WALLET = 1000;
uint8 constant MAX_AVAILABLE_MINERS = 20;
uint8 constant MIN_AVAILABLE_MINERS = 4;

// ===================== UNISWAP Interface ======================================

address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
uint24 constant POOL_FEE_1PERCENT = 10000;