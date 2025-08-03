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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


error Whispr_InvalidWalletAddress(address invalidWallet);
error Whispr_InvalidPairAddress(address invalidPair);
error Whispr_InvalidRouterAddress(address invalidRouter);
error Whispr_CannotTransfer(uint8 code);
error Whispr_InvalidFeeAmount(uint256 fee, uint256 maxFee);
error Whispr_InvalidSplit(uint8 errorTotal);
error Whispr_InvalidMaxTxAmount();
error Whispr_MaxTx();
error Whispr_TradingAlreadyEnabled();
error Whispr_TradingNotYetEnabled(uint256 blockNumber);


contract WhisprToken is ERC20, Ownable, ReentrancyGuard {
    uint256 public constant FEE_BASIS = 100;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromLimit;
    mapping(address => bool) public isPair;
    uint256 public feeOnBuy = 5;
    uint256 public feeOnSell = 5;
    uint256 public swapThreshold;
    uint256 public maxTxAmount;
    bool public tradingEnabled = false;

    IUniswapV2Router02 public router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public immutable WETH;
    address public tradingFundWallet;
    address public devWallet;
    address public uniswapV2Pair;

    uint8 public tradingFundPercent = 3;
    uint8 public devPercent = 2;
    uint8 public totalPercent = 5;
    bool private swapping;

    // events
    event TradingFundWalletUpdate(
        address indexed previousTradingFundWallet,
        address indexed newTradingFundWallet
    );
    event DevWalletUpdate(
        address indexed previousDevWallet,
        address indexed newDevWallet
    );
    event PairUpdate(address indexed previousPair, address indexed newPair);
    event RouterUpdate(
        address indexed previousRouter,
        address indexed newRouter
    );
    event InvalidTransfer(address indexed to, uint256 ETHvalue);
    event UpdateExcludedStatus(address indexed wallet, bool status);
    event UpdateLimitStatus(address indexed wallet, bool status);
    event UpdateBuyFee(uint256 prevFee, uint256 fee);
    event UpdateSellFee(uint256 prevFee, uint256 fee);
    event UpdateThreshold(uint256 prevThreshold, uint256 threshold);
    event UpdateFeeSplit(
        uint8 tradingFundShares,
        uint8 devShares,
        uint8 totalShares
    );
    event MaxTxUpdate(uint256 prevMaxTx, uint256 newMaxTx);
    event TradingEnabled(uint256 blockNumber);

    constructor(address _tradingFundWallet, address _devWallet)
        ERC20("Whispr", "WHISPR")
        Ownable(msg.sender)
    {
        super._update(address(0), msg.sender, 1_000_000_000 ether);
        maxTxAmount = totalSupply() / 100; // 1% of total supply
        tradingFundWallet = _tradingFundWallet;
        devWallet = _devWallet;
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        WETH = router.WETH();
        uniswapV2Pair = factory.createPair(address(this), WETH);
        isPair[uniswapV2Pair] = true;
        swapThreshold = totalSupply() / 5_000;
        // Exclude from fees
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        // Exclude from limits
        isExcludedFromLimit[msg.sender] = true;
        isExcludedFromLimit[address(this)] = true;
        isExcludedFromLimit[DEAD] = true;
        isExcludedFromLimit[uniswapV2Pair] = true;
        isExcludedFromFee[devWallet] = true;
        isExcludedFromFee[tradingFundWallet] = true;
        _approve(address(this), address(router), type(uint256).max);
    }

    receive() external payable {}

    fallback() external payable {}

    function enableTrading() external onlyOwner {
        if (tradingEnabled) revert Whispr_TradingAlreadyEnabled();
        tradingEnabled = true;
        emit TradingEnabled(block.number);
    }

    /**
     * @notice Update the trading fund Wallet
     * @param _newTradingFundWallet The new trading fund Wallet address
     * @dev Only the owner can update the trading fund Wallet and the new wallet should not be the zero address or the contract address or the current trading fund address
     */
    function updateTradingFundWallet(address _newTradingFundWallet)
        external
        onlyOwner
    {
        if (
            _newTradingFundWallet == address(0) ||
            _newTradingFundWallet == address(this) ||
            _newTradingFundWallet == tradingFundWallet
        ) revert Whispr_InvalidWalletAddress(_newTradingFundWallet);
        emit TradingFundWalletUpdate(tradingFundWallet, _newTradingFundWallet);
        tradingFundWallet = _newTradingFundWallet;
    }

    /**
     * @notice Update the Dev Wallet
     * @param _devWallet The new Dev Wallet address
     * @dev Only the owner can update the Dev Wallet and the new wallet should not be the zero address or the contract address or the current trading fund address
     */
    function updateDevWallet(address _devWallet) external onlyOwner {
        if (
            _devWallet == address(0) ||
            _devWallet == address(this) ||
            _devWallet == devWallet
        ) revert Whispr_InvalidWalletAddress(_devWallet);
        emit DevWalletUpdate(devWallet, _devWallet);
        devWallet = _devWallet;
    }

    /**
     * @notice Update the Main Pair to swap for ETH
     * @param _uniswapV2Pair The new UniswapV2Pair address
     * @dev Only the owner can update the Pair and the new wallet should not be the zero address or the contract address or the current address
     *  or the current pair address or be an invalid V2pair
     */
    function updateV2Pair(address _uniswapV2Pair) external onlyOwner {
        address token0 = IUniswapV2Pair(_uniswapV2Pair).token0();
        address token1 = IUniswapV2Pair(_uniswapV2Pair).token1();
        if (token0 != address(this) && token1 != address(this)) {
            revert Whispr_InvalidWalletAddress(_uniswapV2Pair);
        }
        emit PairUpdate(uniswapV2Pair, _uniswapV2Pair);
        uniswapV2Pair = _uniswapV2Pair;
    }

    /**
     * @notice Update the UniswapV2Router
     * @param _uniswapV2Router The new UniswapV2Router address
     * @dev Only the owner can update the Router and the new wallet should not be the zero address or the contract address or the current address
     *  or the current pair address or be an invalid v2 router
     */
    function updateV2Router(address _uniswapV2Router) external onlyOwner {
        if (
            _uniswapV2Router == address(0) ||
            _uniswapV2Router == address(this) ||
            _uniswapV2Router == address(router) ||
            IUniswapV2Router02(_uniswapV2Router).WETH() != WETH
        ) revert Whispr_InvalidRouterAddress(_uniswapV2Router);
        emit RouterUpdate(address(router), _uniswapV2Router);
        router = IUniswapV2Router02(_uniswapV2Router);
    }

    /**
     * @notice Add a new pair to the list of pairs
     * @param pair The address of the pair to add
     */
    function addPair(address pair) external onlyOwner {
        if (pair == address(0) || pair == address(this))
            revert Whispr_InvalidPairAddress(pair);
        isPair[pair] = true;
        isExcludedFromLimit[pair] = true;
    }

    /**
     * @notice Update the exclusion status of a wallet from fees
     * @param wallet The address to update exclusion status from fees
     * @param status The new exclusion status
     */
    function updateWalletExcludeStatus(address wallet, bool status)
        external
        onlyOwner
    {
        isExcludedFromFee[wallet] = status;
        emit UpdateExcludedStatus(wallet, status);
    }

    /**
     * @notice Update the limit exclusion of a wallet
     * @param wallet The address to update exclusion status from limits
     * @param status The new limit exclusion status
     * @dev Wallet to update cannot be the pair or the router
     */
    function updateWalletLimitStatus(address wallet, bool status)
        external
        onlyOwner
    {
        if (wallet == uniswapV2Pair || wallet == address(router))
            revert Whispr_InvalidWalletAddress(wallet);
        isExcludedFromLimit[wallet] = status;
        emit UpdateLimitStatus(wallet, status);
    }

    /**
     * @notice Swap currently held fees for ETH and distribute to trading fund and dev wallets
     */
    function manualSwapFees() external onlyOwner {
        _swapFees();
    }

    /**
     * @notice update the fee taken on BUY transactions
     * @param _fee The new fee to apply
     * @dev The fee cannot be more than 30%
     */
    function updateBuyFee(uint256 _fee) external onlyOwner {
        if (_fee > 30) revert Whispr_InvalidFeeAmount(_fee, 30);
        emit UpdateBuyFee(feeOnBuy, _fee);
        feeOnBuy = _fee;
    }

    /**
     * @notice update the fee taken on BUY transactions
     * @param _fee The new fee to apply
     * @dev The fee cannot be more than 30%
     */
    function updateSellFee(uint256 _fee) external onlyOwner {
        if (_fee > 30) revert Whispr_InvalidFeeAmount(_fee, 30);
        emit UpdateSellFee(feeOnSell, _fee);
        feeOnSell = _fee;
    }

    /**
     * @notice update the amount to collect before triggering a conversion to ETH
     * @param _threshold The new threshold to apply
     */
    function updateSwapThreshold(uint256 _threshold) external onlyOwner {
        emit UpdateThreshold(swapThreshold, _threshold);
        swapThreshold = _threshold;
    }

    /**
     * Updates the Max Tokens a tx can make in a single TX
     * @param _maxTx The new maxTx to apply
     */
    function updateMaxTx(uint256 _maxTx) external onlyOwner {
        if (_maxTx < totalSupply() / 100) revert Whispr_InvalidMaxTxAmount();
        emit MaxTxUpdate(maxTxAmount, _maxTx);
        maxTxAmount = _maxTx;
    }

    /**
     * @notice update the fee split between trading fund and dev wallets
     * @param _tradingFundShares The new trading fund shares
     * @param _devShares The new dev shares
     * @dev totalPercent cannot be 0. Shares do not change the fees, only the split
     */
    function updateFeeSplit(uint8 _tradingFundShares, uint8 _devShares)
        external
        onlyOwner
    {
        if (_tradingFundShares + _devShares == 0) revert Whispr_InvalidSplit(0);
        totalPercent = _tradingFundShares + _devShares;
        tradingFundPercent = _tradingFundShares;
        devPercent = _devShares;
    }

    /**
     * @notice remove any ETH from the contract to DEV wallet
     */
    function extractETH() external {
        uint256 amount = address(this).balance;
        if (amount == 0) revert Whispr_CannotTransfer(0);
        (bool success, ) = devWallet.call{value: address(this).balance}("");
        if (!success) revert Whispr_CannotTransfer(1);
    }

    /**
     * @notice remove any ERC20 token from the contract to dev wallet
     * @param token The address of the ERC20 token to extract from this contract
     */
    function extractToken(address token) external onlyOwner {
        if (token == address(0)) {
            revert Whispr_InvalidWalletAddress(token);
        }

        ERC20 erc = ERC20(token);
        uint256 balance = erc.balanceOf(address(this));
        if (balance == 0) {
            revert Whispr_CannotTransfer(0);
        }
        erc.transfer(devWallet, balance);
    }

    /**
     * @notice Updates balances for sender and receiver with fee handling and trading controls.
     * @param from The sender address.
     * @param to The receiver address.
     * @param value The amount of tokens to be transferred.
     * @dev Overrides the ERC20 transfer mechanism to implement buy/sell transaction checks and fee management.
     * It verifies trading is enabled and checks transaction limits unless the address is exempt. Fees are calculated
     * and retained if applicable, and balances updated accordingly. Exceeds threshold triggers a token swap for ETH
     * to fund designated wallets.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        bool isBuy = isPair[from] && to != address(this);
        bool isSell = isPair[to] && from != address(this);

        // Apply restrictions
        if (isBuy || isSell) {
            bool isAuthorizedTrader = (from == owner() ||
                to == owner() ||
                from == devWallet ||
                to == devWallet ||
                from == tradingFundWallet ||
                to == tradingFundWallet);

            // Only allow trading if enabled or if an authorized wallet is directly interacting
            if (!tradingEnabled && !isAuthorizedTrader) {
                revert Whispr_TradingNotYetEnabled(block.number);
            }
        }

        // Check transaction limits for buys and sells
        if ((isBuy || isSell) && value > maxTxAmount) {
            if (!isExcludedFromLimit[from] && !isExcludedFromLimit[to]) {
                revert Whispr_MaxTx();
            }
        }

        // Manage token swaps based on internal conditions and thresholds
        bool canSwap = !swapping &&
            balanceOf(address(this)) >= swapThreshold &&
            !isSell;
        if (canSwap) {
            _swapFees();
        }

        // Handle fees ONLY for buy/sell txs
        uint256 fee = 0;
        if (
            !swapping &&
            (isBuy || isSell) &&
            !(isExcludedFromFee[from] || isExcludedFromFee[to])
        ) {
            if (isBuy) {
                fee = (value * feeOnBuy) / FEE_BASIS;
            } else if (isSell) {
                fee = (value * feeOnSell) / FEE_BASIS;
            }
            super._update(from, address(this), fee); // deduct fees
            value -= fee;
        }

        super._update(from, to, value);
    }

    /**
     * @notice Swap fees for Whispr to eth, and send the eth to dev and trading wallets
     */
    function _swapFees() private nonReentrant {
        uint256 totalFees = balanceOf(address(this));
        require(totalFees >= swapThreshold, "Insufficient fees to swap");

        // Ensuring the interaction with the external contract is the last action.
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uint256 initialBalance = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            totalFees,
            0,  // Minimum amount of ETH to accept (could be modified to a reasonable value)
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 tradingFundFeeETH = (newBalance * tradingFundPercent) / totalPercent;
        uint256 devFeeETH = (newBalance * devPercent) / totalPercent;

        // Transferring ETH after all state updates
        (bool tfSuccess, ) = tradingFundWallet.call{value: tradingFundFeeETH}("");
        require(tfSuccess, "Failed to send ETH to trading fund");

        (bool devSuccess, ) = devWallet.call{value: devFeeETH}("");
        require(devSuccess, "Failed to send ETH to dev wallet");
    }
}