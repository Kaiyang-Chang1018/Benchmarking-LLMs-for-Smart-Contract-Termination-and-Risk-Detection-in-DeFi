// SPDX-License-Identifier: MIT
// Twitter: https://x.com/Punkismeth
// Telegram: https://t.me/punkismeth
// Website: https://www.punkism.io/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





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
    function _transfer(address from, address to, uint256 value) internal virtual {
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

// File: punkism/generator.sol


pragma solidity ^0.8.26;

contract Generator {
    string[] public hat_colors = [
        "#f4a261", "#e76f51", "#264653", "#2a9d8f", "#e9c46a", 
        "#8d99ae", "#d62828", "#f77f00", "#fcbf49", "#003049", 
        "#d4a373", "#ffb4a2", "#cb997e", "#a5a58d", "#6b705c", 
        "#ffe8d6", "#f28482", "#84a59d", "#f5cac3", "#f28482", 
        "#0d3b66", "#faf0ca", "#f4d35e", "#ee964b", "#f95738", 
        "#fb8500", "#023047", "#219ebc", "#8ecae6", "#ffb703", 
        "#adb5bd"
    ];

    string[] public face_colors = [
        "#ffddd2", "#ffe8d6", "#fcbf49", "#e63946", "#f1faee", 
        "#a8dadc", "#457b9d", "#1d3557", "#ffcdb2", "#ffb4a2", 
        "#e5989b", "#b5838d", "#6d6875", "#ffcc99", "#fddbb5", 
        "#f0c6a1", "#edc9af", "#d2b48c", "#deb887", "#ffe4c4", 
        "#faebd7", "#f4a460", "#d2691e", "#cd853f", "#f5deb3", 
        "#f8e4d9", "#ffe4b5", "#ffb6c1", "#f0e68c", "#ff6347", 
        "#ff4500"
    ];

    string[] public eye_colors = [
        "#3d405b", "#81b29a", "#f2cc8f", "#e07a5f", "#6a994e", 
        "#22223b", "#4a4e69", "#9a8c98", "#c9ada7", "#f2e9e4", 
        "#2d6a4f", "#40916c", "#52b788", "#74c69d", "#95d5b2", 
        "#2f3e46", "#4c566a", "#434c5e", "#8fbcbb", "#88c0d0", 
        "#81a1c1", "#5e81ac", "#bf616a", "#d08770", "#ebcb8b", 
        "#a3be8c", "#b48ead", "#3b4252", "#5e81ac", "#8fa1b3", 
        "#89b4c6"
    ];

    string[] public mouth_colors = [
        "#ef476f", "#ffd166", "#06d6a0", "#118ab2", "#073b4c", 
        "#f07167", "#f4a261", "#2a9d8f", "#d62828", "#f77f00", 
        "#118ab2", "#06d6a0", "#ffca3a", "#2ec4b6", "#f72585", 
        "#4361ee", "#4cc9f0", "#3a86ff", "#8338ec", "#ff006e", 
        "#fb5607", "#ffbe0b", "#ff7b00", "#ff0054", "#fe7f2d", 
        "#ef476f", "#8338ec", "#9d4edd", "#e36414", "#f08080", 
        "#ffcc00"
    ];

    string[] public nose_colors = [
        "#e09f3e", "#9c6644", "#cb997e", "#b5838d", "#6b705c", 
        "#ffddd2", "#f4a261", "#2a9d8f", "#e9c46a", "#003049", 
        "#d4a373", "#ffb4a2", "#d62828", "#f77f00", "#fcbf49", 
        "#8d99ae", "#264653", "#fb8500", "#219ebc", "#8ecae6", 
        "#84a98c", "#4a4e69", "#a8dadc", "#457b9d", "#e63946", 
        "#f1faee", "#f07167", "#f4a261", "#2a9d8f", "#d62828", 
        "#003049"
    ];

    string[] public background_colors = [
        "#f0efeb", "#e07a5f", "#3d405b", "#81b29a", "#f2cc8f", 
        "#ffddd2", "#ffe8d6", "#edf6f9", "#e9c46a", "#f4a261", 
        "#264653", "#2a9d8f", "#8d99ae", "#d62828", "#fcbf49", 
        "#f07167", "#3d5a80", "#293241", "#ee6c4d", "#98c1d9", 
        "#2b2d42", "#8d99ae", "#d4a373", "#cdb4db", "#ffb4a2", 
        "#6b705c", "#ffd166", "#06d6a0", "#118ab2", "#073b4c", 
        "#fca311"
    ];


    function randomColor(uint256 tokenId, string[] memory colorArray) internal view returns (string memory) {
        uint256 rand = uint256(keccak256(
            abi.encodePacked(
                block.timestamp,         
                tokenId,        
                blockhash(block.number), 
                tokenId,                 
                msg.sender 
            )
        )) % colorArray.length;

        return colorArray[rand];
    }

    function getPunkSVG(uint256 tokenId) public view returns (string memory) {
        return string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' style='background:", randomColor(tokenId, background_colors) ,"' version='1.0' width='386.000000pt' height='383.000000pt' viewBox='0 0 386.000000 383.000000'>",
                    "<g xmlns='http://www.w3.org/2000/svg' transform='translate(0.000000,383.000000) scale(0.100000,-0.100000)' stroke='none'>",
                        // face
                        "<path xmlns='http://www.w3.org/2000/svg' fill='", randomColor(tokenId, face_colors) ,"' d='M1280 3120 l0 -80 -80 0 -80 0 0 -80 0 -80 -80 0 -80 0 0 -400 0 -400 -80 0 -80 0 0 -80 0 -80 -80 0 -80 0 0 -80 0 -80 80 0 80 0 0 -160 0 -160 80 0 80 0 0 -720 0 -720 80 0 80 0 0 800 0 800 -80 0 -80 0 0 80 0 80 80 0 80 0 0 320 0 320 720 0 720 0 0 -160 0 -160 -160 0 -160 0 0 -160 0 -160 160 0 160 0 0 -560 0 -560 -80 0 -80 0 0 -80 0 -80 -400 0 -400 0 0 -240 0 -240 80 0 80 0 0 160 0 160 320 0 320 0 0 80 0 80 80 0 80 0 0 80 0 80 80 0 80 0 0 880 0 880 240 0 240 0 0 80 0 80 -80 0 -80 0 0 80 0 80 -240 0 -240 0 0 160 0 160 -80 0 -80 0 0 80 0 80 -560 0 -560 0 0 -80z m960 -160 l0 -80 80 0 80 0 0 -80 0 -80 -80 0 -80 0 0 80 0 80 -80 0 -80 0 0 80 0 80 80 0 80 0 0 -80z m-1280 -1120 l0 -80 -80 0 -80 0 0 80 0 80 80 0 80 0 0 -80z'/>",
                        // eyes
                        "<path xmlns='http://www.w3.org/2000/svg' fill='", randomColor(tokenId, eye_colors) ,"' d='M1440 1920 l0 -160 160 0 160 0 0 160 0 160 -160 0 -160 0 0 -160z'/>",
                        // nose
                        "<path xmlns='http://www.w3.org/2000/svg' fill='", randomColor(tokenId, nose_colors) ,"' d='M1920 1360 l0 -240 80 0 80 0 0 240 0 240 -80 0 -80 0 0 -240z'/>",
                        // mouth
                        "<path xmlns='http://www.w3.org/2000/svg' fill='", randomColor(tokenId, mouth_colors) ,"' d='M1600 880 l0 -80 400 0 400 0 0 80 0 80 -400 0 -400 0 0 -80z'/>",
                    "</g>",
                "</svg>"
            )
        );
    }
}

