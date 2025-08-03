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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function mint(address to) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IWETH {
    function deposit() external payable;
}

/**
 * @notice UniswapV2Pair does not allow to receive to token0 or token1.
 * As a workaround, this contract can receive tokens and has max approval
 * for the creator.
 */
contract ERC20HolderWithApproval {
    constructor(address token) {
        IERC20(token).approve(msg.sender, type(uint256).max);
    }
}

/**
 * @notice Gas optimized ERC20 token based on solmate's ERC20 contract.
 * @dev Optimizations assume a UniswapV2 WETH pair as main liquidity.
 */
abstract contract ERC20UniswapV2InternalSwaps {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private immutable wethReceiver;
    address public immutable pair;
    bool private immutable tokenIsToken0;

    constructor() {
        tokenIsToken0 = address(this) < WETH;
        pair = IUniswapV2Factory(FACTORY).createPair(address(this), WETH);
        wethReceiver = address(new ERC20HolderWithApproval(WETH));
    }

    /**
     * @dev Swap tokens to WETH directly on pair, to save gas.
     * No check for minimal return, susceptible to price manipulation!
     */
    function _swapForWETH(uint amountToken, address to) internal {
        uint amountWeth = _getAmountWeth(amountToken);
        _transferFromContractBalance(pair, amountToken);
        // Pair prevents receiving tokens to one of the pairs addresses
        IUniswapV2Pair(pair).swap(tokenIsToken0 ? 0 : amountWeth, tokenIsToken0 ? amountWeth : 0, wethReceiver, new bytes(0));
        IERC20(WETH).transferFrom(wethReceiver, to, amountWeth);
    }

    /**
     * @dev Add tokens and WETH to liquidity, directly on pair, to save gas.
     * No check for minimal return, susceptible to price manipulation!
     * Sufficient WETH in contract balancee assumed!
     */
    function _addLiquidity(
        uint amountToken,
        address to
    ) internal returns (uint amountWeth) {
        amountWeth = _quoteToken(amountToken);
        _transferFromContractBalance(pair, amountToken);
        IERC20(WETH).transferFrom(address(this), pair, amountWeth);
        IUniswapV2Pair(pair).mint(to);
    }

    /**
     * @dev Add tokens and WETH as initial liquidity, directly on pair, to save gas.
     * No checks performed. Caller has to make sure to have access to the token before public!
     * Sufficient WETH in contract balancee assumed!
     */
    function _addInitialLiquidity(
        uint amountToken,
        uint amountWeth,
        address to
    ) internal {
        _transferFromContractBalance(pair, amountToken);
        IERC20(WETH).transferFrom(address(this), pair, amountWeth);
        IUniswapV2Pair(pair).mint(to);
    }

    /**
     * @dev Add tokens and ETH as initial liquidity, directly on pair, to save gas.
     * No checks performed. Caller has to make sure to have access to the token before public!
     * Sufficient ETH in contract balancee assumed!
     */
    function _addInitialLiquidityEth(
        uint amountToken,
        uint amountEth,
        address to
    ) internal {
        IWETH(WETH).deposit{value: amountEth}();
        _addInitialLiquidity(amountToken, amountEth, to);
    }

    /** @dev Transfer all WETH from contract balance to `to`. */
    function _sweepWeth(address to) internal returns (uint amountWeth) {
        amountWeth = IERC20(WETH).balanceOf(address(this));
        IERC20(WETH).transferFrom(address(this), to, amountWeth);
    }

    /** @dev Transfer all ETH from contract balance to `to`. */
    function _sweepEth(address to) internal {
        _safeTransferETH(to, address(this).balance);
    }

    /** @dev Quote `amountToken` in ETH, assuming no fees (used for liquidity). */
    function _quoteToken(
        uint amountToken
    ) internal view returns (uint amountEth) {
        (uint reserveToken, uint reserveEth) = _getReserve();
        amountEth = (amountToken * reserveEth) / reserveToken;
    }

    /** @dev Quote `amountToken` in WETH, assuming 0.3% uniswap fees (used for swap). */
    function _getAmountWeth(
        uint amounToken
    ) internal view returns (uint amountWeth) {
        (uint reserveToken, uint reserveWeth) = _getReserve();
        uint amountTokenWithFee = amounToken * 997;
        uint numerator = amountTokenWithFee * reserveWeth;
        uint denominator = (reserveToken * 1000) + amountTokenWithFee;
        amountWeth = numerator / denominator;
    }

    /** @dev Quote `amountWeth` in tokens, assuming 0.3% uniswap fees (used for swap). */
    function _getAmountToken(
        uint amounWeth,
        uint reserveToken,
        uint reserveWeth
    ) internal pure returns (uint amountToken) {
        uint numerator = reserveToken * amounWeth * 1000;
        uint denominator = (reserveWeth - amounWeth) * 997;
        amountToken = (numerator / denominator) + 1;
    }

    /** @dev Get reserves of pair. */
    function _getReserve()
        internal
        view
        returns (uint reserveToken, uint reserveWeth)
    {
        (uint112 reserveToken0, uint112 reserveToken1) = IUniswapV2Pair(pair).getReserves();
        (reserveToken, reserveWeth) = tokenIsToken0 ? (reserveToken0, reserveToken1) : (reserveToken1, reserveToken0);
    }

    /** @dev Transfer `amount` ETH to `to` gas efficiently. */
    function _safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly { // solhint-disable-line no-inline-assembly
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /** @dev Returns true if `_address` is a contract. */
    function _isContract(address _address) internal view returns (bool) {
        uint32 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }

    /** @dev Transfeer `amount` tokens from contract balance to `to`. */
    function _transferFromContractBalance(
        address to,
        uint256 amount
    ) internal virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20UniswapV2InternalSwaps} from "./ERC20UniswapV2InternalSwaps.sol";

contract TheTribe is ERC20, Ownable, ERC20UniswapV2InternalSwaps {
    /** @notice The presale states. */
    enum PresaleState {
        NONE,
        OPEN,
        CLOSED,
        COMPLETED
    }

    /** @notice Percentage of supply allocated for presale participants (60%). */
    uint256 public constant SHARE_PRESALE = 60_00;
    /** @notice Percentage of supply allocated for initial liquidity (28.5%).*/
    uint256 public constant SHARE_LIQUIDITY = 28_50;
    /** @notice Percentage of supply allocated for team, marketing, cex listings, etc. (11.5%). */
    uint256 public constant SHARE_OTHER = 11_50;
    /** @notice Per account limit in ETH for presale (1 ETH). */
    uint256 public constant PRESALE_ACCOUNT_LIMIT = 1 ether;
    /** @notice Minimum threshold in ETH to trigger #_swapTokens. */
    uint256 public constant SWAP_THRESHOLD_ETH_MIN = 0.005 ether;
    /** @notice Maximum threshold in ETH to trigger #_swapTokens. */
    uint256 public constant SWAP_THRESHOLD_ETH_MAX = 50 ether;
    /** @notice Maximum tax (0.25%) */
    uint256 public constant MAX_TAX = 25;

    uint256 private constant _MAX_SUPPLY = 1_000_000_000 ether;
    uint256 private constant _SUPPLY_PRESALE =
        (_MAX_SUPPLY * SHARE_PRESALE) / 100_00;
    uint256 private constant _SUPPLY_LIQUIDITY =
        (_MAX_SUPPLY * SHARE_LIQUIDITY) / 100_00;
    uint256 private constant _SUPPLY_OTHER =
        _MAX_SUPPLY - _SUPPLY_PRESALE - _SUPPLY_LIQUIDITY;
    uint256 private constant _LAUNCH_BUY_TAX = 3_00;
    uint256 private constant _LAUNCH_SELL_TAX = 50_00;
    uint256 private constant _LAUNCH_TAX_WINDOW = 20 minutes;

    /** @notice Tax recipient wallet. */
    address public taxRecipient;
    /** @notice Whether address is extempt from transfer tax. */
    mapping(address => bool) public taxFreeAccount;
    /** @notice Whether address is an exchange pool. */
    mapping(address => bool) public isExchangePool;
    /** @notice Threshold in ETH of tokens to collect before triggering #_swapTokens. */
    uint256 public swapThresholdEth = 0.1 ether;
    /** @notice Tax manager. */
    address public taxManager;
    /** @notice Buy tax in bps (0%). In first 20 minutes after adding liquidity, buy tax will be 3%. */
    uint256 public buyTax = 0;
    /** @notice Sell tax in bps (0.25%). In first 20 minutes after adding liquidity, sell tax will be 50%. */
    uint256 public sellTax = 25;
    /** @notice Presale commitment in ETH per address. */
    mapping(address => uint256) public commitment;
    /** @notice Presale amount of claimed tokens per address. */
    mapping(address => uint256) public claimedTokens;
    /** @notice Presale total commitment in ETH. */
    uint256 public totalCommitments;
    /** @notice Presale total amount of claimed tokens. */
    uint256 public totalClaimed;
    /** @notice Current presale state. */
    PresaleState public presaleState;

    uint256 private _launchTaxEndsAt = type(uint256).max;

    event CommitedToPresale(address indexed account, uint256 amount);
    event PresaleOpened();
    event PresaleClosed(uint256 totalCommitments);
    event PresaleCompleted(uint256 totalCommitments);
    event PresaleClaimed(address indexed account, uint256 amount);
    event TaxRecipientChanged(address indexed taxRecipient);
    event SwapThresholdChanged(uint256 swapThresholdEth);
    event TaxFreeStateChanged(address indexed account, bool indexed taxFree);
    event ExchangePoolStateChanged(
        address indexed account,
        bool indexed isExchangePool
    );
    event TaxManagerChanged(address indexed taxManager);
    event TaxesChanged(uint256 newBuyTax, uint256 newSellTax);
    event TaxesWithdrawn(uint256 amount);

    error MaxAccountLimitExceeded();
    error PresaleIsClosed();
    error PresaleNotCompleted();
    error AlreadyClaimed();
    error NoCommittments();
    error NothingCommitted();
    error Unauthorized();
    error InvalidParameters();
    error InvalidSwapThreshold();
    error InvalidTax();
    error NoContract();
    error InvalidState();

    modifier onlyTaxManager() {
        if (msg.sender != taxManager) {
            revert Unauthorized();
        }
        _;
    }

    constructor(
        address _owner,
        address _taxRecipient,
        address _taxManager
    ) ERC20("The Tribe", "TRIBE") Ownable(_owner) {
        taxManager = _taxManager;
        emit TaxManagerChanged(_taxManager);
        taxRecipient = _taxRecipient;
        emit TaxRecipientChanged(_taxRecipient);

        taxFreeAccount[address(0)] = true;
        emit TaxFreeStateChanged(address(0), true);
        taxFreeAccount[_taxRecipient] = true;
        emit TaxFreeStateChanged(_taxRecipient, true);
        taxFreeAccount[address(this)] = true;
        emit TaxFreeStateChanged(address(this), true);
        isExchangePool[pair] = true;
        emit ExchangePoolStateChanged(pair, true);
        emit TaxesChanged(buyTax, sellTax);

        _mint(address(this), _SUPPLY_PRESALE + _SUPPLY_LIQUIDITY);
        _mint(_taxRecipient, _SUPPLY_OTHER);
    }

    /** @dev Users can send ETH directly to **this** contract to participate */
    receive() external payable {
        commitToPresale();
    }

    // *** User Interface ***

    /**
     * @notice Commit ETH to presale.
     * Presale supply is claimable proportionally for all presale participants.
     * Presale has no hardcap and 1 ETH per wallet limit.
     * Users can also send ETH directly to **this** contract to participate.
     * @dev Callable once presaleOpen.
     */
    function commitToPresale() public payable {
        address account = msg.sender;
        if (_isContract(account)) {
            revert NoContract();
        }
        if (
            presaleState != PresaleState.OPEN
        ) {
            revert PresaleIsClosed();
        }

        commitment[account] += msg.value;
        totalCommitments += msg.value;

        if (commitment[account] > PRESALE_ACCOUNT_LIMIT) {
            revert MaxAccountLimitExceeded();
        }

        emit CommitedToPresale(account, msg.value);
    }

    /**
     * @notice Claim callers presale tokens.
     * @dev Callable once presaleCompleted.
     */
    function claimPresale() external {
        address account = msg.sender;

        if (_isContract(account)) {
            revert NoContract();
        }
        if (presaleState != PresaleState.COMPLETED) {
            revert PresaleNotCompleted();
        }
        if (commitment[account] == 0) {
            revert NothingCommitted();
        }
        if (claimedTokens[account] != 0) {
            revert AlreadyClaimed();
        }

        uint256 amountTokens = (_SUPPLY_PRESALE * commitment[account]) /
            totalCommitments;
        claimedTokens[account] = amountTokens;
        totalClaimed += amountTokens;

        _transferFromContractBalance(account, amountTokens);

        emit PresaleClaimed(account, amountTokens);
    }

    /** @notice Returns amount of tokens to be claimed by presale participants. */
    function unclaimedSupply() external view returns (uint256) {
        return _SUPPLY_PRESALE - totalClaimed;
    }


    // *** Owner Interface ***

    /**
     * @notice Open presale for all users.
     */
    function openPresale() external onlyOwner {
        if (presaleState != PresaleState.NONE) {
            revert InvalidState();
        }
        presaleState = PresaleState.OPEN;
        emit PresaleOpened();
    }

    /**
     * @notice Close the presale.
     * Called after #openPresale.
     */
    function closePresale() external onlyOwner {
        if (presaleState != PresaleState.OPEN) {
            revert InvalidState();
        }
        if (totalCommitments == 0) {
            revert NoCommittments();
        }

        presaleState = PresaleState.CLOSED;

        emit PresaleClosed(totalCommitments);
    }

    /**
     * @notice Complete the presale.
     * @dev Adds 47.5% of collected ETH with 28.5% of totalSupply to Liquidity.
     * Sends the remaining 52.5% of collected ETH to current owner.
     * Renounces ownership.
     * Called after #closePresale.
     */
    function completePresale() external onlyOwner {
        if (presaleState != PresaleState.CLOSED) {
            revert InvalidState();
        }

        uint256 amountEthForLiquidity = (totalCommitments * _SUPPLY_LIQUIDITY) /
            _SUPPLY_PRESALE;
        _addInitialLiquidityEth(
            _SUPPLY_LIQUIDITY,
            amountEthForLiquidity,
            taxRecipient
        );

        _sweepEth(taxRecipient);

        _launchTaxEndsAt = block.timestamp + _LAUNCH_TAX_WINDOW;
        renounceOwnership();

        presaleState = PresaleState.COMPLETED;

        emit PresaleCompleted(totalCommitments);
    }

    // *** Tax Manager Interface ***

    /**
     * @notice Set `taxFree` state of `account`.
     * @param account account
     * @param taxFree true if `account` should be extempt from transfer taxes.
     * @dev Only callable by taxManager.
     */
    function setTaxFreeAccount(
        address account,
        bool taxFree
    ) external onlyTaxManager {
        if (taxFreeAccount[account] == taxFree) {
            revert InvalidParameters();
        }
        taxFreeAccount[account] = taxFree;
        emit TaxFreeStateChanged(account, taxFree);
    }

    /**
     * @notice Set `exchangePool` state of `account`
     * @param account account
     * @param exchangePool whether `account` is an exchangePool
     * @dev ExchangePool state is used to decide if transfer is a swap
     * and should trigger #_swapTokens.
     */
    function setExchangePool(
        address account,
        bool exchangePool
    ) external onlyTaxManager {
        if (isExchangePool[account] == exchangePool) {
            revert InvalidParameters();
        }
        isExchangePool[account] = exchangePool;
        emit ExchangePoolStateChanged(account, exchangePool);
    }

    /**
     * @notice Transfer taxManager role to `newTaxManager`.
     * @param newTaxManager new taxManager
     * @dev Only callable by taxManager.
     */
    function transferTaxManager(address newTaxManager) external onlyTaxManager {
        if (newTaxManager == taxManager) {
            revert InvalidParameters();
        }
        taxManager = newTaxManager;
        emit TaxManagerChanged(newTaxManager);
    }

    /**
     * @notice Set taxRecipient address to `newTaxRecipient`.
     * @param newTaxRecipient new taxRecipient
     * @dev Only callable by taxManager.
     */
    function setTaxRecipient(address newTaxRecipient) external onlyTaxManager {
        if (newTaxRecipient == taxRecipient) {
            revert InvalidParameters();
        }
        taxRecipient = newTaxRecipient;
        emit TaxRecipientChanged(newTaxRecipient);
    }

    /**
     * @notice Withdraw tax collected (which would usually be automatically swapped to weth) to taxRecipient
     * @dev Only callable by taxManager.
     */
    function withdrawTaxes() external onlyTaxManager {
        uint256 balance = balanceOf(address(this));
        if (balance > 0) {
            super._transfer(address(this), taxRecipient, balance);
            emit TaxesWithdrawn(balance);
        }
    }

    /**
     * @notice Change the amount of tokens collected via tax before a swap is triggered.
     * @param newSwapThresholdEth new threshold received in ETH
     * @dev Only callable by taxManager
     */
    function setSwapThresholdEth(
        uint256 newSwapThresholdEth
    ) external onlyTaxManager {
        if (
            newSwapThresholdEth < SWAP_THRESHOLD_ETH_MIN ||
            newSwapThresholdEth > SWAP_THRESHOLD_ETH_MAX ||
            newSwapThresholdEth == swapThresholdEth
        ) {
            revert InvalidSwapThreshold();
        }
        swapThresholdEth = newSwapThresholdEth;
        emit SwapThresholdChanged(newSwapThresholdEth);
    }

    /**
     * @notice Set tax for buying and selling the token
     * @param newBuyTax new buy tax in bps
     * @param newSellTax new sell tax in bps
     * @dev Only callable by taxManager
     */
    function changeTaxes(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyTaxManager {
        if (newBuyTax > MAX_TAX || newSellTax > MAX_TAX) {
            revert InvalidTax();
        }
        buyTax = newBuyTax;
        sellTax = newSellTax;
        emit TaxesChanged(newBuyTax, newSellTax);
    }

    /**
     * @notice Threshold of how many tokens to collect from tax before calling #swapTokens.
     * @dev Depends on swapThresholdEth which can be configured by taxManager.
     * Restricted to 5% of liquidity.
     */
    function swapThresholdToken() public view returns (uint256) {
        (uint reserveToken, uint reserveWeth) = _getReserve();
        uint256 maxSwapEth = (reserveWeth * 5) / 100;
        return
            _getAmountToken(
                swapThresholdEth > maxSwapEth ? maxSwapEth : swapThresholdEth,
                reserveToken,
                reserveWeth
            );
    }

    /** @notice Get current buy tax depending on current timestamp. */
    function currentBuyTax() public view returns (uint256) {
        return _getTax(true);
    }

    /** @notice Get current buy tax depending on current timestamp. */
    function currentSellTax() public view returns (uint256) {
        return _getTax(false);
    }


    // *** Internal Interface ***

    /** @notice IERC20#_transfer */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (
            !taxFreeAccount[from] &&
            !taxFreeAccount[to] &&
            !taxFreeAccount[msg.sender]
        ) {
            uint256 fee = amount * _getTax(isExchangePool[from]) / 100_00;
            super._update(from, address(this), fee);
            unchecked {
                amount -= fee;
            }

            if (isExchangePool[to]) /* selling */ {
                _swapTokens(swapThresholdToken());
            }
        }
        super._update(from, to, amount);
    }


    /** @dev Get transfer tax depending on current timestamp and `isBuy`. */
    function _getTax(bool isBuy) private view returns (uint256) {
        return
            isBuy
                ? (
                    block.timestamp < _launchTaxEndsAt
                        ? _LAUNCH_BUY_TAX
                        : buyTax
                )
                : (
                    block.timestamp < _launchTaxEndsAt
                        ? _LAUNCH_SELL_TAX
                        : sellTax
                );
    }

    /** @dev Transfer `amount` tokens from contract balance to `to`. */
    function _transferFromContractBalance(
        address to,
        uint256 amount
    ) internal override {
        super._update(address(this), to, amount);
    }

    /**
     * @notice Swap `amountToken` collected from tax to WETH to add to send to taxRecipient.
     */
    function _swapTokens(uint256 amountToken) internal {
        if (balanceOf(address(this)) + totalClaimed < amountToken + _SUPPLY_PRESALE) {
            return;
        }

        _swapForWETH(amountToken, taxRecipient);
    }
}