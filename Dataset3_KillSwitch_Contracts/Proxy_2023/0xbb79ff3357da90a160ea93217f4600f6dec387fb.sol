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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SaleToken.sol";


interface IVistaFactory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

interface IPair {
    function claimShare() external;
}

interface ILaunchContract {
    function launch(
        address token,
        uint256 amountTokenDesired,
        uint256 amountETHMin,
        uint256 amountTokenMin,
        uint8 buyLpFee,
        uint8 sellLpFee,
        uint8 buyProtocolFee,
        uint8 sellProtocolFee,
        address protocolAddress
    ) external payable;
}

contract SaleContract is ReentrancyGuard {
    address public token;
    address public creator;
    address public factory;
    uint256 public totalTokensForSale;
    uint256 public totalTokens;
    uint256 public totalRaised;
    uint256 public maxContribution;
    uint8 public creatorshare;
    bool public launched;
    mapping(address => uint256) public contributions;

    address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public vistaFactoryAddress = 0x9a27cb5ae0B2cEe0bb71f9A85C0D60f3920757B4;

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address _creator,
        address _factory,
        uint256 _totalTokens,
        uint256 _totalTokensForSale,
        uint256 _maxContribution,
        uint8 _creatorshare
    ) {
        creator = _creator;
        factory = _factory;
        totalTokens = _totalTokens;
        totalTokensForSale = _totalTokensForSale;
        maxContribution = _maxContribution;
        creatorshare = _creatorshare;


        // Deploy the token directly from SaleContract and mint to SaleContract address
        SaleToken newToken = new SaleToken(name, symbol, _totalTokens, address(this));
        token = address(newToken);
    }

    function contribute(address user) external payable onlyFactory nonReentrant {
        require(!launched, "Sale already launched");
        require(contributions[user] + msg.value <= maxContribution, "Contribution exceeds max");

        contributions[user] += msg.value;
        totalRaised += msg.value;
    }

    function claimTokens(address user) external onlyFactory nonReentrant {
        require(launched, "Sale not launched");
        uint256 contribution = contributions[user];
        require(contribution > 0, "No contribution");

        uint8 decimals = ERC20(token).decimals();
        uint256 tokensToClaim = (contribution * totalTokensForSale * (10 ** decimals)) / totalRaised;

        contributions[user] = 0;

        require(ERC20(token).transfer(user, tokensToClaim), "Token transfer failed");
    }

    function launchSale(
    address _launchContract,
    uint8 buyLpFee,
    uint8 sellLpFee,
    uint8 buyProtocolFee,
    uint8 sellProtocolFee
) external onlyFactory nonReentrant {
    require(!launched, "Sale already launched");
    launched = true;

    uint256 tokenAmount = (totalTokens - totalTokensForSale) * (10 ** ERC20(token).decimals());
    uint256 ethAmount = totalRaised;

    // Calculate the amount to use for launching after creator's share deduction
    uint256 launchEthAmount = ((100 - creatorshare) * ethAmount) / 100;

    // Approve the launch contract to spend the SaleContract's tokens
    require(ERC20(token).approve(_launchContract, tokenAmount), "Approval failed");

    // Launch the sale using the deducted ETH amount (after creator's share deduction)
    ILaunchContract(_launchContract).launch{value: launchEthAmount}(
        token,
        tokenAmount,
        0,
        0,
        buyLpFee,
        sellLpFee,
        buyProtocolFee,
        sellProtocolFee,
        creator
    );

    // Transfer the remaining balance (creator's share) to the creator
    uint256 creatorShareAmount = address(this).balance;
    require(creatorShareAmount > 0, "No balance for creator share");

    payable(creator).transfer(creatorShareAmount);
}



    function processRefund(address user) external onlyFactory nonReentrant {
        require(!launched, "Sale already launched");
        uint256 contribution = contributions[user];
        require(contribution > 0, "No contribution to refund");

        contributions[user] = 0;
        payable(user).transfer(contribution);
    }

    function takeFee(address lockFactoryOwner) external onlyFactory nonReentrant {
        IVistaFactory vistaFactory = IVistaFactory(vistaFactoryAddress);
        address pairAddress = vistaFactory.getPair(token, wethAddress);

        require(pairAddress != address(0), "Pair not found");

        IPair pair = IPair(pairAddress);
        pair.claimShare();

        uint256 claimedEth = address(this).balance;
        require(claimedEth > 0, "No ETH claimed");

        payable(lockFactoryOwner).transfer(claimedEth);
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// SaleToken: ERC-20 token for the sale
contract SaleToken is ERC20 {
    address public saleContract;

    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address _saleContract
    ) ERC20(name, symbol) {
        saleContract = _saleContract;
        // Mint total supply to the sale contract, adjusted for decimals
        _mint(_saleContract, totalSupply * (10 ** decimals()));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SaleContract.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ISaleContract {
    function contribute(address user) external payable;
    function claimTokens(address user) external;
    function launchSale(
        address _launchContract,
        uint8 buyLpFee,
        uint8 sellLpFee,
        uint8 buyProtocolFee,
        uint8 sellProtocolFee
    ) external;
    function processRefund(address user) external;
    function takeFee(address lockFactoryOwner) external;
}

contract VistaStoreFactory is ReentrancyGuard {
    address public owner;
   
    address public launchContractAddress = 0xCEDd366065A146a039B92Db35756ecD7688FCC77;
    uint256 public saleCounter;

    uint256 public deadlinePeriod = 3 days;
    uint256 public totalTokens = 100000000;
    uint256 public totalTokensForSale = 60000000;
    uint256 public defaultSaleGoal = 1 ether;
    uint256 public maxContribution = 0.1 ether;
    uint8 public creatorshare = 5;


    // Predefined fees
    uint8 public buyLpFee = 5;
    uint8 public sellLpFee = 5;
    uint8 public buyProtocolFee = 5;
    uint8 public sellProtocolFee = 5;

    struct Sale {
        address creator;
        address tokenAddress;
        address saleContract;
        string name;
        string symbol;
        uint256 totalRaised;
        uint256 saleGoal;
        bool launched;
        bool finalized;
        uint256 deadline;
    }

    struct SaleMetadata {
        string logoUrl;
        string websiteUrl;
        string twitterUrl;
        string telegramUrl;
    }

    mapping(uint256 => Sale) public sales;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    mapping(address => uint256[]) public contributedSales;
    mapping(uint256 => mapping(address => bool)) public hasClaimed;
    mapping(uint256 => mapping(address => bool)) public hasRefunded;
    mapping(uint256 => SaleMetadata) public saleMetadata;


    event SaleCreated(
    uint256 indexed saleId,
    address indexed creator,
    address tokenAddress,
    address saleContract,
    string name,
    string symbol,
    uint256 saleGoal,
    uint256 deadline
    );

    event ContributionMade(uint256 indexed saleId, address indexed contributor, uint256 saleRaised, uint256 totalContribution);
    event SaleLaunched(uint256 indexed saleId, address indexed launcher);
    event Claimed(uint256 indexed saleId, address indexed claimant);
    event SaleRefunded(uint256 indexed saleId, address indexed contributor, uint256 amount);
    event MetaUpdated(uint256 indexed saleId, string logoUrl, string websiteUrl, string twitterUrl, string telegramUrl);


    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlySaleCreator(uint256 saleId) {
        require(msg.sender == sales[saleId].creator, "Notcreator");
        _;
    }

    constructor() {
        owner = msg.sender;
        saleCounter = 0;
    }

    function createSale(string memory name, string memory symbol) external nonReentrant {
        SaleContract newSaleContract = new SaleContract(
            name,
            symbol,
            msg.sender,
            address(this),
            totalTokens,
            totalTokensForSale,
            maxContribution,
            creatorshare
        );

        uint256 deadline = block.timestamp + deadlinePeriod;

        sales[saleCounter] = Sale({
            creator: msg.sender,
            tokenAddress: newSaleContract.token(),
            saleContract: address(newSaleContract),
            name: name,
            symbol: symbol,
            totalRaised: 0,
            saleGoal: defaultSaleGoal,
            launched: false,
            finalized: false,
            deadline: deadline
        });

        // Emit event with individual values
    emit SaleCreated(
        saleCounter,
        msg.sender,
        newSaleContract.token(),
        address(newSaleContract),
        name,
        symbol,
        defaultSaleGoal,
        deadline
    );

        saleCounter++;
    }

    function contribute(uint256 saleId) external payable nonReentrant {
        Sale storage sale = sales[saleId];
        require(!sale.launched, "launched");
        require(sale.totalRaised < sale.saleGoal + 0.1 ether, "goal reached");
        require(block.timestamp <= sale.deadline, "expired");

        contributions[saleId][msg.sender] += msg.value;
        sale.totalRaised += msg.value;
        contributedSales[msg.sender].push(saleId);

        emit ContributionMade(saleId, msg.sender, sale.totalRaised, contributions[saleId][msg.sender]);

        ISaleContract(sale.saleContract).contribute{value: msg.value}(msg.sender);
    }

    function claim(uint256 saleId) external nonReentrant {
        Sale storage sale = sales[saleId];
        require(sale.launched, "not launched");
        require(!hasClaimed[saleId][msg.sender], "claimed");

        hasClaimed[saleId][msg.sender] = true;

        emit Claimed(saleId, msg.sender);

        ISaleContract(sale.saleContract).claimTokens(msg.sender);
    }

    function launch(uint256 saleId) external nonReentrant {
        Sale storage sale = sales[saleId];
        require(!sale.launched, "launched");
        require(sale.totalRaised >= sale.saleGoal, "less than sale goal");
        require(msg.sender == sale.creator || msg.sender == owner, "Not authorized");

        sale.launched = true;

        emit SaleLaunched(saleId, msg.sender);

        // Use predefined fees during launch
        ISaleContract(sale.saleContract).launchSale(
            launchContractAddress,
            buyLpFee,
            sellLpFee,
            buyProtocolFee,
            sellProtocolFee
        );
    }

    function triggerRefund(uint256 saleId) external nonReentrant {
        Sale storage sale = sales[saleId];
        require(!sale.launched, "launched");
        require(block.timestamp > sale.deadline, "deadline not reached");
        require(sale.totalRaised < sale.saleGoal, "not allowed");
        require(!hasRefunded[saleId][msg.sender], "claimed");

        hasRefunded[saleId][msg.sender] = true;

        emit SaleRefunded(saleId, msg.sender, contributions[saleId][msg.sender]);

        ISaleContract(sale.saleContract).processRefund(msg.sender);
    }

    function takeFeeFrom(uint256 saleId) external onlyOwner nonReentrant {
        Sale storage sale = sales[saleId];
        ISaleContract(sale.saleContract).takeFee(owner);
    }

    // Function to update predefined fees, accessible only by owner
    function updateFee(uint8 _buyLpFee, uint8 _sellLpFee, uint8 _buyProtocolFee, uint8 _sellProtocolFee) external onlyOwner {
        buyLpFee = _buyLpFee;
        sellLpFee = _sellLpFee;
        buyProtocolFee = _buyProtocolFee;
        sellProtocolFee = _sellProtocolFee;
    }

    function updateSaleParameters(uint256 _totalTokens, uint256 _totalTokensForSale, uint256 _saleGoal, uint256 _maxContribution) external onlyOwner {
        totalTokens = _totalTokens;
        totalTokensForSale = _totalTokensForSale;
        defaultSaleGoal = _saleGoal;
        maxContribution = _maxContribution;
    }

    function updateDeadlinePeriod(uint256 _deadlinePeriod) external onlyOwner {
        deadlinePeriod = _deadlinePeriod;
    }

    function updateContractAddresses(address _launchContractAddress) external onlyOwner {
        
        launchContractAddress = _launchContractAddress;
    }

    function getSaleIdsForContributor(address contributor) external view returns (uint256[] memory) {
        return contributedSales[contributor];
    }


    function setSaleMetadata(
        uint256 saleId,
        string memory logoUrl,
        string memory websiteUrl,
        string memory twitterUrl,
        string memory telegramUrl
    ) external onlySaleCreator(saleId) {
        SaleMetadata storage metadata = saleMetadata[saleId];

        metadata.logoUrl = logoUrl;
        metadata.websiteUrl = websiteUrl;
        metadata.twitterUrl = twitterUrl;
        metadata.telegramUrl = telegramUrl;

        emit MetaUpdated(saleId, logoUrl, websiteUrl, twitterUrl, telegramUrl);
    }   

        // New function to update creatorshare
    function updateCreatorShare(uint8 newShare) external onlyOwner {
        require(newShare > 0 && newShare <= 100, "Invalid creator share");
        creatorshare = newShare;
        
    }
}