// File: punkism/main.sol

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract PunkismMain is ERC20, Generator {
    IUniswapV2Router01 public uniswapRouter;
    IUniswapV2Factory public uniswapFactory;

    uint256 public count = 0;
    address public owner;
    address public tokenPairAddress = address(0);

    struct activityLogs {
        address user;
        string visual;
    }
    mapping(uint256 => activityLogs) public activityLogsData;

    constructor(address _router) ERC20("Punkism", "P") {
        uniswapRouter = IUniswapV2Router01(_router);
        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
        _mint(msg.sender, 100 * 10**decimals());
        owner = msg.sender;
    }

    function renounceOwnership() external {
        require(msg.sender == owner, "Access denied. #2");
        owner = address(0);
    }

    function start() external {
        require(tokenPairAddress == address(0), "Already started.");
        require(msg.sender == owner, "Access denied. #1");

        tokenPairAddress = uniswapFactory.createPair(address(this), uniswapRouter.WETH());
    }

    function addPunk(address user, uint256 val) internal{
        for (uint256 i = 0; i < val / 1 ether; i++) {
            ++count;
            activityLogsData[count] = activityLogs({
                user: user,
                visual: getPunkSVG(count)
            });
        }
        
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        super._transfer(sender, recipient, amount);

        if (sender == address(tokenPairAddress)) {
            // buy tx
            addPunk(tx.origin, amount);
        }
    }
}