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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ElosysCommunitySale {
    address private                         _owner;
    IERC20 private                          _eloToken;
    mapping(address => uint256) private     _wallets_investment;
    mapping(address => uint256) private     _wallets_elo_amount;
    address[] public                        _whitelistedAddresses;

    // Round 1 : parameters
    uint256 private                          _r1StartTime;            
    uint256 private                          _r1EndTime;
    uint256 private                          _r1EloPerEther;
    uint256 private                          _r1TotalEth;
    uint256 private                          _r1MaxBuyEth;
    uint256 private                          _r1MinBuyEth;
    uint256 private                          _r1TotalEthRaised;
    uint256 private                          _r1TotalEloSoled;


    // Round 2 : parameters
    uint256 private                          _r2StartTime;            
    uint256 private                          _r2EndTime;
    uint256 private                          _r2EloPerEther;
    uint256 private                          _r2TotalEth;
    uint256 private                          _r2MaxBuyEth;
    uint256 private                          _r2MinBuyEth;
    uint256 private                          _r2TotalEthRaised;
    uint256 private                          _r2TotalEloSoled;

    // Claim
    bool public                             _claim = false;
    
    // Total $ELO amount of claimed by users
    uint256 public                          _rTotalClaimed;



    event SoldElo(uint256 srcAmount, uint256 eloPerEth, uint256 eloAmount);
    event StateChange();
    event WhitelistAdded(uint256 whitelistCount);

    /**
     * @dev Constructing the contract basic informations, containing the ELO token addr, the ratio price eth:elo
     * and the max authorized eth amount per wallet
     */
    constructor() {
        require(msg.sender != address(0), "Deploy from the zero address");
        _owner = msg.sender;
        _eloToken = IERC20(0x61b34A012646cD7357f58eE9c0160c6d0021fA41);

        // Round 1 : parameters
        _r1StartTime = 1703001600; // December 19, 2023 4:00:00 PM GMT
        _r1EndTime = 1703088000; // December 20, 2023 4:00:00 PM GMT
        _r1EloPerEther = 316 * (10 ** 10); // 0.00000316 ETH 
        _r1TotalEth = 30 * (10 ** 18); // 30 ETH
        _r1MaxBuyEth = 3 * (10 ** 17); // 0.3 ETH
        _r1MinBuyEth = 1 * (10 ** 17); // 0.1 ETH
        _r1TotalEthRaised = 0;
        _r1TotalEloSoled = 0;


        // Round 2 : parameters
        _r2StartTime = 1703091600; // December 20, 2023 5:00:00 PM GMT
        _r2EndTime = 1703178000; // December 21, 2023 5:00:00 PM GMT
        _r2EloPerEther = 368 * (10 ** 10); // 0.00000368 ETH 
        _r2TotalEth = 50 * (10 ** 18); // 50 ETH
        _r2MaxBuyEth = 5 * (10 ** 17); // 0.5 ETH
        _r2MinBuyEth = 1 * (10 ** 17); // 0.1 ETH
        _r2TotalEthRaised = 0;
        _r2TotalEloSoled = 0;

        _rTotalClaimed = 0;
    }

    /**
     * @dev Check that the transaction sender is the ELO owner
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can do this action");
        _;
    }

    /**
     * @dev Check the sender have depassed the limit of max eth
     */
    modifier onlyOnceInvestable() {
        uint256 totalInvested = _wallets_investment[msg.sender];
        require(totalInvested == 0, "You have already bought the ELO token.");
        _;
    }

    /**
     * @dev Receive eth payment for the presale raise
     */
    function buy() external payable onlyOnceInvestable {
        _allocateElo(msg.value);
    }

    

    /**
     * @dev Set the presale claim mode 
     */
    function setClaim(bool value) external onlyOwner {
        require(block.timestamp> _r2EndTime, "Presale is not finished.");
        _claim = value;
        emit StateChange();
    }

    /**
     * @dev Claim the ELO once the presale is done
     */
    function claimElo() public
    {
        require(_claim == true, "You cant claim your ELO yet");
        uint256 srcAmount =  _wallets_investment[msg.sender];
        require(srcAmount > 0, "You dont have any ELO to claim");
        
        uint256 eloAmount =_wallets_elo_amount[msg.sender];
        require(
            _eloToken.balanceOf(address(this)) >= eloAmount,
            "The ELO amount on the contract is insufficient."
        );
        _wallets_investment[msg.sender] = 0;
        _eloToken.transfer(msg.sender, eloAmount);

        _rTotalClaimed += eloAmount;
    }

    /**
     * @dev Return the Current Round Id ( 1 => Round 1, 2 => Round 2, 3 => Finished).
     */
    function getRoundId() public view returns(uint256) {
        uint256 currentTime = block.timestamp;
        if (currentTime < _r1EndTime) {
            return 1;
        } else if (currentTime < _r2EndTime) {
            return 2;
        } else {
            return 3;
        }
    }


    /**
     * @dev Return the start time of the Presale in Round
     */
    function getRoundStartTime(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1StartTime;
        } else if (roundId == 2) {
            return _r2StartTime;
        }
        return 0;
    }

    /**
     * @dev Return the end time of the Presale in Round
     */
    function getRoundEndTime(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1EndTime;
        } else if (roundId == 2) {
            return _r2EndTime;
        }
        return 0;
    }
    
    /**
     * @dev Return the rate of Elo/Eth from the Presale in Round
     */
    function getEloPerEther(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1EloPerEther;
        } else if (roundId == 2) {
            return _r2EloPerEther;
        }
        return 0;
    }

    /**
     * @dev Return the limited amount from the Presale (as ETH) in Round
     */
    function getTotalEth(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1TotalEth;
        } else if (roundId == 2) {
            return _r2TotalEth;
        }
        return 0;
    }

    /**
     * @dev Return the max buy value per wallet (as ETH) in Round
     */
    function getMaxBuyEthPerWallet(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1MaxBuyEth;
        } else if (roundId == 2) {
            return _r2MaxBuyEth;
        }
        return 0;
    }

    /**
     * @dev Return the min buy value per wallet (as ETH) in Round
     */
    function getMinBuyEthPerWallet(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1MinBuyEth;
        } else if (roundId == 2) {
            return _r2MinBuyEth;
        }
        return 0;
    }

    /**
     * @dev Return the amount raised from the Presale (as ETH) in Round
     */
    function getTotalRaisedEth(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1TotalEthRaised;
        } else if (roundId == 2) {
            return _r2TotalEthRaised;
        }
        return 0;
    }

    /**
     * @dev Return the amount soled from the Presale (as ELO) in Round
     */
    function getTotalSoledElo(uint roundId) public view returns(uint256) {
        if (roundId == 1) {
            return _r1TotalEloSoled;
        } else if (roundId == 2) {
            return _r2TotalEloSoled;
        }
        return 0;
    }


    /**
     * @dev Return the total amount invested from a specific address
     */
    function getAddressInvestment(address addr) public view returns(uint256) {
        return  _wallets_investment[addr];
    }

    /**
     * @dev Return the total amount of ELO bought for a specific address
     */
    function getAddressBoughtElo(address addr) public view returns(uint256) {
        return  _wallets_elo_amount[addr];
    }

    /**
     * @dev Allocate the specific ELO amount to the payer address
     */
    function _allocateElo(uint256 _srcAmount) private {
        uint256 _eloPerEth = 0;
        uint256 currentTime = block.timestamp;
        if (currentTime < _r1StartTime) {
            revert('You should wait for Round 1');
        } else if (currentTime < _r1EndTime) {
            // Check if wallet is in whitelist : Round 1
            require(checkWhitelist(msg.sender), "You are not whitelisted");
            require(_srcAmount >= _r1MinBuyEth, "Too small deposite");
            require(_srcAmount <= _r1MaxBuyEth, "Too much deposite");
            require(_r1TotalEthRaised + _srcAmount <= _r1TotalEth, "Total Ether limited");
            _eloPerEth = _r1EloPerEther;
        } else if (currentTime < _r2StartTime) {
            revert('You should wait for Round 2');
        } else if (currentTime < _r2EndTime) {
            require(_srcAmount >= _r2MinBuyEth, "Too small deposite");
            require(_srcAmount <= _r2MaxBuyEth, "Too much deposite");
            require(_r2TotalEthRaised + _srcAmount <= _r2TotalEth, "Total Ether limited");
            
            _eloPerEth = _r2EloPerEther;
        } else {
            revert('Presale is over');
        }

        uint256 eloAmount = _srcAmount * (10 ** 18) / _eloPerEth; 

        require(
            _eloToken.balanceOf(address(this)) >= eloAmount + _r1TotalEloSoled + _r2TotalEloSoled,
                "The ELO amount on the contract is insufficient."
        );


        emit SoldElo(_srcAmount, _eloPerEth, eloAmount);

        if (currentTime < _r1EndTime) {
            _r1TotalEthRaised += _srcAmount;
            _r1TotalEloSoled += eloAmount;
        } else {
            _r2TotalEthRaised += _srcAmount;
            _r2TotalEloSoled += eloAmount;
        }
        
        _wallets_investment[msg.sender] += _srcAmount;
        _wallets_elo_amount[msg.sender] += eloAmount;
    }

    /**
     * @dev Authorize the contract owner to withdraw the raised funds from the presale
     */
    function withdraw() public onlyOwner {
        require(block.timestamp > _r2EndTime, "Presale is running yet.");
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Authorize the contract owner to withdraw the remaining ELO from the presale
     */
    function withdrawRemainingELO(uint256 _amount) public onlyOwner {
        require(
            _eloToken.balanceOf(address(this)) >= _amount,
            "ELO amount asked exceed the contract amount"
        );

        // Calculate how many $ELO should be in this contract.
        // The $ELOs are for the users who haven't claimed yet.
        uint256 _totalForUsers = _r1TotalEloSoled + _r2TotalEloSoled - _rTotalClaimed;

        require(
            _eloToken.balanceOf(address(this)) >= _amount + _totalForUsers,
            "ELO amount asked exceed the amount for users"
        );
        _eloToken.transfer(msg.sender, _amount);
    }

    /**
     * @dev Add wallets in whitelist 
     */
    function addInWhitelist(address[] calldata _users) external onlyOwner {
        for (uint i = 0; i < _users.length; i++)  {
            if ( !checkWhitelist(_users[i]) )
                _whitelistedAddresses.push(_users[i]);
        }
        emit WhitelistAdded(_whitelistedAddresses.length);
    }

    /**
     * @dev remove wallets in whitelist 
     */
    function removeFromWhitelist(address[] calldata _users) external onlyOwner {
        for (uint i = 0; i < _users.length; i++)  {
            for ( uint k = 0; k < _whitelistedAddresses.length; k++ ) {
                if (_whitelistedAddresses[k] == _users[i]) {
                    _whitelistedAddresses[k] = _whitelistedAddresses[_whitelistedAddresses.length - 1];
                    _whitelistedAddresses.pop();
                }
            }
        }
    }


    /**
     * @dev Check the whitelist
     */
    function checkWhitelist(address _user) public view returns (bool) {
        for (uint i = 0; i < _whitelistedAddresses.length; i++) {
            if (_whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Get number of whitelist
     */
    function getWhitelistCount() public view returns (uint) {
        return _whitelistedAddresses.length;
    }
}