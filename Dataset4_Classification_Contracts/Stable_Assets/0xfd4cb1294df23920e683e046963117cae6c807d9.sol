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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "../libs/constant.sol";

/**
 * @title BurnInfo
 * @dev this contract is meant to be inherited into main contract
 * @notice It has the variables and functions specifically for tracking burn amount and reward
 */

abstract contract BurnInfo {
    //Variables
    //track the total Shogun burn amount
    uint256 private s_totalShogunBurned;

    //mappings
    //track wallet address -> total Shogun burn amount
    mapping(address => uint256) private s_userBurnAmount;
    //track contract/project address -> total Shogun burn amount
    mapping(address => uint256) private s_project_BurnAmount;
    //track contract/project address, wallet address -> total Shogun burn amount
    mapping(address => mapping(address => uint256)) private s_projectUser_BurnAmount;

    //events
    /** @dev log user burn Shogun event
     * project can be address(0) if user burns Shogun directly from Shogun contract
     */
    event ShogunBurned(address indexed user, address indexed project, uint256 amount);

    //functions
    /** @dev update the burn amount
     * @param user wallet address
     * @param project contract address
     * @param amount Shogun amount burned
     */
    function _updateBurnAmount(address user, address project, uint256 amount) internal {
        s_userBurnAmount[user] += amount;
        s_totalShogunBurned += amount;

        if (project != address(0)) {
            s_project_BurnAmount[project] += amount;
            s_projectUser_BurnAmount[project][user] += amount;
        }

        emit ShogunBurned(user, project, amount);
    }

    //views
    /** @notice return total burned Shogun amount from all users burn or projects burn
     * @return totalBurnAmount returns entire burned Shogun
     */
    function getTotalBurnTotal() public view returns (uint256) {
        return s_totalShogunBurned;
    }

    /** @notice return user address total burned Shogun
     * @return userBurnAmount returns user address total burned Shogun
     */
    function getUserBurnTotal(address user) public view returns (uint256) {
        return s_userBurnAmount[user];
    }

    /** @notice return project address total burned Shogun amount
     * @return projectTotalBurnAmount returns project total burned Shogun
     */
    function getProjectBurnTotal(address contractAddress) public view returns (uint256) {
        return s_project_BurnAmount[contractAddress];
    }

    /** @notice return user address total burned Shogun amount via a project address
     * @param contractAddress project address
     * @param user user address
     * @return projectUserTotalBurnAmount returns user address total burned Shogun via a project address
     */
    function getProjectUserBurnTotal(
        address contractAddress,
        address user
    ) public view returns (uint256) {
        return s_projectUser_BurnAmount[contractAddress][user];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "../libs/constant.sol";

import "../interfaces/IShogunBnB.sol";

error Shogun_InvalidRange();

abstract contract GlobalInfo {
    //Variables
    //deployed timestamp
    uint256 private immutable i_genesisTs;

    /** @dev track current contract day */
    uint256 private s_currentContractDay;

    /** @dev track current daily auction supply in phase 2 */
    uint256 private s_currentAuctionSupply;

    /** @dev track current amount for next perpetual auction supply in phase 2 */
    uint256 private s_currentWarChestSupply;

    //*********** Auction Variables ***********/
    /** @dev track user total amount for each daily cycle
     * s_userCycleAmount[address][1] = 300 = day 1 300
     * s_userCycleAmount[address][2] = 500 = day 2 500
     * */
    mapping(address => mapping(uint256 => uint256)) s_userCycleAmount;

    /** @dev track auction total amount for each daily cycle
     * s_cycleTotal[1] = 30000
     * s_cycleTotal[2] = 60000
     */
    mapping(uint256 => uint256) private s_cycleTotal;

    /** @dev track auction supply per share for each daily cycle
     * s_cycleSupplyPerShare[1] = 10
     * s_cycleSupplyPerShare[2] = 8
     */
    mapping(uint256 => uint256) private s_cycleSupplyPerShare;

    /** @dev track user start auction claim index
     * so calculation would start from current index
     * [address] = 1
     */
    mapping(address => uint256) private s_userStartAuctionClaimIndex;

    //structs
    struct CycleAuctionInfo {
        uint256 day;
        uint256 amount;
        uint256 reward;
    }

    //event
    event GlobalDailyUpdateStats(uint256 indexed day, uint256 indexed auctionSupply);
    event CalculatedAuctionSupplyPerShare(uint256 indexed day, uint256 indexed supplyPerShare);

    /** @dev Update variables in terms of day, modifier is used in all external/public functions (exclude view)
     * Every interaction to the contract would run this function to update variables
     */
    modifier dailyUpdate(address bnbAddress) {
        _dailyUpdate(bnbAddress);
        _;
    }

    constructor() {
        i_genesisTs = block.timestamp;
        s_currentContractDay = 1;
        s_currentAuctionSupply = INITIAL_PHASE_DAILY_AUCTION_SUPPLY;
    }

    /** @dev calculate and update variables daily */
    function _dailyUpdate(address bnbAddress) private {
        uint256 currentContractDay = s_currentContractDay;
        uint256 currentBlockDay = ((block.timestamp - i_genesisTs) / 1 days) + 1;

        if (currentBlockDay > currentContractDay) {
            //calculate previous cycle SupplyPerShare
            if (currentContractDay < 28) {
                _calculateCycleSupplyPerShare(
                    currentContractDay,
                    INITIAL_PHASE_DAILY_AUCTION_SUPPLY
                );

                emit GlobalDailyUpdateStats(currentBlockDay, INITIAL_PHASE_DAILY_AUCTION_SUPPLY);
            } else {
                _calculateCycleSupplyPerShare(currentContractDay, s_currentAuctionSupply);

                uint256 newAuctionSupply = (s_currentWarChestSupply *
                    PHASE_2_DAILY_AUCTION_SUPPLY_PERCENT) / PERCENT_BPS;
                s_currentAuctionSupply = newAuctionSupply;
                s_currentWarChestSupply -= newAuctionSupply;

                emit GlobalDailyUpdateStats(currentBlockDay, newAuctionSupply);
            }

            s_currentContractDay = currentBlockDay;
            IShogunBnB(bnbAddress).dailyUpdate(); //update BnB daily funds
        }
    }

    /******* Auction functions *******/
    /** @dev calculate supply per share on a given contract day
     * @param contractDay contract day
     * @param auctionSupply auction supply
     */
    function _calculateCycleSupplyPerShare(uint256 contractDay, uint256 auctionSupply) internal {
        uint256 supplyPerShare;
        uint256 totalAmount = s_cycleTotal[contractDay];

        if (totalAmount != 0) {
            supplyPerShare = (auctionSupply * 1 ether) / totalAmount;
            s_cycleSupplyPerShare[contractDay] = supplyPerShare;
        }

        emit CalculatedAuctionSupplyPerShare(contractDay, supplyPerShare);
    }

    /** @dev update cylce user amount and total amount based on current contract day
     * @param user address
     * @param amount amount
     */
    function _updateCycleAmount(address user, uint256 amount) internal {
        uint256 currentContractDay = getCurrentContractDay();

        //only new user will need to init claim index
        //set claim index to start from current contract day
        if (s_userStartAuctionClaimIndex[user] == 0) {
            s_userStartAuctionClaimIndex[user] = currentContractDay;
        }

        //update user amount and total amount in current cycle
        s_userCycleAmount[user][currentContractDay] += amount;
        s_cycleTotal[currentContractDay] += amount;
    }

    /** @dev update to the last index where a user has claimed the auction
     * @param user user address
     */
    function _updateUserAuctionClaimIndex(address user) internal {
        s_userStartAuctionClaimIndex[user] = getCurrentContractDay();
    }

    /** @dev increase War Chest supply from buy and burn or a % from transfer tax
     * @param amount amount to increase
     */
    function _AddWarChestSupply(uint256 amount) internal {
        s_currentWarChestSupply += amount;
    }

    /** Views */
    /** @notice Returns current contract day
     * @return currentContractDay current contract day
     */
    function getCurrentContractDay() public view returns (uint256) {
        return s_currentContractDay;
    }

    /** @notice Returns current auction supply
     * @return current auction supply
     */
    function getCurrentAuctionSupply() public view returns (uint256) {
        return s_currentAuctionSupply;
    }

    /** @notice Returns current War Chest supply
     * @return current War Chest supply
     */
    function getCurrentWarChestSupply() public view returns (uint256) {
        return s_currentWarChestSupply;
    }

    /** @notice Returns contract deployment block timestamp
     * @return genesisTs deployed timestamp
     */
    function genesisTs() public view returns (uint256) {
        return i_genesisTs;
    }

    /** @notice Returns the calculated supply per share for a given contract day as index
     * @param index cycle index
     * @return supplyPerShare
     */
    function getSupplyPerShare(uint256 index) public view returns (uint256) {
        return s_cycleSupplyPerShare[index];
    }

    /** @notice Returns total amount in a given daily cycle
     * * @param day day
     * @return total amount
     */
    function getCycleTotalAmount(uint256 day) public view returns (uint256) {
        return s_cycleTotal[day];
    }

    /** @notice Returns user total amount in a given daily cycle
     * @param user user address
     * * @param day day
     * @return total amount
     */
    function getUserCycleAmount(address user, uint256 day) public view returns (uint256) {
        return s_userCycleAmount[user][day];
    }

    /** @notice Returns user's start claim index
     * @param user user address
     * @return cycleIndex cycle index
     */
    function getUserStartAuctionClaimIndex(address user) public view returns (uint256) {
        return s_userStartAuctionClaimIndex[user];
    }

    /** @notice Returns user total unclaim auction supply from user's start claim index
     * @param user address
     * @return claimableSupply total unclaim amount
     */
    function getUserClaimableAuctionSupply(
        address user
    ) public view returns (uint256 claimableSupply) {
        uint256 startClaimIndex = s_userStartAuctionClaimIndex[user];
        uint256 maxContractDay = getCurrentContractDay();
        for (uint256 i = startClaimIndex; i < maxContractDay; i++) {
            claimableSupply += s_userCycleAmount[user][i] * s_cycleSupplyPerShare[i];
        }

        //supplyPerShare has 18 decimals scaling, so here divide by 18 decimals
        if (claimableSupply != 0) claimableSupply /= 1 ether;
    }

    /** @notice return a list of user auction info based on input range (contract start and end day)
     * the list will return real time auction amount (current contract day) and past cycles' auction reward
     * @param startDay start day
     * @param endDay end day
     */
    function getUserAuctionInfo(
        address user,
        uint256 startDay,
        uint256 endDay
    ) public view returns (CycleAuctionInfo[] memory cycleAuctionInfo) {
        if (startDay > endDay) revert Shogun_InvalidRange();
        uint256 currentContractDay = getCurrentContractDay();
        endDay = endDay > currentContractDay ? currentContractDay : endDay;

        uint256 index = 0;
        cycleAuctionInfo = new CycleAuctionInfo[](endDay - startDay + 1);

        for (uint256 i = startDay; i <= endDay; i++) {
            uint256 amount = s_userCycleAmount[user][i];
            cycleAuctionInfo[index++] = CycleAuctionInfo({
                day: i,
                amount: amount,
                reward: (amount * s_cycleSupplyPerShare[i]) / 1 ether
            });
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../interfaces/ITITANX.sol";
import "../interfaces/ITitanBurn.sol";
import "../interfaces/ITitanOnBurn.sol";
import "../interfaces/IShogunOnBurn.sol";
import "../interfaces/IShogun.sol";
import "../interfaces/IX28.sol";

import "./GlobalInfo.sol";
import "./BurnInfo.sol";

//custom errors
error Shogun_NotSupportedContract();
error Shogun_NotAllowed();
error Shogun_InvalidBurnRewardPercent();
error Shogun_LPTokensHasMinted();
error Shogun_InvalidAddress();
error Shogun_UnregisteredCA();
error Shogun_NoSupplyToClaim();
error Shogun_NoAllowance();
error Shogun_NotEnoughBalance();
error Shogun_BurnStakeClosed();
error Shogun_CannotZero();

/** @title Shogun */
contract Shogun is ERC20, ReentrancyGuard, GlobalInfo, BurnInfo, Ownable, ITitanOnBurn {
    /** Storage Variables*/
    /** @dev stores genesis wallet address */
    address private s_genesisAddress;

    /** @dev stores LP wallet address */
    address private s_lPAddress;

    /** @dev stores buy and burn contract address */
    address private s_buyAndBurnAddress;

    /** @dev tracks total amount of X28 deposited */
    uint256 s_totalX28Deposited;

    /** @dev tracks total amount of X28 burned */
    uint256 s_totalX28Burned;

    /** @dev tracks total amount of TitanX deposited */
    uint256 s_totalTitanXDeposited;

    /** @dev tracks total amount of TitanX burned */
    uint256 s_totalTitanXBurned;

    /** @dev tracks total amount of Shogun burned from tax */
    uint256 s_totalShogunTaxBurned;

    /** @dev Tracks Shogun buy and burn contract addresses status
     * Specifically used for burning Shogun in registered CA */
    mapping(address => bool) s_buyAndBurnAddressRegistry;

    /** @dev track addresses to exclude from transfer tax */
    mapping(address => bool) private s_taxExclusionList;

    /** @dev tracks if initial LP tokens has minted or not */
    bool private s_initialLPMinted;

    event AuctionEntered(address indexed user, uint256 indexed day, uint256 indexed amount);
    event AuctionSupplyClaimed(address indexed user, uint256 indexed amount);

    constructor(
        address genesisAddress,
        address lPAddress,
        address buyAndBurnAddress
    ) Ownable(msg.sender) ERC20("SHOGUN", "SHOGUN") {
        if (genesisAddress == address(0)) revert Shogun_InvalidAddress();
        if (lPAddress == address(0)) revert Shogun_InvalidAddress();
        if (buyAndBurnAddress == address(0)) revert Shogun_InvalidAddress();
        s_genesisAddress = genesisAddress;
        s_lPAddress = lPAddress;
        s_buyAndBurnAddress = buyAndBurnAddress;
        s_buyAndBurnAddressRegistry[buyAndBurnAddress] = true;
        s_taxExclusionList[buyAndBurnAddress] = true;
        s_taxExclusionList[lPAddress] = true;
        s_taxExclusionList[address(0)] = true;
        _mint(s_lPAddress, LP_WALLET_TOKENS);
    }

    /** @notice add given address to be excluded from transfer tax. Only callable by owner address.
     * @param addr address
     */
    function addTaxExclusionAddress(address addr) external onlyOwner {
        if (addr == address(0)) revert Shogun_InvalidAddress();
        s_taxExclusionList[addr] = true;
    }

    /** @notice remove given address to be excluded from transfer tax. Only callable by owner address.
     * @param addr address
     */
    function removeTaxExclusionAddress(address addr) external onlyOwner {
        if (addr == address(0)) revert Shogun_InvalidAddress();
        s_taxExclusionList[addr] = false;
    }

    /** @notice Set BuyAndBurn Contract Address.
     * Only owner can call this function
     * @param contractAddress BuyAndBurn contract address
     */
    function setBuyAndBurnContractAddress(address contractAddress) external onlyOwner {
        /* Only able to change to supported buyandburn contract address.
         * Also prevents owner from registering EOA address into s_buyAndBurnAddressRegistry and call burnCAShogun to burn user's tokens.
         */
        if (
            !IERC165(contractAddress).supportsInterface(IERC165.supportsInterface.selector) ||
            !IERC165(contractAddress).supportsInterface(type(IShogun).interfaceId)
        ) revert Shogun_NotSupportedContract();
        s_buyAndBurnAddress = contractAddress;
        s_buyAndBurnAddressRegistry[contractAddress] = true;
        s_taxExclusionList[contractAddress] = true;
    }

    /** @notice Set to new genesis wallet. Only genesis wallet can call this function
     * @param newAddress new genesis wallet address
     */
    function setNewGenesisAddress(address newAddress) external {
        if (msg.sender != s_genesisAddress) revert Shogun_NotAllowed();
        if (newAddress == address(0)) revert Shogun_InvalidAddress();
        s_genesisAddress = newAddress;
    }

    /** @notice Set to new LP wallet. Only LP wallet can call this function
     * @param newAddress new LP wallet address
     */
    function setNewLPAddress(address newAddress) external {
        if (msg.sender != s_lPAddress) revert Shogun_NotAllowed();
        if (newAddress == address(0)) revert Shogun_InvalidAddress();
        s_lPAddress = newAddress;
        s_taxExclusionList[newAddress] = true;
    }

    /** @notice mint initial LP tokens. Only BuyAndBurn contract set by owner can call this function
     */
    function mintLPTokens() external {
        if (msg.sender != s_buyAndBurnAddress) revert Shogun_NotAllowed();
        if (s_initialLPMinted) revert Shogun_LPTokensHasMinted();
        s_initialLPMinted = true;
        _mint(s_buyAndBurnAddress, INITAL_LP_TOKENS);
    }

    /** @notice burn Shogun in BuyAndBurn contract.
     * Only burns registered contract address
     * % to LP wallet, % to War Chest supply (stored in variable), burn all tokens except LP tokens
     */
    function burnCAShogun(address contractAddress) external dailyUpdate(s_buyAndBurnAddress) {
        if (!s_buyAndBurnAddressRegistry[contractAddress]) revert Shogun_UnregisteredCA();

        uint256 totalAmount = balanceOf(contractAddress);
        uint256 lPAmount = (totalAmount * SHOGUN_LP_PERCENT) / PERCENT_BPS;
        uint256 warChestAmount = (totalAmount * SHOGUN_WARCHEST_PERCENT) / PERCENT_BPS;
        super._update(contractAddress, address(0), totalAmount - lPAmount); //burn including war chest supply
        super._update(contractAddress, s_lPAddress, lPAmount); //LP supply
        _AddWarChestSupply(warChestAmount);
    }

    /** @notice enter auction using liquid X28
     * % burned, % to LP address, % to genesis address, % to B&B contract
     * @param amount TitanX amount
     */
    function enterAuctionX28Liquid(
        uint256 amount
    ) external dailyUpdate(s_buyAndBurnAddress) nonReentrant {
        if (amount == 0) revert Shogun_CannotZero();

        //transfer burn amount to X28 BNB, call public burnCAX28() to burn X28
        uint256 burnAmount = (amount * BURN_PERCENT) / PERCENT_BPS;
        IX28(X28).transferFrom(msg.sender, X28_BNB, burnAmount);
        IX28(X28).burnCAX28(X28_BNB);

        //transfer LP amount to LP address
        uint256 lPAmount = (amount * LP_PERCENT) / PERCENT_BPS;
        IX28(X28).transferFrom(msg.sender, s_lPAddress, lPAmount);

        //transfer genesis amount to genesis address
        uint256 genesisAmount = (amount * GENESIS_PERCENT) / PERCENT_BPS;
        IX28(X28).transferFrom(msg.sender, s_genesisAddress, genesisAmount);

        //transfer BnB amount to BnB contract
        IX28(X28).transferFrom(
            msg.sender,
            s_buyAndBurnAddress,
            amount - burnAmount - lPAmount - genesisAmount
        );

        _updateCycleAmount(msg.sender, amount);
        s_totalX28Deposited += amount;
        s_totalX28Burned += burnAmount;

        emit AuctionEntered(msg.sender, getCurrentContractDay(), amount);
    }

    /** @notice enter auction using TitanX stakes (up to 28 at once)
     * same amount of staked TitanX as liquid is required to burn stake
     * % burned, % to LP address, % to genesis address, % to B&B contract
     * 8% burn dev reward to BnB contract
     * credit 2x amount in current auction
     * @param stakeId User TitanX stake Ids
     */
    function enterAuctionTitanXStake(
        uint256[] calldata stakeId
    ) external dailyUpdate(s_buyAndBurnAddress) nonReentrant {
        if (getCurrentContractDay() > 28) revert Shogun_BurnStakeClosed();
        if (ITITANX(TITANX_CA).allowanceBurnStakes(msg.sender, address(this)) < stakeId.length)
            revert Shogun_NoAllowance();

        uint256 amount;
        uint256 claimCount;
        for (uint256 i = 0; i < stakeId.length; i++) {
            ITITANX.UserStakeInfo memory info = ITITANX(TITANX_CA).getUserStakeInfo(
                msg.sender,
                stakeId[i]
            );

            if (info.status == ITITANX.StakeStatus.ACTIVE && info.titanAmount != 0) {
                ITitanBurn(TITANX_CA).burnStakeToPayAddress(
                    msg.sender,
                    stakeId[i],
                    0,
                    8,
                    s_buyAndBurnAddress
                );
                amount += info.titanAmount;
                ++claimCount;
            }
            if (claimCount == MAX_BATCH_BURN_COUNT) break;
        }
        if (ITITANX(TITANX_CA).balanceOf(msg.sender) < amount) revert Shogun_NotEnoughBalance();

        //transfer burn amount to TitanX BNBV2, call public burnLPTokens() to burn TitanX
        uint256 burnAmount = (amount * BURN_PERCENT) / PERCENT_BPS;
        ITITANX(TITANX_CA).transferFrom(msg.sender, TITANX_BNBV2, burnAmount);
        ITITANX(TITANX_CA).burnLPTokens();

        //transfer LP amount to LP address
        uint256 lPAmount = (amount * LP_PERCENT) / PERCENT_BPS;
        ITITANX(TITANX_CA).transferFrom(msg.sender, s_lPAddress, lPAmount);

        //transfer genesis amount to genesis address
        uint256 genesisAmount = (amount * GENESIS_PERCENT) / PERCENT_BPS;
        ITITANX(TITANX_CA).transferFrom(msg.sender, s_genesisAddress, genesisAmount);

        //transfer BnB amount to BnB contract
        ITITANX(TITANX_CA).transferFrom(
            msg.sender,
            s_buyAndBurnAddress,
            amount - burnAmount - lPAmount - genesisAmount
        );

        uint256 totalCreditAmount = amount * 2;
        _updateCycleAmount(msg.sender, totalCreditAmount);
        s_totalTitanXDeposited += totalCreditAmount;
        s_totalTitanXBurned += burnAmount + amount; //100% staked amount burned + 20% liquid burned

        emit AuctionEntered(msg.sender, getCurrentContractDay(), totalCreditAmount);
    }

    /** @notice claim available auction supply (accumulate if past auctions was not claimed) */
    function claimUserAuction() external dailyUpdate(s_buyAndBurnAddress) nonReentrant {
        uint256 claimableSupply = getUserClaimableAuctionSupply(msg.sender);
        if (claimableSupply == 0) revert Shogun_NoSupplyToClaim();

        _updateUserAuctionClaimIndex(msg.sender);
        _mint(msg.sender, claimableSupply);

        emit AuctionSupplyClaimed(msg.sender, claimableSupply);
    }

    /** @notice callback function from TitanX contract after burn.
     * do nothing
     * @param user wallet address
     * @param amount burned Titan X amount
     */
    function onBurn(address user, uint256 amount) external {}

    //private functions
    /** @dev override ERC20 update for tax logic
     * add to tax exlusion list to avoid tax logic
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        if (s_taxExclusionList[from] || s_taxExclusionList[to]) {
            super._update(from, to, value);
            return;
        }

        uint256 taxAmount = (value * TRANSFER_TAX_PERCENT) / PERCENT_BPS;
        uint256 lPAmount = (taxAmount * SHOGUN_LP_PERCENT) / PERCENT_BPS;
        uint256 warChestAmount = (taxAmount * SHOGUN_WARCHEST_PERCENT) / PERCENT_BPS;
        super._update(from, address(0), taxAmount - lPAmount); //burn including war chest supply
        super._update(from, s_lPAddress, lPAmount); //LP supply
        super._update(from, to, value - taxAmount); //transfer taxed amount
        _AddWarChestSupply(warChestAmount);
        s_totalShogunTaxBurned += taxAmount - lPAmount - warChestAmount;
    }

    /** @dev burn liquid Shogun through other project.
     * called by other contracts for proof of burn 2.0 with up to 8% for both builder fee and user rebate
     * @param user user address
     * @param amount liquid Shogun amount
     * @param userRebatePercentage percentage for user rebate in liquid Shogun (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Shogun (0 - 8)
     * @param rewardPaybackAddress builder can opt to receive fee in another address
     */
    function _burnLiquidShogun(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) private {
        _spendAllowance(user, msg.sender, amount);
        _burnbefore(userRebatePercentage, rewardPaybackPercentage);
        _burn(user, amount);
        _burnAfter(
            user,
            amount,
            userRebatePercentage,
            rewardPaybackPercentage,
            rewardPaybackAddress
        );
    }

    /** @dev perform checks before burning starts.
     * check reward percentage and check if called by supported contract
     * @param userRebatePercentage percentage for user rebate
     * @param rewardPaybackPercentage percentage for builder fee
     */
    function _burnbefore(
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage
    ) private view {
        if (rewardPaybackPercentage + userRebatePercentage > MAX_BURN_REWARD_PERCENT)
            revert Shogun_InvalidBurnRewardPercent();

        //Only supported contracts is allowed to call this function
        if (
            !IERC165(msg.sender).supportsInterface(IERC165.supportsInterface.selector) ||
            !IERC165(msg.sender).supportsInterface(type(IShogunOnBurn).interfaceId)
        ) revert Shogun_NotSupportedContract();
    }

    /** @dev update burn stats and mint reward to builder or user if applicable
     * @param user user address
     * @param amount Shogun amount burned
     * @param userRebatePercentage percentage for user rebate in liquid Shogun (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Shogun (0 - 8)
     * @param rewardPaybackAddress builder can opt to receive fee in another address
     */
    function _burnAfter(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) private {
        _updateBurnAmount(user, msg.sender, amount);

        uint256 devFee;
        uint256 userRebate;
        if (rewardPaybackPercentage != 0) devFee = (amount * rewardPaybackPercentage) / 100;
        if (userRebatePercentage != 0) userRebate = (amount * userRebatePercentage) / 100;

        if (devFee != 0) _mint(rewardPaybackAddress, devFee);
        if (userRebate != 0) _mint(user, userRebate);

        IShogunOnBurn(msg.sender).onBurn(user, amount);
    }

    //Views
    /** @notice Returns true/false of the given interfaceId
     * @param interfaceId interface id
     * @return bool true/false
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == IERC165.supportsInterface.selector ||
            interfaceId == type(ITitanOnBurn).interfaceId;
    }

    /** @notice Returns current genesis wallet address
     * @return address current genesis wallet address
     */
    function getGenesisAddress() public view returns (address) {
        return s_genesisAddress;
    }

    /** @notice Returns current LP wallet address
     * @return address current LP wallet address
     */
    function getLPAddress() public view returns (address) {
        return s_lPAddress;
    }

    /** @notice Returns current buy and burn contract address
     * @return address current buy and burn contract address
     */
    function getBuyAndBurnAddress() public view returns (address) {
        return s_buyAndBurnAddress;
    }

    /** @notice Returns status of the given address
     * @return true/false
     */
    function getBuyAndBurnAddressRegistry(address contractAddress) public view returns (bool) {
        return s_buyAndBurnAddressRegistry[contractAddress];
    }

    /** @notice Returns status of the given address if it's excluded from transfer tax
     * @return true/false
     */
    function isAddressTaxExcluded(address user) public view returns (bool) {
        return s_taxExclusionList[user];
    }

    /** @notice Returns total X28 deposited
     * @return amount
     */
    function getTotalX28Deposited() public view returns (uint256) {
        return s_totalX28Deposited;
    }

    /** @notice Returns total TitanX burned from deposit
     * @return amount
     */
    function getTotalX28BurnedFromDeposits() public view returns (uint256) {
        return s_totalX28Burned;
    }

    /** @notice Returns total TitanX deposited
     * @return amount
     */
    function getTotalTitanXDeposited() public view returns (uint256) {
        return s_totalTitanXDeposited;
    }

    /** @notice Returns total TitanX burned from deposit
     * @return amount
     */
    function getTotalTitanXBurnedFromDeposits() public view returns (uint256) {
        return s_totalTitanXBurned;
    }

    /** @notice Returns total Shogun burned from tax
     * @return amount
     */
    function getTotalShogunBurnedFromTax() public view returns (uint256) {
        return s_totalShogunTaxBurned;
    }

    //Public functions for devs to intergrate with Shogun
    /** @notice allow anyone to sync dailyUpdate manually */
    function manualDailyUpdate() public dailyUpdate(s_buyAndBurnAddress) {}

    /** @notice Burn Shogun tokens and creates Proof-Of-Burn record to be used by connected DeFi and fee is paid to specified address
     * @param user user address
     * @param amount Shogun amount
     * @param userRebatePercentage percentage for user rebate in liquid Shogun (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Shogun (0 - 8)
     * @param rewardPaybackAddress builder can opt to receive fee in another address
     */
    function burnTokensToPayAddress(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) public nonReentrant dailyUpdate(s_buyAndBurnAddress) {
        _burnLiquidShogun(
            user,
            amount,
            userRebatePercentage,
            rewardPaybackPercentage,
            rewardPaybackAddress
        );
    }

    /** @notice Burn Shogun tokens and creates Proof-Of-Burn record to be used by connected DeFi and fee is paid to specified address
     * @param user user address
     * @param amount Shogun amount
     * @param userRebatePercentage percentage for user rebate in liquid Shogun (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Shogun (0 - 8)
     */
    function burnTokens(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage
    ) public nonReentrant dailyUpdate(s_buyAndBurnAddress) {
        _burnLiquidShogun(user, amount, userRebatePercentage, rewardPaybackPercentage, msg.sender);
    }

    /** @notice allows user to burn liquid Shogun directly from contract
     * @param amount Shogun amount
     */
    function userBurnTokens(uint256 amount) public nonReentrant dailyUpdate(s_buyAndBurnAddress) {
        _burn(msg.sender, amount);
        _updateBurnAmount(msg.sender, address(0), amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IShogun {
    function mintLPTokens() external;

    function burnCAShogun(address contractAddress) external;

    function genesisTs() external returns (uint256);

    function getGenesisAddress() external returns (address);

    function getLPAddress() external returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IShogunBnB {
    function dailyUpdate() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IShogunOnBurn {
    function onBurn(address user, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITITANX is IERC20 {
    enum StakeStatus {
        ACTIVE,
        ENDED,
        BURNED
    }

    struct UserStakeInfo {
        uint152 titanAmount;
        uint128 shares;
        uint16 numOfDays;
        uint48 stakeStartTs;
        uint48 maturityTs;
        StakeStatus status;
    }

    function startMint(uint256 mintPower, uint256 numOfDays) external payable;

    function batchMint(uint256 mintPower, uint256 numOfDays, uint256 count) external payable;

    function claimMint(uint256 id) external;

    function batchClaimMint() external;

    function startStake(uint256 amount, uint256 numOfDays) external;

    function getUserStakeInfo(address user, uint256 id) external returns (UserStakeInfo memory);

    function approveBurnStakes(address spender, uint256 amount) external returns (bool);

    function allowanceBurnStakes(address user, address spender) external view returns (uint256);

    function burnLPTokens() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface ITitanBurn {
    function burnTokens(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage
    ) external;

    function burnTokensToPayAddress(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) external;

    function burnMint(address userAddress, uint256 id) external;

    function burnStake(
        address userAddress,
        uint256 id,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage
    ) external;

    function burnStakeToPayAddress(
        address userAddress,
        uint256 id,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface ITitanOnBurn {
    function onBurn(address user, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IX28 is IERC20 {
    function mintX28withTitanX(uint256 amount) external;

    function burnCAX28(address contractAddress) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

address constant TITANX_CA = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant TITANX_BNBV2 = 0x410e10C33a49279f78CB99c8d816F18D5e7D5404;

address constant X28 = 0x5c47902c8C80779CB99235E42C354E53F38C3B0d;
address constant X28_BNB = 0xa3144E7FCceD79Ce6ff6E14AE9d8DF229417A7a2;

// ===================== Shogun ==========================================
uint256 constant GENESIS_PERCENT = 5_00;
uint256 constant BURN_PERCENT = 20_00;
uint256 constant LP_PERCENT = 22_00;
uint256 constant BNB_PERCENT = 53_00;

uint256 constant TRANSFER_TAX_PERCENT = 8_00;

uint256 constant SHOGUN_BURN_PERCENT = 28_00;
uint256 constant SHOGUN_LP_PERCENT = 8_00;
uint256 constant SHOGUN_WARCHEST_PERCENT = 64_00;

uint256 constant PERCENT_BPS = 100_00;

uint256 constant INITAL_LP_TOKENS = 1_000_000 ether;
uint256 constant LP_WALLET_TOKENS = 100_000_000 ether;

// ===================== AuctionInfo ==========================================
uint256 constant INITIAL_PHASE_DAILY_AUCTION_SUPPLY = 100_000_000 ether;
uint256 constant PHASE_2_DAILY_AUCTION_SUPPLY_PERCENT = 8_00;

uint256 constant MAX_BATCH_BURN_COUNT = 28;

// ===================== BurnInfo ==========================================
uint256 constant MAX_BURN_REWARD_PERCENT = 8;