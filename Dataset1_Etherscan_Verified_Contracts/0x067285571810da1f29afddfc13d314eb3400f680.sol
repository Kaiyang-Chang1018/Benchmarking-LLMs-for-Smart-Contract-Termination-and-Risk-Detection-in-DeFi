// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";
import "./interfaces/VRFV2WrapperInterface.sol";

/** *******************************************************************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2WrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomness' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2WrapperConsumerBase {
  LinkTokenInterface internal immutable LINK;
  VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

  /**
   * @param _link is the address of LinkToken
   * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _link, address _vrfV2Wrapper) {
    LINK = LinkTokenInterface(_link);
    VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
  }

  /**
   * @dev Requests randomness from the VRF V2 wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2 request ID of the newly created randomness request.
   */
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords
  ) internal returns (uint256 requestId) {
    LINK.transferAndCall(
      address(VRF_V2_WRAPPER),
      VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
    );
    return VRF_V2_WRAPPER.lastRequestId();
  }

  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
    fulfillRandomWords(_requestId, _randomWords);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFV2WrapperInterface {
  /**
   * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
   * be relied option within the same transaction that the request was made.
   */
  function lastRequestId() external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   */
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
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
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

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
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
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
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
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
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
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
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
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
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { LaunchpadEnabled } from "./LaunchpadEnabled.sol";
contract BasicMarketplace is Ownable, ReentrancyGuard, LaunchpadEnabled
{
    struct Sale
    {
        uint _Price;
        uint _MintPassProjectID;
        uint _Type;
        uint _ABProjectID;
        uint _AmountForSale;
        address _NFT;
        bytes32 _Root;
    }
    mapping(uint=>Sale) public Sales;
    mapping(uint=>uint) public AmountSold;
    mapping(uint=>uint[]) public DiscountAmounts;
    event Purchased(address Purchaser, uint Amount);

    /**
     * @dev Purchases An `Amount` Of NFTs From A `SaleIndex`
     */
    function Purchase(uint SaleIndex, uint Amount, bytes32[] calldata Proof) external payable nonReentrant
    {
        (bool Brightlist, uint Priority) = VerifyBrightList(SaleIndex, msg.sender, Sales[SaleIndex]._Root, Proof);
        if(Brightlist) 
        {
            require(msg.value == ((Sales[SaleIndex]._Price * DiscountAmounts[SaleIndex][Priority]) / 100), "BasicMarketplace: Incorrect ETH Amount Sent");
        }
        else
        {
            require(msg.value == Sales[SaleIndex]._Price * Amount, "BasicMarketplace: Incorrect ETH Amount Sent");
        }
        require(AmountSold[SaleIndex] + Amount <= Sales[SaleIndex]._AmountForSale, "BasicMarketplace: Not Enough NFTs Left For Sale");
        AmountSold[SaleIndex] = AmountSold[SaleIndex] + Amount;
        if(Sales[SaleIndex]._Type == 0) { IERC721(Sales[SaleIndex]._NFT)._MintToFactory(Sales[SaleIndex]._MintPassProjectID, msg.sender, Amount); }
        else 
        { 
            uint ProjectID = Sales[SaleIndex]._ABProjectID;
            for(uint x; x < Amount; x++) { IERC721(Sales[SaleIndex]._NFT).purchaseTo(msg.sender, ProjectID); }
        } 
        emit Purchased(msg.sender, Amount);
    }

    /**
     * @dev Changes The NFT Address Of A Sale
     */
    function __ChangeNFTAddress(uint SaleIndex, address NewAddress) external onlyOwner { Sales[SaleIndex]._NFT = NewAddress; }

    /**
     * @dev Changes The Price Of A Sale
     */
    function __ChangePrice(uint SaleIndex, uint Price) external onlyOwner { Sales[SaleIndex]._Price = Price; }

    /**
     * @dev Changes The MintPass ProjectID
     */
    function __ChangeMintPassProjectID(uint SaleIndex, uint MintPassProjectID) external onlyOwner { Sales[SaleIndex]._MintPassProjectID = MintPassProjectID; }

    /**
     * @dev Changes The ArtBlocks ProjectID
     */
    function __ChangeABProjectID(uint SaleIndex, uint ABProjectID) external onlyOwner { Sales[SaleIndex]._ABProjectID = ABProjectID; }

    /**
     * @dev Changes The Amount Of NFTs For Sale
     */
    function __ChangeAmountForSale(uint SaleIndex, uint AmountForSale) external onlyOwner { Sales[SaleIndex]._AmountForSale = AmountForSale; }

    /**
     * @dev Changes The Type Of A Sale
     */
    function __ChangeType(uint SaleIndex, uint Type) external onlyOwner { Sales[SaleIndex]._Type = Type; }

    /**
     * @dev Initializes A Sale Via A Struct
     */
    function __StartSale(uint SaleIndex, Sale memory _Sale) external onlyOwner { Sales[SaleIndex] = _Sale; }

    /**
     * @dev Initializes A Sale Via Parameters
     */
    function __StartSale(
        uint SaleIndex, 
        uint Price, 
        uint MintPassProjectID, 
        uint Type, 
        uint ABProjectID, 
        uint AmountForSale, 
        address NFT, 
        bytes32 Root
    ) external onlyOwner { Sales[SaleIndex] = Sale(Price, MintPassProjectID, Type, ABProjectID, AmountForSale, NFT, Root); }

    /**
     * @dev Withdraws ETH From The Contract
     */
    function WithdrawETH() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Withdraws ETH With A Low-Level Call
     */
    function WithdrawETHCall() external onlyOwner 
    { 
        (bool success,) = msg.sender.call { value: address(this).balance }(""); 
        require(success, "BasicMarketplace: ETH Withdraw Failed"); 
    }

    /**
     * @dev Verifies Brightlist
     */
    function VerifyBrightList(uint SaleIndex, address _Wallet, bytes32 _Root, bytes32[] calldata _Proof) public view returns (bool, uint)
    {
        bytes32 _Leaf = keccak256(abi.encodePacked(_Wallet));
        for(uint x; x < DiscountAmounts[SaleIndex].length; x++) { if(MerkleProof.verify(_Proof, _Root, _Leaf)) { return (true, x); } }
        return (false, 69420);
    }
}

interface IERC721
{
    function _MintToFactory(uint projectid, address to, uint amount) external;
    function purchaseTo(address _to, uint _projectID) external payable returns (uint _tokenId);
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
contract BatchReader
{
    struct CityInfo
    {
        string Name;
        address NFT;
        uint StartingIndex;
    }
    mapping(uint=>CityInfo) public CityInformation;
    constructor()
    {
        CityInformation[0] = CityInfo('CryptoGalacticans', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 0);
        CityInformation[1] = CityInfo('CryptoVenetians', 0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270, 95000000);
        CityInformation[2] = CityInfo('CryptoNewYorkers', 0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270, 189000000);
        CityInformation[3] = CityInfo('CryptoBerliners', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 3000000);
        CityInformation[4] = CityInfo('CryptoLondoners', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 4000000);
        CityInformation[5] = CityInfo('CryptoMexas', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 5000000);
        CityInformation[6] = CityInfo('CryptoTokyites', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 6000000);
        CityInformation[7] = CityInfo('City #8', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 7000000);
        CityInformation[8] = CityInfo('City #9', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 8000000);
        CityInformation[9] = CityInfo('City #10', 0xbDdE08BD57e5C9fD563eE7aC61618CB2ECdc0ce0, 9000000);
    }

    /**
     * @dev Returns An Array Of A Specific CryptoCitizen City Owners
     */
    function ReadCitizenCityOwners(uint CityIndex) external view returns (address[] memory)
    {
        address NFTAddress = CityInformation[CityIndex].NFT;
        uint Counter;
        IERC721 _NFT = IERC721(NFTAddress);
        address[] memory Owners = new address[](1000);
        uint Start = CityInformation[CityIndex].StartingIndex;
        uint Range = Start + 1000;
        for(Start; Start < Range; Start++)
        {
            try _NFT.ownerOf(Start) returns (address Owner) 
            { 
                Owners[Counter] = Owner; 
                Counter++;
            }
            catch 
            { 
                Counter++;
                continue; 
            }
        }
        return Owners;
    }
}

interface IERC721 { function ownerOf(uint TokenID) external view returns (address); }
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
/**
 * @dev @brougkr
 */
contract BulkPurchase {   
    address private constant AB = 0xd8a90CbD15381fc0226Be61AC522fee97f6C2Ed9;
    uint private constant ProjectID = 6;
    // constructor() { Mint(150); }
    function Mint(uint Amount) public { for(uint x; x < Amount; x++) { IAB(AB).purchaseTo(msg.sender, ProjectID); } }
}

interface IAB { function purchaseTo(address _to, uint _projectId) payable external returns (uint tokenID); } // ArtBlocks Standard Minter
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
contract Bytepack
{
    struct TokenData
    {
        string name;
        string gif;
        string trait;
    }

    struct OGTokenData
    {
        string name;
        string gif;
        string trait;
        bool updated;
    }

    uint private CurrentIndex;
    mapping(uint=>TokenData) private tokenData;
    mapping(uint=>OGTokenData) private OGTokenDatas;

    constructor() {}

    // /**
    //  * @dev Sets Token Data
    //  */
    // function setTokenInfo(TokenData calldata TokenDatas) external  
    // {
    //     tokenData[CurrentIndex] = TokenDatas;
    //     CurrentIndex += 1;
    // }

    function setTokenInfo(string memory Bingbong) external
    {
        CurrentIndex+=1;
    }

    function ogsetTokenInfo(uint _tokenId, string memory _name, string memory _GIF, string memory _trait) external 
    { 
        OGTokenDatas[_tokenId].name = _name;
        OGTokenDatas[_tokenId].trait = _trait;
        OGTokenDatas[_tokenId].gif = _GIF;
        OGTokenDatas[_tokenId].updated = true;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
abstract contract DelegateCashEnabled
{
    address private constant _DN = 0x00000000000076A84feF008CDAbe6409d2FE638B;
    IDelegation public constant DelegateCash = IDelegation(_DN);
}

interface IDelegation
{
    /**
     * @dev Checks If A Vault Has Delegated To The Delegate
     */
    function checkDelegateForAll(address delegate, address vault) external view returns (bool);
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IMP } from "./IMP.sol";
import { LaunchpadEnabled } from "./LaunchpadEnabled.sol";
contract DutchMarketplace is Ownable, ReentrancyGuard, LaunchpadEnabled
{
    struct Sale
    {
        string _Name;                     // [0] -> _Name
        uint _ProjectIDMintPass;          // [1] -> _ProjectIDMintPass
        uint _ProjectIDArtBlocks;         // [2] -> _ProjectIDArtBlocks
        uint _PriceStart;                 // [3] -> _PriceStart
        uint _PriceEnd;                   // [4] -> _PriceEnd
        uint _MaxAmtPerPurchase;          // [5] -> _MaxAmtPerPurchase
        uint _MaximumAvailableForSale;    // [6] -> _MaximumAvailableForSale
        uint _StartingBlockUnixTimestamp; // [7] -> _StartingBlockUnixTimestamp
        uint _SecondsBetweenPriceDecay;   // [8] -> _SecondsBetweenPriceDecay
        uint _SaleStrip;                  // [9] -> _SaleStrip note: For MintPack Sales, This Is The Default Amount Of Tokens To Mint Per Purchase Per Amount 
    }

    struct InternalSale
    {
        address _NFT;           // [0] -> _NFT
        address _Operator;      // [1] _Operator (Wallet That NFT Is Pulling From)
        uint _CurrentIndex;     // [2] _CurrentIndex (If Simple Sale Type, This Is The Next Token Index To Iterate Upon)
        uint _Type;             // [3] _SaleType (0 = Factory MintPass, 1 = Bespoke MintPass, 2 = transferFrom(), 3 = purchaseTo(), 4 = MintPack transferFrom())
        bool _ActivePublic;     // [4] -> _ActivePublic
        bool _ActiveBrightList; // [5] -> _ActiveBrightList 
        bool _ActiveDiscount;   // [6] -> _ActiveDiscount
        bool _ActiveRespend;    // [7] -> _ActiveRespend
    }

    struct SaleParam
    {
        bytes32[] _Roots;        // [0] -> _Roots (Merkle Roots For BrightList)
        bytes32[] _RootsAmounts; // [1] -> _RootsAmounts (Merkle Roots For BrightList Amounts)
        uint[] _DiscountAmounts; // [2] -> _DiscountAmounts (Discount Amounts For Each Discount Priority Tier)
    }

    struct MiscSale
    {
        uint _AmountSold;         // [0] -> _AmountSold
        uint _UniqueSales;        // [1] -> _UniqueSales
        uint _FinalClearingPrice; // [2] -> _FinalClearingPrice
        uint _CurrentRefundIndex; // [3] -> _CurrentRefundIndex
    }

    struct Order
    {
        address _Purchaser;       // [0] _Purchaser
        uint _PurchaseValue;      // [1] _PurchaseValue
        uint _PurchaseAmount;     // [2] _PurchaseAmount
        uint _Priority;           // [3] _BrightList Priority Status note: (0 Is Highest Priority)
        bool _BrightListPurchase; // [4] _BrightListPurchase
        bool _Claimed;            // [5] _Claimed
    }

    struct _UserSaleInformation
    {
        uint[] _UserOrderIndexes;        // [0] -> _UserOrderIndexes        | The Indexes Of The User's Orders
        uint[] _AmountPurchasedPriority; // [1] -> _AmountPurchasedPriority | The Amount Of Tokens Purchased By The User For The Provided Priority
        uint _PurchasedAmount;           // [2] -> _PurchaseAmount          | The Amount Of Tokens Purchased By The User
        uint _RemainingPurchaseAmount;   // [3] -> _RemainingPurchaseAmount | The Amount Of Tokens Remaining To Be Purchased Specifically For The User
        uint _ClaimIndex;                // [4] -> _ClaimIndex              | If ETH-Claims Are Enabled, This Is The User's Current Claim Index
        uint _AmountRemaining;           // [5] -> _AmountRemaining         | The Amount Of Tokens Remaining To Be Sold
        uint _CurrentPrice;              // [6] -> _MintPassCurrentPrice    | The Current Price Of The Token To Be Sold
        uint _Priority;                  // [7] -> _Priority For BrightList | The User's Priority For The BrightList | note: (0 Is Highest Priority) 
        uint _Credit;                    // [8] -> _Credit                  | The Amount Of Credit / Rebate Owed To The User (Without Discount) 
        bool _BrightListEligible;        // [9] -> _BrightListEligible      | If The User Is Eligible For The BrightList
        bool _MaxAmountVerified;         // [10] -> _MaxAmountVerified      | If The User Passed MaxAmount Correctly
        bool _ActiveRespend;             // [11] -> _ActiveRespend          | If Purchase Credit Is Able To Be Used
        bool _Active;                    // [12] -> _Active                 | If The Sale Is Active
    }

    struct Info
    {
        uint _CurrentPrice;            // [0] -> _CurrentPrice
        uint _MaximumAvailableForSale; // [1] -> _MaximumAvailableForSale
        uint _AmountRemaining;         // [2] -> _AmountRemaining
        bool _Active;                  // [3] -> _Active
    }

    /*------------------
     * STATE VARIABLES *
    -------------------*/

    uint public _TOTAL_UNIQUE_SALES_DUTCH;                                               // Total Unique Dutch Sales
    uint private constant _DEFAULT_PRIORITY = 69420;                                     // Default Priority Value ?              
    address private constant _DN = 0x00000000000076A84feF008CDAbe6409d2FE638B;           // `delegate.cash` Delegation Registry 
    address private constant _BRT_MULTISIG = 0x0BC56e3c1397e4570069e89C07936A5c6020e3BE; // `sales.brightmoments.eth`
    
    /*-----------
     * MAPPINGS *
    ------------*/

    mapping(uint=>Sale) public Sales;                                                   // [SaleIndex] => Sale
    mapping(uint=>MiscSale) public SaleState;                                           // [SaleIndex] => MiscSale
    mapping(uint=>InternalSale) public SalesInternal;                                   // [SaleIndex] => InternalSale
    mapping(uint=>Order[]) public Orders;                                               // [SaleIndex][UniqueSaleIndex] => Order
    mapping(uint=>mapping(address=>_UserSaleInformation)) public UserInfo;              // [SaleIndex][Wallet] => UserInfo
    mapping(uint=>SaleParam) private SaleParams;                                        // [SaleIndex] => SaleParam
    mapping(address=>bool) public Admin;                                                // [Wallet] => IsAdmin
    mapping(address=>uint) public NFTAddressToSaleIndex;                                // [NFT Address] => SaleIndex
    mapping(uint=>mapping(address=>mapping(uint=>uint))) public PriorityPurchaseAmount; // [SaleIndex][Wallet][Priority] => Purchased Amount For Priority Level

    /*---------
     * EVENTS *
    ----------*/

    event Purchased(uint SaleIndex, address Purchaser, uint Amount, uint PurchaseValue, uint NewAmountSold, bool BrightList, uint Priority, uint AppliedCredit);
    event Refunded(uint Value);
    event OrderRefundFailed(uint SaleIndex, uint OrderIndex);
    event SaleStarted(uint SaleIndex);
    event RefundClaimed(uint SaleIndex, uint OrderIndex);

    constructor() { Admin[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = true; } // `operator.brightmoments.eth`

    /*---------------------
     * EXTERNAL FUNCTIONS *
    ----------------------*/

    /**
     * @dev Purchases NFTs
     * note: IF YOU PURCHASE THROUGH THE CONTRACT WITHOUT THE FRONTEND YOU WILL NOT BE ELIGIBLE FOR A DISCOUNT REBATE, REQUIRES A MERKLE PROOF
     * note: `msg.value` Must Be Sufficient To Purchase NFTs @ The Current Price Of The Dutch Auction
     * @param SaleIndex        | The Sale Index
     * @param Amount           | The Amount Of NFTs To Purchase
     * @param MaxAmount        | Optional Maximum Brightlist Purchase Per Wallet Limiter
     * @param Vault            | Vault (optional delegate.cash) (if opt-out, use address(0) or `` for this value)
     * @param ProofEligibility | Merkle Proof For Priority Discount Eligibility
     * @param ProofAmount      | Merkle Proof For Maximum Purchase Amount
     * note: @param ProofEligibility Input --> [0x0] <-- For Empty Proof
     * note: @param ProofAmount - Input --> [0x0] <-- For Empty Proof
     */
    function Purchase (
        uint SaleIndex, 
        uint Amount, 
        uint MaxAmount, 
        address Vault, 
        bytes32[] calldata ProofEligibility, 
        bytes32[] calldata ProofAmount
    ) external payable nonReentrant { 
        require(tx.origin == msg.sender, "DutchMarketplace: EOA Only, Use `delegate.cash` For Wallet Delegation");
        InternalSale memory _IS = SalesInternal[SaleIndex];
        require(block.timestamp >= Sales[SaleIndex]._StartingBlockUnixTimestamp, "DutchMarketplace: Sale Not Started");
        require(_IS._ActivePublic || _IS._ActiveBrightList, "DutchMarketplace: Sale Not Active");
        address Recipient = msg.sender;
        uint OrderIndex = SaleState[SaleIndex]._UniqueSales;
        if(Vault != address(0)) { if(IDelegationRegistry(_DN).checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } } 
        require(Recipient != address(0), "DutchMarketplace: Invalid Recipient");
        if(SaleState[SaleIndex]._AmountSold + Amount > Sales[SaleIndex]._MaximumAvailableForSale)
        {
            Amount = Sales[SaleIndex]._MaximumAvailableForSale - SaleState[SaleIndex]._AmountSold;
        }
        uint NewAmountSold = SaleState[SaleIndex]._AmountSold + Amount;
        require(NewAmountSold <= Sales[SaleIndex]._MaximumAvailableForSale, "DutchMarketplace: Sold Out");
        uint Priority = _DEFAULT_PRIORITY;
        bool BrightListEligible;
        if(_IS._ActiveBrightList)
        {
            (BrightListEligible, Priority) = ViewBrightListStatus(SaleIndex, Recipient, ProofEligibility);
            if(BrightListEligible)
            {
                uint UserPriorityPurchasedAmount = PriorityPurchaseAmount[SaleIndex][Recipient][Priority];
                bytes32 _RootHash = SaleParams[SaleIndex]._RootsAmounts[Priority];
                require(VerifyAmount(Recipient, MaxAmount, _RootHash, ProofAmount), "DutchMarketplace: Invalid Max Amount Merkle Proof For Provided Merkle Priority");
                require(UserPriorityPurchasedAmount + Amount <= MaxAmount, "DutchMarketplace: User Has Purchased All Allocation For Provided Merkle Priority");
                PriorityPurchaseAmount[SaleIndex][Recipient][Priority] += Amount;
            }
        }
        require(Amount > 0 && Amount <= Sales[SaleIndex]._MaxAmtPerPurchase, "DutchMarketplace: Incorrect Desired Purchase Amount");
        uint CurrentPrice = ViewCurrentPrice(SaleIndex);
        uint PurchaseValue = CurrentPrice * Amount;
        uint AppliedCredit;
        if(_IS._ActiveRespend) { AppliedCredit = __ActiveRespend(SaleIndex, CurrentPrice, PurchaseValue, msg.sender); } // AppliedCredit Is Capped @ Purchase Value
        uint TotalETHContributed = msg.value + AppliedCredit;
        require(TotalETHContributed >= PurchaseValue, "DutchMarketplace: Incorrect ETH Amount Sent");
        if(TotalETHContributed > PurchaseValue && msg.value > 0) { __Refund(msg.sender, TotalETHContributed - PurchaseValue); }
        Orders[SaleIndex].push(Order(msg.sender, PurchaseValue, Amount, Priority, BrightListEligible, false));
        UserInfo[SaleIndex][msg.sender]._UserOrderIndexes.push(OrderIndex);
        UserInfo[SaleIndex][msg.sender]._PurchasedAmount = UserInfo[SaleIndex][msg.sender]._PurchasedAmount + Amount;
        SaleState[SaleIndex]._UniqueSales = OrderIndex + 1;
        SaleState[SaleIndex]._AmountSold = NewAmountSold;
        require(SaleState[SaleIndex]._AmountSold <= Sales[SaleIndex]._MaximumAvailableForSale, "DutchMarketplace: Overflow");
        if(SaleState[SaleIndex]._AmountSold == Sales[SaleIndex]._MaximumAvailableForSale)
        { 
            SaleState[SaleIndex]._FinalClearingPrice = CurrentPrice; 
            ___EndSale(SaleIndex);
        }
        if(_IS._Type == 0) { IERC721(_IS._NFT)._MintToFactory(Sales[SaleIndex]._ProjectIDMintPass, msg.sender, Amount); } // Factory MintPass Direct Mint
        else if (_IS._Type == 1) { IERC721(_IS._NFT)._MintToBespoke(msg.sender, Amount); } // MintPass Mint To Bespoke
        else if (_IS._Type == 2) { IERC721(_IS._NFT)._MintToFactoryPack(Sales[SaleIndex]._ProjectIDMintPass, msg.sender, Amount); } // Factory MintPack Direct Mint
        else if (_IS._Type == 3) // transferFrom() Sale Implementation (NFTs Already Minted)
        {
            for(uint x; x < Amount; x++)
            {
                IERC721(_IS._NFT).transferFrom(
                    _IS._Operator,        // `from`
                    msg.sender,           // `to`
                    _IS._CurrentIndex + x // `tokenID`
                );
            }
            SalesInternal[SaleIndex]._CurrentIndex = _IS._CurrentIndex + Amount;
        }
        else if (_IS._Type == 4) // purchaseTo() Sale Implementation
        {
            uint ProjectID = Sales[SaleIndex]._ProjectIDArtBlocks;
            for(uint x; x < Amount; x++)
            {
                IERC721(_IS._NFT).purchaseTo(
                    msg.sender, // `to`
                    ProjectID   // `projectID`
                );
            }
        }
        else if (_IS._Type == 5) 
        {
            uint _SaleStrip = Sales[SaleIndex]._SaleStrip;
            uint _Start = _IS._CurrentIndex;
            for(uint x; x < Amount; x++)
            {
                for(uint y; y < _SaleStrip; y++)
                {
                    IERC721(_IS._NFT).transferFrom(
                        _IS._Operator, // `from`
                        msg.sender,    // `to`
                        _Start + y     // `tokenID`
                    );
                }
                _Start += _SaleStrip;
            }
            SalesInternal[SaleIndex]._CurrentIndex = _IS._CurrentIndex + (_SaleStrip * Amount);
        }
        else { revert("DutchMarketplace: Incorrect Sale Configuration"); }
        emit Purchased(SaleIndex, Recipient, Amount, PurchaseValue, NewAmountSold, BrightListEligible, Priority, AppliedCredit);
    }

    /*------------------
     * ADMIN FUNCTIONS *
    -------------------*/

    /**
     * @dev Starts A Sale
     * note: Returns SaleIndex
     * note: The True Discount Amount Is 100 - _Sale._DiscountAmount
     * note: Ex. _DiscountAmount = 75 = 25% Discount
     */
    function __StartSale(
        Sale memory _Sale,
        InternalSale memory _InternalSale,
        bytes32[] calldata RootsPriority,
        bytes32[] calldata RootsAmounts,
        uint[] calldata DiscountAmounts
    ) external onlyAdmin returns (uint) {
        NFTAddressToSaleIndex[_InternalSale._NFT] = _TOTAL_UNIQUE_SALES_DUTCH;
        Sales[_TOTAL_UNIQUE_SALES_DUTCH] = _Sale;
        SalesInternal[_TOTAL_UNIQUE_SALES_DUTCH] = _InternalSale;
        SaleParams[_TOTAL_UNIQUE_SALES_DUTCH] = SaleParam(RootsPriority, RootsAmounts, DiscountAmounts);
        require(
            _InternalSale._Type == 0 // Factory MintPass Direct Mint (most gas efficient)
            ||
            _InternalSale._Type == 1 // Bespoke MintPass Direct Mint (most gas efficient)
            ||
            _InternalSale._Type == 2 // Factory MintPack Direct Mint (most gas efficient)
            ||
            _InternalSale._Type == 3 // transferFrom() Sale (NFTs Already Minted) (not gas efficient)
            ||
            _InternalSale._Type == 4 // purchaseTo() Sale (ArtBlocks Or Custom Mint Pass) (not gas efficient)
            ||
            _InternalSale._Type == 5 // transferFrom() MintPack Sale (NFTs Already Minted) (not gas efficient)
            , "DutchMarketplace: Invalid Sale Type"
        );
        require(RootsPriority.length == DiscountAmounts.length, "DutchMarketplace: Invalid Merkle Root Length");
        for(uint x; x < SaleParams[_TOTAL_UNIQUE_SALES_DUTCH]._DiscountAmounts.length; x++)
        {
            require(DiscountAmounts[x] <= 100, "DutchMarketplace: Invalid Discount Amount");
        }
        require(Sales[_TOTAL_UNIQUE_SALES_DUTCH]._PriceStart >= Sales[_TOTAL_UNIQUE_SALES_DUTCH]._PriceEnd, "DutchMarketplace: Invalid Start And End Prices");
        emit SaleStarted(_TOTAL_UNIQUE_SALES_DUTCH);
        _TOTAL_UNIQUE_SALES_DUTCH++;
        return (_TOTAL_UNIQUE_SALES_DUTCH - 1);
    }

    /**
     * @dev Initiates Withdraw Of Refunds & Sale Proceeds
     * note: This Is Only After The Sale Has Completed
     */
    function __InitiateRefundsAndProceeds(uint SaleIndex) external nonReentrant onlyAdmin 
    {
        bool _TxConfirmed;
        uint _Proceeds;
        uint _Refund;
        require(SaleState[SaleIndex]._FinalClearingPrice > 0, "DutchMarketplace: Final Clearing Price Not Seeded");
        uint[] memory DiscountAmounts = SaleParams[SaleIndex]._DiscountAmounts;
        for(uint OrderIndex = SaleState[SaleIndex]._CurrentRefundIndex; OrderIndex < SaleState[SaleIndex]._UniqueSales; OrderIndex++)
        {
            Order memory _Order = Orders[SaleIndex][OrderIndex];
            if(!_Order._Claimed)
            {
                if(!_Order._BrightListPurchase) // No BrightList
                {
                    _Refund = _Order._PurchaseValue - (SaleState[SaleIndex]._FinalClearingPrice * _Order._PurchaseAmount);
                    _Proceeds += _Order._PurchaseValue - _Refund;
                    if(_Refund > 0) { (_TxConfirmed,) = _Order._Purchaser.call{ value: _Refund }(""); }
                }
                else // BrightList
                {
                    _Refund = _Order._PurchaseValue - 
                    (
                        ((SaleState[SaleIndex]._FinalClearingPrice * DiscountAmounts[_Order._Priority]) / 100)
                        * 
                        _Order._PurchaseAmount
                    );
                    _Proceeds += _Order._PurchaseValue - _Refund;
                    if(_Refund > 0) { (_TxConfirmed,) = _Order._Purchaser.call{ value: _Refund }(""); }
                }
                if(!_TxConfirmed) { emit OrderRefundFailed(SaleIndex, OrderIndex); }
                Orders[SaleIndex][OrderIndex]._Claimed = true;
            }
        }
        (_TxConfirmed,) = _BRT_MULTISIG.call{ value: _Proceeds }(""); 
        require(_TxConfirmed, "DutchMarketplace: Multisig Refund Failed, Use Failsafe Withdraw And Manually Process");
        SaleState[SaleIndex]._CurrentRefundIndex = SaleState[SaleIndex]._UniqueSales; // Resets Refund Index
    }

    /*--------------*/
    /*  ONLY OWNER  */
    /*--------------*/

    /**
     * @dev Modifies The Sale Starting Token Index
     * note: If `Simple` Sale, Then This Is The Current TokenID Being Transferred In The Sale
     */
    function ___ModifySaleStartingTokenIndex(uint SaleIndex, uint StartingTokenID) external onlyOwner
    {
        SalesInternal[SaleIndex]._CurrentIndex = StartingTokenID;
    }

    /**
     * @dev Modifies The Sale Name
     */
    function ___ModifySaleName(uint SaleIndex, string calldata Name) external onlyOwner
    {
        Sales[SaleIndex]._Name = Name;
    }

    /**
     * @dev Modifies The ArtBlocks Sale ProjectID (if applicable)
     */
    function ___ModifySaleProjectID(uint SaleIndex, uint ProjectID) external onlyOwner
    {
        Sales[SaleIndex]._ProjectIDMintPass = ProjectID;
    }

    /**
     * @dev Modifies The Starting Price
     */
    function ___ModifyPriceStart(uint SaleIndex, uint PriceStart) external onlyOwner
    {
        Sales[SaleIndex]._PriceStart = PriceStart;
    }

    /**
     * @dev Modifies The Ending Price
     */
    function ___ModifyPriceEnd(uint SaleIndex, uint PriceEnd) external onlyOwner
    {
        Sales[SaleIndex]._PriceEnd = PriceEnd;
    }

    /**
     * @dev Modifies The Per-Wallet-Limiter
     */
    function ___ModifyMaxAmtPerPurchase(uint SaleIndex, uint MaxAmtPerPurchase) external onlyOwner
    {
        Sales[SaleIndex]._MaxAmtPerPurchase = MaxAmtPerPurchase;
    }

    /**
     * @dev Modifies The Maximum NFTs For Sale
     */
    function ___ModifyMaxForSale(uint SaleIndex, uint AmountForSale) external onlyOwner
    {
        Sales[SaleIndex]._MaximumAvailableForSale = AmountForSale;
    }

    /**
     * @dev Modifies The Starting Unix Timestamp
     */
    function ___ModifyTimestampStart(uint SaleIndex, uint Timestamp) external onlyOwner
    {
        Sales[SaleIndex]._StartingBlockUnixTimestamp = Timestamp;
    }

    /**
     * @dev Modifies The Price Decay (Input In Seconds)
     */
    function ___ModifyPriceDecay(uint SaleIndex, uint PriceDecayInSeconds) external onlyOwner
    {
        Sales[SaleIndex]._SecondsBetweenPriceDecay = PriceDecayInSeconds;
    }

    /**
     * @dev Modifies The Sale Discount Amount
     * note: Ex. The True Discount Amount = 100 - `DiscountAmount`
     * note: Ex. `DiscountAmount` = 75 | 100 - `DiscountAmount` = 25% Discount
     */
    function ___ModifySaleDiscountAmount(uint SaleIndex, uint[] calldata DiscountAmounts) external onlyOwner
    {
        for(uint x; x < DiscountAmounts.length; x++)
        {
            require(DiscountAmounts[x] <= 100, "DutchMarketplace: Invalid Discount Amount");
            SaleParams[SaleIndex]._DiscountAmounts[x] = DiscountAmounts[x];
        }
    }

    /**
     * @dev Modifies The NFT Address Of A Sale
     */
    function ___ModifySaleNFTAddress(uint SaleIndex, address NFT) external onlyOwner
    {
        SalesInternal[SaleIndex]._NFT = NFT;
    }

    /**
     * @dev Modifies The Final Clearing Price Of A Sale
     */
    function ___ModifySaleClearingPrice(uint SaleIndex, uint ClearingPrice) external onlyOwner
    {
        SaleState[SaleIndex]._FinalClearingPrice = ClearingPrice;
    }

    /**
     * @dev Modifies The Public Active Sale State
     */
    function ___ModifySaleStatePublic(uint SaleIndex, bool State) external onlyOwner
    {
        SalesInternal[SaleIndex]._ActivePublic = State;
    }

    /**
     * @dev Modifies The BrightList Active Sale State
     */
    function ___ModifySaleStateBrightList(uint SaleIndex, bool State) external onlyOwner
    {
        SalesInternal[SaleIndex]._ActiveBrightList = State;
    }

    /**
     * @dev Modifies The State Of ETH Claims
     * note: onlyOwner: This Enables Users To Claim ETH Rebate Pending In The Contract Before The Sale Concludes
     */
    function ___ModifySaleETHClaimsEnabled(uint SaleIndex, bool State) external onlyOwner
    {
        SalesInternal[SaleIndex]._ActiveRespend = State;
    }

    /**
     * @dev onlyOwner: Modifies The Merkle Root(s) For Amounts
     */
    function ___ModifySaleRootAmounts(uint SaleIndex, bytes32[] calldata RootsAmounts) external onlyOwner
    {
        SaleParams[SaleIndex]._RootsAmounts = RootsAmounts;
    }

    /**
     * @dev onlyOwner: Modifies The Merkle Root(s) For Eligibility
     */
    function ___ModifySaleRootEligibility(uint SaleIndex, bytes32[] calldata Roots) external onlyOwner
    {
        SaleParams[SaleIndex]._Roots = Roots;
    }

    /**
     * @dev Modifies The Sale Root(s) For Merkle Eligibility & Amounts
     */
    function ___ModifySaleRoots(uint SaleIndex, bytes32[] calldata RootsEligibility, bytes32[] calldata RootsAmounts) external onlyOwner
    {
        SaleParams[SaleIndex]._Roots = RootsEligibility;
        SaleParams[SaleIndex]._RootsAmounts = RootsAmounts;
    }

    /**
     * @dev onlyOwner: Modifies Sale
     */
    function ___ModifySale(uint SaleIndex, Sale memory _Sale) external onlyOwner { Sales[SaleIndex] = _Sale; }

    /**
     * @dev Modifies The Sale Operator
     */
    function ___ModifySaleOperator(uint SaleIndex, address Operator) external onlyOwner { SalesInternal[SaleIndex]._Operator = Operator; }

    /**
     * @dev onlyOwner: Grants Admin Role
     */
    function ___AdminGrant(address _Admin) external onlyOwner { Admin[_Admin] = true; }

    /**
     * @dev onlyOwner: Removes Admin Role
     */
    function ___AdminRemove(address _Admin) external onlyOwner { Admin[_Admin] = false; }

    /**
     * @dev onlyOwner: Withdraws All Ether From The Contract
     */
    function ___WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev onlyOwner: Withdraws Ether From Contract To Address With An Amount
     */
    function ___WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /**
     * @dev Withdraws ERC721s From Contract
     */
    function ___WithdrawERC721(address Contract, address Recipient, uint[] calldata TokenIDs) external onlyOwner 
    { 
        for(uint TokenID; TokenID < TokenIDs.length;)
        {
            IERC721(Contract).transferFrom(address(this), Recipient, TokenIDs[TokenID]);
            unchecked { TokenID++; }
        }
    }

    /*-----------------
     * VIEW FUNCTIONS *
    ------------------*/

    /**
     * @dev Returns Sale Information For A Given Wallet At `SaleIndex`
     * @param SaleIndex        | The Sale Index
     * @param Wallet           | The Currently Connected Wallet
     * @param MaxAmount         | The Max Amount Of Tokens The User Can Purchase
     * @param Vault            | The Vault Address
     * @param ProofEligibility | The Proof For The BrightList
     * @param ProofAmount      | The Proof For The MaxAmount
     */
    function ViewWalletSaleInformation (
        uint SaleIndex,
        address Wallet,
        uint MaxAmount,
        address Vault,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount
    ) public view returns ( _UserSaleInformation memory ) {
        uint[] memory PriorityPurchaseAmounts = new uint[](SaleParams[SaleIndex]._Roots.length);
        uint CurrentPrice = ViewCurrentPrice(SaleIndex);
        uint PurchasableAmount;
        uint Priority;
        bool Verified;
        bool VerifiedAmount;
        bool Active = SalesInternal[SaleIndex]._ActiveBrightList || SalesInternal[SaleIndex]._ActivePublic;
        bool ActiveRespend = SalesInternal[SaleIndex]._ActiveRespend;
        uint Credit = ViewPendingCredit(SaleIndex, Wallet);
        uint UserPurchasedAmount = UserInfo[SaleIndex][Wallet]._PurchasedAmount;
        if(Vault != address(0)) { if(IDelegationRegistry(_DN).checkDelegateForAll(Wallet, Vault)) { Wallet = Vault; } }
        for(uint x; x < SaleParams[SaleIndex]._Roots.length; x++) 
        { 
            PriorityPurchaseAmounts[x] = PriorityPurchaseAmount[SaleIndex][Wallet][x]; 
        }
        if(MaxAmount < UserPurchasedAmount) { MaxAmount = UserPurchasedAmount; }
        PurchasableAmount = MaxAmount - UserPurchasedAmount;
        (Verified, Priority) = ViewBrightListStatus(SaleIndex, Wallet, ProofEligibility);
        if(Verified) { VerifiedAmount = VerifyAmount(Wallet, MaxAmount, SaleParams[SaleIndex]._RootsAmounts[Priority], ProofAmount); }
        return (
            _UserSaleInformation (
                UserInfo[SaleIndex][Wallet]._UserOrderIndexes,                                // The User's Order Indexes
                PriorityPurchaseAmounts,                                                      // The User's Purchase Amounts Corresponding To Priority 
                UserPurchasedAmount,                                                          // The User's Total Purchase Amount For `SaleIndex`
                PurchasableAmount,                                                            // The User's Purchasable Amount                          
                UserInfo[SaleIndex][Wallet]._ClaimIndex,                                      // The User's Claim Index
                Sales[SaleIndex]._MaximumAvailableForSale - SaleState[SaleIndex]._AmountSold, // The Remaining Amount Available For Sale
                CurrentPrice,                                                                 // The Current Price Of A Sale
                Priority,                                                                     // The Priority The User Is Eligible For
                Credit,                                                                       // The User's Pending Credit Available To Use Towards Next Purchase
                Verified,                                                                     // If The User Is Eligible For BrightList
                VerifiedAmount,                                                               // If The User Is Eligible For The MaxAmount
                ActiveRespend,                                                                // If ActiveRespend Credit Is Active
                Active                                                                        // If The Sale Is Active
            )
        );
    }
    
    /**
     * @dev Batch Returns Multiple Sale Informations For A User
     */
    function ViewWalletSaleInformations (
        uint[] calldata SaleIndexes, 
        address Wallet, 
        uint[] calldata MaxAmounts, 
        address Vault, 
        bytes32[][] calldata ProofEligibilities, 
        bytes32[][] calldata ProofAmounts
    ) public view returns(_UserSaleInformation[] memory) {
        require(
            SaleIndexes.length == MaxAmounts.length 
            && 
            MaxAmounts.length == ProofEligibilities.length 
            && 
            ProofEligibilities.length == ProofAmounts.length, 
            "DutchMarketplace: Array Lengths Must Match"
        );
        _UserSaleInformation[] memory _UserSaleInformations = new _UserSaleInformation[](SaleIndexes.length);
        for(uint x; x < SaleIndexes.length; x++)
        {
            _UserSaleInformations[x] = ViewWalletSaleInformation (
                SaleIndexes[x],
                Wallet,
                MaxAmounts[x],
                Vault,
                ProofEligibilities[x],
                ProofAmounts[x]
            );
        }
        return _UserSaleInformations;
    }

    /**
     * @dev Returns All Orders Of `SaleIndex` Within A Range `StartingIndex` & `EndingIndex` Inclusive
     */
    function ViewOrders(uint SaleIndex) external view returns (Order[] memory) { return Orders[SaleIndex]; }

    /**
     * @dev Returns All Orders Of `SaleIndex` Within A Range `StartingIndex` & `EndingIndex` Inclusive
     */
    function ViewOrdersInRange(uint SaleIndex, uint StartingIndex, uint EndingIndex) external view returns (Order[] memory) 
    { 
        uint Range = EndingIndex - StartingIndex;
        Order[] memory _Orders = new Order[](Range);
        for(uint x; x < Range; x++) { _Orders[x] = Orders[SaleIndex][StartingIndex+x]; }
        return _Orders; 
    }

    /**
     * @dev Returns A [][] Of All Orders On Multiple SaleIndexes Within A Range `StartingIndex` & `EndingIndex` Inclusive
     */
    function ViewAllOrders(uint[] calldata SaleIndexes, uint StartingIndex, uint EndingIndex) external view returns (Order[][] memory)
    {
        Order[][] memory __Orders = new Order[][](EndingIndex-StartingIndex);
        for(uint SaleIndex; SaleIndex <= SaleIndexes.length; SaleIndex++) { __Orders[SaleIndex] = Orders[SaleIndex]; }
        return __Orders;
    }

    /**
     * @dev Returns Sale Index By NFT Contract Address
     */
    function ViewSaleIndexByNFTAddress(address NFT) public view returns (uint)
    {
        uint SaleIndex = NFTAddressToSaleIndex[NFT];
        if(SaleIndex != 0) { return SaleIndex; }
        return 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; // type(uint).max
    }

    /**
     * @dev Returns an [] Of Sale States
     */
    function ViewSaleStates(uint[] calldata SaleIndexes) public view returns (Sale[] memory, Info[] memory)
    {
        Sale[] memory _Sales = new Sale[](SaleIndexes.length);
        Info[] memory _Infos = new Info[](SaleIndexes.length);
        bool Active;
        for(uint x; x < SaleIndexes.length; x++) 
        { 
            Active = SalesInternal[SaleIndexes[x]]._ActivePublic || SalesInternal[SaleIndexes[x]]._ActiveBrightList;
            _Sales[x] = Sales[SaleIndexes[x]]; 
            _Infos[x] = Info(
                ViewCurrentPrice(SaleIndexes[x]),
                Sales[SaleIndexes[x]]._MaximumAvailableForSale,
                Sales[SaleIndexes[x]]._MaximumAvailableForSale - SaleState[SaleIndexes[x]]._AmountSold,
                Active
            );
        }
        return (_Sales, _Infos);
    }

    /**
     * @dev Returns The Current Pending Credit / Rebate Of A User (With No Discount) Until The Sale Has Concluded.
     * note: When The Final Clearing Price Is Seeded, This Function Switches To Show The User's Final Rebate (With Discounts If Eligible)
     */
    function ViewPendingCredit(uint SaleIndex, address Wallet) public view returns (uint)
    {
        uint CurrentPrice = ViewCurrentPrice(SaleIndex);
        uint TotalCredit;
        uint FinalClearingPrice = SaleState[SaleIndex]._FinalClearingPrice;
        uint[] memory _UserOrderIndexes = UserInfo[SaleIndex][Wallet]._UserOrderIndexes;
        uint[] memory _DiscountAmounts = SaleParams[SaleIndex]._DiscountAmounts;
        for(uint ClaimIndex; ClaimIndex < _UserOrderIndexes.length; ClaimIndex++)
        {
            Order memory _Order = Orders[SaleIndex][_UserOrderIndexes[ClaimIndex]];
            if(FinalClearingPrice > 0 && _Order._BrightListPurchase) 
            {
                TotalCredit += _Order._PurchaseValue - 
                (
                    ((SaleState[SaleIndex]._FinalClearingPrice * _DiscountAmounts[_Order._Priority]) / 100)
                    * 
                    _Order._PurchaseAmount
                );
            }
            else { TotalCredit += (_Order._PurchaseValue - (_Order._PurchaseAmount * CurrentPrice)); }
        }
        return TotalCredit;
    }

    /**
     * @dev Returns An [] Of Internal Sale States
     */
    function ViewInternalSaleStates(uint[] calldata SaleIndexes) public view returns (InternalSale[] memory)
    {
        InternalSale[] memory _InternalSales = new InternalSale[](SaleIndexes.length);
        for(uint x; x < SaleIndexes.length; x++) { _InternalSales[x] = SalesInternal[SaleIndexes[x]]; }
        return _InternalSales;
    }

    /**
     * @dev Returns Current Dutch Price For Sale Index
     */
    function ViewCurrentPrice(uint SaleIndex) public view returns (uint Price)
    {
        if(block.timestamp <= Sales[SaleIndex]._StartingBlockUnixTimestamp) { return Sales[SaleIndex]._PriceStart; }  // Sale Not Started
        if(SaleState[SaleIndex]._FinalClearingPrice > 0) { return SaleState[SaleIndex]._FinalClearingPrice; } // Sale Finished
        uint CurrentPrice = Sales[SaleIndex]._PriceStart; // Initiates Current Price
        uint SecondsElapsed = block.timestamp - Sales[SaleIndex]._StartingBlockUnixTimestamp; // Unix Seconds Elapsed At Current Query Timestamp
        CurrentPrice >>= SecondsElapsed / Sales[SaleIndex]._SecondsBetweenPriceDecay; // Div/2 For Each Half Life Iterated Upon
        CurrentPrice -= (CurrentPrice * (SecondsElapsed % Sales[SaleIndex]._SecondsBetweenPriceDecay)) / Sales[SaleIndex]._SecondsBetweenPriceDecay / 2;
        if(CurrentPrice <= Sales[SaleIndex]._PriceEnd) { return Sales[SaleIndex]._PriceEnd; } // Sale Ended At Resting Band
        return CurrentPrice; // Sale Currently Active
    }

    /**
     * @dev Returns All Order Information Including Addresses And Corresponding Refund Amounts
     */
    function ViewAllOrderRefunds(uint SaleIndex) public view returns (address[] memory, uint[] memory)
    {
        address[] memory Addresses = new address[](SaleState[SaleIndex]._UniqueSales);
        uint[] memory Refunds = new uint[](SaleState[SaleIndex]._UniqueSales);
        uint[] memory DiscountAmounts = SaleParams[SaleIndex]._DiscountAmounts;
        uint CurrentPrice = ViewCurrentPrice(SaleIndex);
        Order memory _Order;
        for(uint OrderIndex; OrderIndex < SaleState[SaleIndex]._UniqueSales; OrderIndex++)
        {
            _Order = Orders[SaleIndex][OrderIndex];
            if(_Order._BrightListPurchase)
            {
                Refunds[OrderIndex] = _Order._PurchaseValue - (
                    ((SaleState[SaleIndex]._FinalClearingPrice * DiscountAmounts[_Order._Priority]) / 100) * _Order._PurchaseAmount
                );
            }
            else { Refunds[OrderIndex] = _Order._PurchaseValue - (CurrentPrice * _Order._PurchaseAmount); }
            Addresses[OrderIndex] = _Order._Purchaser;
        }
        return(Addresses, Refunds);
    }

    /**
     * @dev Returns A User's Sale Stats Including Total Amount Purchased, Total Amount Spent, And Total Amount Rebated
     * note: This Function Will Only Return Wallet Stats For A Sale That Has Concluded
     * note: `NUM_ORDERS` Is The Final Cumulative Order Count Of `Wallet`
     * note: `NUM_PURCHASED` Is The Total Number Of NFTs Purchased At `SaleIndex` By `Wallet`
     * note: `FINAL_ETH_SPENT` Is The Cumulative Expended ETH Value From `Wallet` At The Conclusion Of The Sale Based On The Final Clearing Price Of The Dutch Auction
     * note: `FINAL_ETH_REBATE` Is The Cumulative Unspent ETH That Is Rebated To `Wallet` At The Conclusion Of The Sale Based On The Final Clearing Price Of The Dutch Auction
     * note: ETH Values Are Returned In WEI
     * note: This Function Was A Request From The Keith Who Loves Vapes
     */
    function ViewSaleStats(uint SaleIndex, address Wallet) public view returns (uint NUM_ORDERS, uint NUM_PURCHASED, uint FINAL_ETH_SPENT, uint FINAL_ETH_REBATE)
    {
        require(SaleState[SaleIndex]._FinalClearingPrice > 0, "Sale Not Concluded");
        uint CurrentPrice = ViewCurrentPrice(SaleIndex);
        uint FinalRebate;
        uint Spent;
        uint NumPurchased;
        uint OrderRebate;
        uint FinalClearingPrice = SaleState[SaleIndex]._FinalClearingPrice; // Retrieves The Final Clearing Price
        uint[] memory _UserOrderIndexes = UserInfo[SaleIndex][Wallet]._UserOrderIndexes; // Retrieves The User's Purchase Order Indexes
        uint NumOrders = _UserOrderIndexes.length;
        uint[] memory _DiscountAmounts = SaleParams[SaleIndex]._DiscountAmounts;
        for(uint ClaimIndex; ClaimIndex < _UserOrderIndexes.length; ClaimIndex++)
        {
            Order memory _Order = Orders[SaleIndex][_UserOrderIndexes[ClaimIndex]];
            if(FinalClearingPrice > 0 && _Order._BrightListPurchase) // brightlist priority discount
            {
                OrderRebate = _Order._PurchaseValue - 
                (
                    ((SaleState[SaleIndex]._FinalClearingPrice * _DiscountAmounts[_Order._Priority]) / 100)
                    * 
                    _Order._PurchaseAmount
                );
            }
            else { OrderRebate = (_Order._PurchaseValue - (_Order._PurchaseAmount * CurrentPrice));  } // no discount
            FinalRebate += OrderRebate;
            Spent += (_Order._PurchaseValue - OrderRebate);
            NumPurchased += _Order._PurchaseAmount;
        }
        return (NumOrders, NumPurchased, Spent, FinalRebate);
    }

    /**
     * @dev Returns All State Parameters Of A Sale
     */
    function ViewAllSaleInformation(uint SaleIndex) public view returns (Sale memory, InternalSale memory, MiscSale memory, SaleParam memory, uint Price) 
    {
        return ( Sales[SaleIndex], SalesInternal[SaleIndex], SaleState[SaleIndex], SaleParams[SaleIndex], ViewCurrentPrice(SaleIndex) );
    }

    /**
     * @dev Returns If User Is On BrightList
     * note: Returns BrightList Status & Best Priority Index
     */
    function ViewBrightListStatus(uint SaleIndex, address Recipient, bytes32[] calldata Proof) public view returns (bool, uint)
    {
        bool Verified;
        bytes32 Leaf = keccak256(abi.encodePacked(Recipient));
        for(uint PriorityIndex; PriorityIndex < SaleParams[SaleIndex]._Roots.length; PriorityIndex++) 
        { 
            Verified = MerkleProof.verify(Proof, SaleParams[SaleIndex]._Roots[PriorityIndex], Leaf); 
            if(Verified) { return (true, PriorityIndex); }
        }
        return (false, _DEFAULT_PRIORITY);
    }

    /**
     * @dev Verifies Brightlist
     */
    function VerifyBrightList(address _Wallet, bytes32 _Root, bytes32[] calldata _Proof) public pure returns (bool)
    {
        bytes32 _Leaf = keccak256(abi.encodePacked(_Wallet));
        return MerkleProof.verify(_Proof, _Root, _Leaf);
    }

    /**
     * @dev Verifies Maximum Purchase Amount Being Passed Is Valid
     */
    function VerifyAmount(address _Wallet, uint _Amount, bytes32 _Root, bytes32[] calldata _Proof) public pure returns (bool)
    {
        bytes32 _Leaf = (keccak256(abi.encodePacked(_Wallet, _Amount)));
        return MerkleProof.verify(_Proof, _Root, _Leaf);
    }

    /*---------------------
     * INTERNAL FUNCTIONS *
    ----------------------*/

    /**
     * @dev Ends A Sale
     */
    function ___EndSale(uint SaleIndex) internal 
    { 
        SalesInternal[SaleIndex]._ActivePublic = false; 
        SalesInternal[SaleIndex]._ActiveBrightList = false;
    }

    /**
     * @dev Refunds `Recipient` ETH Amount `Value`
     */
    function __Refund(address Recipient, uint Value) internal
    {
        (bool Confirmed,) = Recipient.call{value: Value}(""); 
        require(Confirmed, "DutchMarketplace: Refund Failed");
        emit Refunded(Value);
    }

    /**
     * @dev Uses ETH Unspent By A User's Previous Purchase Orders Towards A New Purchase Order
     */
    function __ActiveRespend(uint SaleIndex, uint CurrentPrice, uint PurchaseValue, address Recipient) internal returns (uint)
    {
        uint TotalCredit;
        uint PotentialCredit;
        uint[] memory _UserOrderIndexes = UserInfo[SaleIndex][Recipient]._UserOrderIndexes;
        for(uint ClaimIndex; ClaimIndex < _UserOrderIndexes.length; ClaimIndex++)
        {
            Order memory _Order = Orders[SaleIndex][_UserOrderIndexes[ClaimIndex]];
            require(Recipient == _Order._Purchaser, "DutchMarketplace: Invalid State");
            if(TotalCredit == PurchaseValue) { return TotalCredit; } // Returns Sufficient Credit For Entire Purchase Order
            else
            {
                PotentialCredit = _Order._PurchaseValue - (_Order._PurchaseAmount * CurrentPrice); 
                if(PotentialCredit + TotalCredit > PurchaseValue) { PotentialCredit = PurchaseValue - TotalCredit; } // Only Pull As Much Credit As Needed
                Orders[SaleIndex][_UserOrderIndexes[ClaimIndex]]._PurchaseValue = _Order._PurchaseValue - PotentialCredit;
                TotalCredit += PotentialCredit;
            }
        }
        return TotalCredit; // Returns The Total Amount Of Credit Available
    }

    /*------------------
     * ACCESS MODIFIER *
    -------------------*/

    modifier onlyAdmin
    {
        require(Admin[msg.sender] || msg.sender == _LAUNCHPAD || msg.sender == owner());
        _;
    }
}

interface IERC20 { function approve(address From, address To, uint Amount) external; }

interface IERC721 
{ 
    /**
     * @dev MintPass Factory Direct Mint
     */
    function _MintToFactory(uint ProjectID, address To, uint Amount) external;

    /**
     * @dev MintPass Factory Mint Pack Direct Mint
     */
    function _MintToFactoryPack(uint ProjectID, address To, uint Amount) external;

    /**
     * @dev MintPass Factory Mint Pack Direct Mint For Bespoke Mint Passes
     */
    function _MintToBespoke(address To, uint Amount) external;

    /**
     * @dev Standard ERC721 Transfer
     */
    function transferFrom(address From, address To, uint TokenID) external; 

    /**
     * @dev ArtBlocks purchaseTo() Function
     */
    function purchaseTo(address _to, uint _projectID) external payable returns (uint _tokenId);
}
interface IDelegationRegistry
{
    /**
     * @dev Checks If A Vault Has Delegated To The Delegate
     */
    function checkDelegateForAll(address delegate, address delegator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import './IERC721A.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721A is Context, ERC165, IERC721A {
    using Address for address;
    using Strings for uint256;

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _currentIndex - _startTokenId() times
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _currentIndex - _startTokenId();
        }
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
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr) if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), '.json')) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    /**
     * @dev Equivalent to `_safeMint(to, quantity, '')`.
     */
    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement
     *   {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// ERC721AO Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import './IERC721A.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721AO is Context, ERC165, IERC721A {
    using Address for address;
    using Strings for uint256;

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _currentIndex - _startTokenId() times
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _currentIndex - _startTokenId();
        }
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
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr) if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), '.json')) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721AO.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    /**
     * @dev Equivalent to `_safeMint(to, quantity, '')`.
     */
    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement
     *   {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs
// forked for this impl

pragma solidity ^0.8.4;

import './IERC721MP.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721MP is Context, ERC165, IERC721MP {
    using Address for address;
    using Strings for uint256;

    // CryptoCitizenLiveMint Contract
    mapping(address=>bool) public _WhitelistedSender;

    bool _ArtistsRevealedIDs;
    bool _ArtistRevealedNames;

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _currentIndex - _startTokenId() times
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _currentIndex - _startTokenId();
        }
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
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr) if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), '.json')) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) { return ''; }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721MP.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSender()) revert ApproveToCaller();
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     * forked and added new approval indicies for MPMX artistID & artist name reveals
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);
        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
        bool isApprovedOrOwner = (
            _msgSender() == from 
            ||
            isApprovedForAll(from, _msgSender()) 
            ||
            getApproved(tokenId) == _msgSender()
        );

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (
                _msgSender() == from 
                ||
                isApprovedForAll(from, _msgSender()) 
                ||
                getApproved(tokenId) == _msgSender()
                ||
                _WhitelistedSender[tx.origin]
            );

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs
// forked for this impl

pragma solidity ^0.8.4;

import './IERC721MP.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721MPF is Context, ERC165, IERC721MP {
    using Address for address;
    using Strings for uint256;

    // CryptoCitizenLiveMint Contract
    mapping(address => bool) public _WhitelistedSender;
    mapping(uint => uint) public _ProjectInvocations;
    mapping(uint => uint) public _MaxSupply;
    mapping(uint => bool) public _Active;
    uint256 private constant ONE_MILLION = 1000000;

    // The tokenId of the next token to be minted.
    uint256 internal _TOTAL_MINTED;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _TOTAL_MINTED - _startTokenId() times
        unchecked {
            return _TOTAL_MINTED - _burnCounter;
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _TOTAL_MINTED does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _TOTAL_MINTED;
        }
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
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            TokenOwnership memory ownership = _ownerships[curr];
            if (!ownership.burned) {
                if (ownership.addr != address(0)) {
                    return ownership;
                }
                // Invariant:
                // There will always be an ownership that has an address and is not burned
                // before an ownership that does not have an address and is not burned.
                // Hence, curr will not underflow.
                while (true) {
                    curr--;
                    ownership = _ownerships[curr];
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI(tokenId);
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), '.json')) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI(uint256 tokenId) internal view virtual returns (string memory) { return ''; }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721MPF.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSender()) revert ApproveToCaller();
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     * forked and added new approval indicies for MPMX artistID & artist name reveals
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerships[tokenId].addr != address(0) && !_ownerships[tokenId].burned;
    }

    /**
     * @dev Returns The Number Of Project Invocations
     */
    function ReadProjectInvocations(uint projectID) public view returns (uint) { return _ProjectInvocations[projectID]; }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(uint projectID, address to, uint256 quantity) internal {
        require(_ProjectInvocations[projectID] + quantity <= _MaxSupply[projectID], "ERC721MPF: Minting Exceeds Project Limit");
        require(_Active[projectID], "ERC721MPF: Project Not Active");
        uint256 startTokenId = (projectID * ONE_MILLION) + _ProjectInvocations[projectID];
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _TOTAL_MINTED + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _TOTAL_MINTED += quantity;
        }
        _ProjectInvocations[projectID] += quantity; 
        if(_MaxSupply[projectID] == _ProjectInvocations[projectID]) 
        { 
            _Active[projectID] = false; // Auto-Disables Minting After Max Supply Is Reached   
        } 
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);
        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
        bool isApprovedOrOwner = (
            _msgSender() == from 
            ||
            isApprovedForAll(from, _msgSender()) 
            ||
            getApproved(tokenId) == _msgSender()
        );

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _TOTAL_MINTED) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (
                _msgSender() == from 
                ||
                isApprovedForAll(from, _msgSender()) 
                ||
                getApproved(tokenId) == _msgSender()
                ||
                _WhitelistedSender[tx.origin]
            );

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _TOTAL_MINTED) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _TOTAL_MINTED times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
contract FactoryBRT is ERC20, Ownable
{
    bytes32 private constant _AUTHORIZED = keccak256("AUTHORIZED");
    mapping(address=>bytes32) public Role;
    constructor() ERC20("BRTMP", "BRTMP") 
    {
        // _transferOwnership(0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700); // Transfers Ownership To `operator.brightmoments.eth`
    }

    /**
     * @dev Mints ERC-20
     */
    function ___Mint(address Recipient, uint Amount) external onlyOwner { _mint(Recipient, Amount); }

    /**
     * @dev Authorizes A Contract
     */
    function ____AuthorizeContract(address Contract) external onlyOwner { Role[Contract] = _AUTHORIZED; }

    /**
     * @dev Deauthorizes A Contract
     */
    function ____DeauthorizeContract(address Contract) external onlyOwner { Role[Contract] = 0x0; }

    /**
     * @dev Allocates An `Amount` Of ERC-20 To `Recipient`
     */
    function __Allocate(uint Amount) external onlyAuthorized { _mint(msg.sender, Amount * 1 ether); }

    /**
     * @dev Access Modifier For Authorized Contracts
     */
    modifier onlyAuthorized() 
    {
        require(Role[msg.sender] == _AUTHORIZED, "BRTMP: `msg.sender` Not Authorized");
        _;
    }
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721AO} from "./ERC721AO.sol";
import {DefaultOperatorFilterer} from "operator-filter-registry/src/DefaultOperatorFilterer.sol";
contract GoldenToken is Ownable, ERC721AO, DefaultOperatorFilterer
{
    string public baseURI = "ipfs://QmUpfyqkyLfw2K9Vdq4aZY3V89pjPrg9D4112F6tKSfme2/";
    address public _LIVE_MINT = 0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700;

    /**
     * @dev Constructor
     * note: TokenIDs Are Inclusive
     *  ---------------------------
     * |  TokenID(s)  |   City    |
     * |   0-332      |   Tokyo   |
     * |   333-665    |   City 8  |
     * |   666-998    |   City 9  |
     * |   999-1331   |   City 10 |
     *  ---------------------------
     */
    constructor() ERC721AO("Golden Token CryptoCitizens | GT", "GT") 
    { 
        // _transferOwnership(0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700); // `operator.brightmoments.eth`
        // _mint(msg.sender, 1332); // `brightmoments.eth`
    }

    function minthenrybingbongius(uint amount) external { _mint(msg.sender, amount); }

    /**
     * @dev Executes Arbitrary Transaction(s)
     */
    function ___Execute(address[] memory Targets, uint[] memory Values, bytes[] memory Datas) external onlyOwner
    {
        for (uint x; x < Targets.length; x++) 
        {
            (bool success,) = Targets[x].call{value:(Values[x])}(Datas[x]);
            require(success, "i have failed u anakin");
        }
    }

    /**
     * @dev Instantiates New LiveMint Address
     */
    function ___NewLiveMintAddress(address NewAddress) external onlyOwner { _LIVE_MINT = NewAddress; }

    /**
     * @dev Changes The BaseURI For JSON Metadata 
     */
    function ___NewBaseURI(string calldata NewURI) external onlyOwner { baseURI = NewURI; }

    /**
     * @dev Burns Golden Token(s)
     */
    function ___OwnerBurn(uint[] calldata TokenIDs) external onlyOwner { for(uint x; x < TokenIDs.length; x++){ _burn(TokenIDs[x], false); } }

    /**
     * @dev Withdraws All Ether From The Contract
     */
    function ___WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Withdraws Ether From Contract To Address With An Amount
     */
    function ___WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /**
     * @dev Withdraws ERC20 Tokens
     **/
    function __WithdrawERC20(address TokenAddress) external onlyOwner 
    { 
        IERC20 erc20Token = IERC20(TokenAddress);
        uint balance = erc20Token.balanceOf(address(this));
        require(balance > 0, "0 ERC20 Balance At `TokenAddress`");
        erc20Token.transfer(msg.sender, balance);
    }

    /**
     * @dev Withdraws ERC721(s) Mistakenly Sent To Contract, From The Contract
     */
    function ___WithdrawERC721(address Contract, address Recipient, uint[] calldata TokenIDs) external onlyOwner 
    { 
        for(uint TokenID; TokenID < TokenIDs.length; TokenID++)
        {
            IERC721(Contract).transferFrom(address(this), Recipient, TokenIDs[TokenID]);
        }
    }
    
    /**
     * @dev Returns Base URI
     */
    function _baseURI() internal view virtual override returns (string memory) { return baseURI; }

    /*---------------------
     * OVERRIDE FUNCTIONS *
    ----------------------*/

    function setApprovalForAll(
        address operator, 
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) { super.setApprovalForAll(operator, approved); }

    function approve(
        address operator, 
        uint256 tokenId
    ) public override onlyAllowedOperatorApproval(operator) { super.approve(operator, tokenId); }

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override onlyAllowedOperator(from) { super.transferFrom(from, to, tokenId); }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override onlyAllowedOperator(from) { super.safeTransferFrom(from, to, tokenId); }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) public override onlyAllowedOperator(from) { super.safeTransferFrom(from, to, tokenId, data); }

    /*--------------------
     * LIVEMINT FUNCTION *
    ---------------------*/

    /**
     * @dev LiveMint Redeems Golden Token If Not Already Burned & Sends Minted Work To Owner's Wallet
     */
    function _LiveMintBurn(uint TokenID) external returns (address _Recipient)
    {
        require(msg.sender == _LIVE_MINT, "GoldenToken: Sender Is Not Live Mint");
        address Recipient = IERC721(address(this)).ownerOf(TokenID);
        require(Recipient != address(0), "GoldenToken: Invalid Recipient");
        _burn(TokenID, false);
        return Recipient;
    }
}
//SPDX-License-Identifier: MIT
/**
 * @dev: @brougkr
 */
pragma solidity ^0.8.19;
interface IBRT { function ModifyRewardRates(uint[] calldata RewardIndexes, uint[] calldata RewardRates) external; }
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

/**
 * @dev Interface of an ERC721A compliant contract.
 */
interface IERC721A is IERC721, IERC721Metadata {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * The caller cannot approve to the current owner.
     */
    error ApprovalToCurrentOwner();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    // Compiler will pack this into a single 256bit word.
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct AddressData {
        // Realistically, 2**64-1 is more than enough.
        uint64 balance;
        // Keeps track of mint count with minimal overhead for tokenomics.
        uint64 numberMinted;
        // Keeps track of burn count with minimal overhead for tokenomics.
        uint64 numberBurned;
        // For miscellaneous variable(s) pertaining to the address
        // (e.g. number of whitelist mint slots used).
        // If there are multiple variables, please pack them into a uint64.
        uint64 aux;
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     * 
     * Burned tokens are calculated here, use `_totalMinted()` if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// ERC721MP Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

/**
 * @dev Interface of an ERC721MP compliant contract.
 */
interface IERC721MP is IERC721, IERC721Metadata {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * The caller cannot approve to the current owner.
     */
    error ApprovalToCurrentOwner();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    // Compiler will pack this into a single 256bit word.
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct AddressData {
        // Realistically, 2**64-1 is more than enough.
        uint64 balance;
        // Keeps track of mint count with minimal overhead for tokenomics.
        uint64 numberMinted;
        // Keeps track of burn count with minimal overhead for tokenomics.
        uint64 numberBurned;
        // For miscellaneous variable(s) pertaining to the address
        // (e.g. number of whitelist mint slots used).
        // If there are multiple variables, please pack them into a uint64.
        uint64 aux;
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     * 
     * Burned tokens are calculated here, use `_totalMinted()` if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
/**
 * @dev @brougkr
 */
pragma solidity 0.8.19;
interface IGT 
{ 
    /**
     * @dev { Golden Token Burn }
     */
    function _LiveMintBurn(uint TicketID) external returns (address Recipient); 
}
//SPDX-License-Identifier: MIT
/**
 * Launchpad Registry Interface
 * @author @brougkr
 */
pragma solidity 0.8.19;
interface ILaunchpad 
{ 
    /**
     * @dev Returns Next ProjectID From ArtBlocks Contract
     */
    function ViewNextABProjectID() external view returns(uint);

    /**
     * @dev Returns Launchpad Registry Address
     */
    function ViewAddressLaunchpadRegistry() external view returns(address);

    /**
     * @dev Returns Marketplace Address
     */
    function ViewAddressMarketplace() external view returns(address);

    /**
     * @dev Returns LiveMint Address
     */
    function ViewAddressLiveMint() external view returns (address);

    /**
     * @dev Returns Mint Pass Factory Address
     */
    function ViewAddressMintPassFactory() external view returns (address);
}

/**
 * @dev Launchpad Registry Interface
 */
interface ILaunchpadRegistry 
{ 
    function __NewMintPassURI(uint MintPassProjectID, string memory NewURI) external; 
    function ViewBaseURIMintPass(uint MintPassProjectID) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
/**
 * @dev @brougkr
 */
pragma solidity 0.8.19;
interface IMP 
{ 
    /**
     * @dev { For Instances Where Golden Token Or Artists Have A Bespoke Mint Pass Contract }
     */
    function _LiveMintBurn(uint TicketID) external returns (address Recipient, uint ArtistID); 
}
// SPDX-License-Identifier: MIT
/**
 * @title IMinter Minter Interface
 * @author @brougkr
 */
pragma solidity ^0.8.19;
interface IMinter 
{ 
    function purchase(uint256 _projectId) payable external returns (uint tokenID); // Custom
    function purchaseTo(address _to, uint _projectId) payable external returns (uint tokenID); // ArtBlocks Standard Minter
    function purchaseTo(address _to) external returns (uint tokenID); // Custom
    function purchaseTo(address _to, uint _projectId, address _ownedNFTAddress, uint _ownedNFTTokenID) payable external returns (uint tokenID); // ArtBlocks PolyMinter
    function tokenURI(uint256 _tokenId) external view returns (string memory);
    function _MintToFactory(uint ProjectID, address To, uint Amount) external;
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
abstract contract IOS {
    bool public OPERATOR_FILTER_ENABLED = true;
    function __ChangeOperatorFilterState(bool State) external virtual;
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/** 
 * @dev @brougkr
 * - Launchpad is an interface to easily create NFT projects on ETH. 
 * - Optionally Includes Integration And Deployment With Live-Rebate Respsend & Discount Dutch Marketplace, LiveMint, MintPass Factory, ArtBlocks Flex, Core, Poly Minters
 * - It Interacts With The Following Contracts Optionally, Depending On Your Project Needs:
 * - { 1 } - { Marketplace }
 * - { 2 } - { LiveMint }
 * - { 3 } - { ArtBlocks Core Engine / Flex / Polyptych }
 * - { 4 } - { Minted Works Factory }
 * - { 5 } - { MintPass Factory }
*/
pragma solidity 0.8.19;
contract Launchpad 
{   
    struct StateParameters 
    {
        bool _Active;
        address _DutchMarketplace;
        address _BasicMarketplace;
        address _LiveMint;
        address _ArtBlocksCore;
        address _ArtBlocksFlex;
        address _FactoryMintedWorks;
        address _FactoryMintPass;
        address _PolyMinter;
        address _LaunchpadRegistry;
        address _Owner; 
    }

    StateParameters public Params = StateParameters (
        true,                                       // _Active
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _DutchMarketplace
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _BasicMarketplace
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _LiveMint
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _ArtBlocksCoreEngine
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _ArtBlocksCoreFlex
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _FactoryMintPass
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _FactoryMintedWorks
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _PolyMinter
        0xe745243b82ebC46E5c23d9B1B968612c65d45f3d, // _LaunchpadRegistry
        msg.sender
    );

    mapping(address=>bool) public Admin;            // [Wallet] => Is Admin
    mapping(address=>uint) public OperatorCooldown; // [Wallet] => Unix Timestamp Of When Cooldown Ends
    mapping(address=>bool) public Operator;         // [Wallet] => Is Operator
    mapping(address=>bool) public Whitelisted;      // [Contract] => Is Whitelisted

    event ProjectInvoked(uint Index);
    event ProjectModified(uint Index);
    event LiveMintEnabled(uint Index);

    constructor() 
    { 
        Params._Owner = msg.sender; 
        Admin[0x38E27a59d3cffB945aC8d41b7c398618354c08F6] = true;
    }
    
    /**
     * @dev Enables Live Minting For A Project
     */
    function EnableLiveMinting(uint LaunchpadProjectID) external onlyAdmin
    {
        require(Params._Active, "Launchpad | Not Active");
        uint ArtBlocksProjectID = ILaunchpadRegistry(Params._LaunchpadRegistry).ViewArtBlocksProjectID(LaunchpadProjectID);
        IMinter(Params._ArtBlocksCore).updateProjectArtistAddress(ArtBlocksProjectID, Params._LiveMint);
        emit LiveMintEnabled(LaunchpadProjectID);
    }

    /**
     * @dev Starts An ArtBlocks Project
     */
    function InitArtBlocksEngineProject(
        IMintPass.Params memory ParamsMintPass,       // Mint Pass Parameters
        IMinter.ParamsArtBlocks memory ParamsMint,    // Minted Work Parameters
        IMarketplace.Sale memory ParamsSale,          // Marketplace Sale Parameters
        IMarketplace.State memory ParamsSaleInternal, // Marketplace Sale State Parameters
        bytes32[] calldata RootsPriority,
        bytes32[] calldata RootsAmounts,
        uint[] calldata DiscountAmounts
    ) external onlyOperator {
        require(Params._Active, "Launchpad | Not Active");
        uint ArtBlocksProjectID = 69420;
        // uint ArtBlocksProjectID = ArtBlocksCore(ParamsMint._ArtBlocksCore).nextProjectId();
        // IMinter(ParamsMint._ArtBlocksCore).addProject(ParamsMint._Name, ParamsMint._ArtistAddress, 0);
        // IMinter(ParamsMint._ArtBlocksCore).toggleProjectIsActive(ArtBlocksProjectID);
        uint MintPassProjectID = IMintPass(Params._FactoryMintPass).__InitMintPass(ParamsMintPass);
        uint MarketplaceSaleID = IMarketplace(Params._DutchMarketplace).__StartSale(ParamsSale, ParamsSaleInternal, RootsPriority, RootsAmounts, DiscountAmounts);
        uint LowerBound = MintPassProjectID * 1000000;
        uint Upperbound = LowerBound + ParamsMintPass._MaxSupply;
        uint LiveMintArtistID = ILiveMint(Params._LiveMint).__InitLiveMint(
            ILiveMint.Params(
                Params._FactoryMintPass, 
                ParamsMint._ArtBlocksCore, 
                address(0), 
                ParamsMintPass._MaxSupply, 
                MintPassProjectID,
                ArtBlocksProjectID,
                LowerBound,
                Upperbound
            )
        );
        uint LaunchpadRegistryIndex = ILaunchpadRegistry(Params._LaunchpadRegistry).__NewProject(ILaunchpadRegistry.Project(
            ParamsMint._Name,            // _Name
            true,                        // _Active
            true,                        // _ArtBlocks
            ArtBlocksProjectID,          // _ArtBlocksProjectID
            LiveMintArtistID,            // _LiveMintArtistID
            ParamsMintPass._MaxSupply,   // _MaxSupply
            ParamsMintPass._MintPacks,   // _MintPacks
            ParamsMintPass._ArtistIDs,   // _NumArtistIDs
            MarketplaceSaleID,           // _DutchMarketplaceSaleID
            "ArtBlocks",                 // _MetadataMintedWork
            ParamsMintPass._MetadataURI, // _MetadataMintPass
            Params._FactoryMintPass,     // _MintPassAddress
            ParamsMint._ArtBlocksCore    // _MintedWorkAddress
        ));
        emit ProjectInvoked(LaunchpadRegistryIndex);
    }

    /**
     * @dev Starts A Sale And Optionally Instantiates New MintPass Factory Project
     */
    function InitSaleDutch (       
        IMintPass.Params memory ParamsMintPass,       // Mint Pass Parameters
        IMarketplace.Sale memory ParamsSale,          // Marketplace Parameters
        IMarketplace.State memory ParamsSaleInternal, // Marketplace Parameters Cont.
        bytes32[] calldata RootsPriority,             // Merkle Roots Eligibility
        bytes32[] calldata RootsAmounts,              // Merkle Root Amounts
        uint[] calldata DiscountAmounts               // Discount Amounts
    ) external onlyOperator {
        if(ParamsSaleInternal._NFT == Params._FactoryMintPass)
        {
            uint MintPassProjectID = IMintPass(Params._FactoryMintPass).__InitMintPass(ParamsMintPass);
            ParamsSale._ProjectIDMintPass = MintPassProjectID;
        }
        IMarketplace(Params._DutchMarketplace).__StartSale(ParamsSale, ParamsSaleInternal, RootsPriority, RootsAmounts, DiscountAmounts);
    }

    /**
     * @dev Starts A Fixed Price Sale And Optionally Instantiates New MintPass Factory Project
     */
    function InitSaleFixedPrice(
        IMarketplace.FixedPriceSale memory ParamsSale, // FixedPriceSale
        IMintPass.Params memory ParamsMintPass         // Mint Pass Parameters
    ) external onlyOperator {
        if(ParamsSale._NFT == Params._FactoryMintPass)
        {
            uint MintPassProjectID = IMintPass(Params._FactoryMintPass).__InitMintPass(ParamsMintPass);
            ParamsSale._ProjectIDMintPass = MintPassProjectID;
        } 
        IMarketplace(Params._BasicMarketplace).__StartSale(ParamsSale);
    }

    /**
     * @dev Returns Next ProjectID From ArtBlocks Contract
     */
    function ViewNextABProjectID() public view returns ( uint ) { return ArtBlocksCore(Params._ArtBlocksCore).nextProjectId(); }

    /**
     * @dev Returns Launchpad Registry Address
     */
    function ViewAddressLaunchpadRegistry() public view returns(address) { return Params._LaunchpadRegistry; }

    /**
     * @dev Returns Marketplace Address
     */
    function ViewAddressMarketplace() public view returns ( address ) { return Params._DutchMarketplace; }

    /**
     * @dev Returns LiveMint Address
     */
    function ViewAddressLiveMint() public view returns ( address ) { return Params._LiveMint; }

    /**
     * @dev Returns Mint Pass Factory Address
     */
    function ViewAddressMintPassFactory() public view returns ( address ) { return Params._FactoryMintPass; }

    /**
     * @dev Returns Owner Address
     */
    function ViewOwner() public view returns ( address ) { return Params._Owner; }

    /**
     * @dev Changes The BaseURI For a Mint Pass Project
     * note: `MintPassProjectID` Is The Project ID From The MintPass Factory Contract
     */
    function _NewBaseURIMintPass(uint MintPassProjectID, string calldata BaseURI) external onlyAdmin 
    {
        IMintPass(Params._FactoryMintPass).__NewBaseURI(MintPassProjectID, BaseURI);
        ILaunchpadRegistry(Params._LaunchpadRegistry).__NewMintPassURI(MintPassProjectID, BaseURI);
    }

    /**
     * @dev Adds An Operator
     */
    function _OperatorAdd(address Wallet) external onlyAdmin { Operator[Wallet] = true; }

    /**
     * @dev Removes An Operator
     */
    function _OperatorRemove(address Wallet) external onlyAdmin { Operator[Wallet] = false; }

    /**
     * @dev Authorizes Contract
     */
    function __AuthorizeContract(address Contract, bool State) external onlyOwner { Whitelisted[Contract] = State; }

    /**
     * @dev Adds An Admin
     */
    function __AdminAdd(address Wallet) external onlyOwner { Admin[Wallet] = true; }

    /**
     * @dev Removes An Admin
     */
    function __AdminRemove(address Wallet) external onlyOwner { Admin[Wallet] = false; }

    /**
     * @dev Toggles The Contract State
     */
    function __ActiveToggle() external onlyOwner { Params._Active = !Params._Active; }
    
    /**
     * @dev Changes ArtBlocks Core Address
     */
    function __ChangeArtBlocksCore(address NewAddress) external onlyOwner { Params._ArtBlocksCore = NewAddress; }

    /**
     * @dev Changes Marketplace Address
     */
    function __ChangeMarketplace(address NewAddress) external onlyOwner { Params._DutchMarketplace = NewAddress; }

    /**
     * @dev Changes LiveMint Address
     */
    function __ChangeLiveMint(address NewAddress) external onlyOwner { Params._LiveMint = NewAddress; }

    /**
     * @dev Changes Mint Pass Factory Address
     */
    function __ChangeFactoryMintPass(address NewAddress) external onlyOwner { Params._FactoryMintPass = NewAddress; }
    
    /**
     * @dev Changes Minted Works Factory Address
     */
    function __ChangeFactoryMintedWorks(address NewAddress) external onlyOwner { Params._FactoryMintedWorks = NewAddress; }

    /**
     * @dev Changes Basic Marketplace Address
     */
    function __ChangeBasicMarketplace(address NewAddress) external onlyOwner { Params._BasicMarketplace = NewAddress; }

    /**
     * @dev Upgrades The Basic Marketplace's Active Launchpad Address
     */
    function __UpgradeBasicMarketplace(address NewAddress) external onlyOwner { ICustom(Params._BasicMarketplace)._____NewLaunchpadAddress(NewAddress); }

    /**
     * @dev Upgrades The Marketplace's Active Launchpad Address
     */
    function __UpgradeDutchMarketplace(address NewAddress) external onlyOwner { ICustom(Params._DutchMarketplace)._____NewLaunchpadAddress(NewAddress); }

    /**
     * @dev Upgrades The LiveMint's Active Launchpad Address
     */
    function __UpgradeLiveMint(address NewAddress) external onlyOwner { ICustom(Params._LiveMint)._____NewLaunchpadAddress(NewAddress); }

    /**
     * @dev Upgrades The Minted Works Factory's Active Launchpad Address
     */
    function __UpgradeFactoryMintedWorks(address NewAddress) external onlyOwner { ICustom(Params._FactoryMintedWorks)._____NewLaunchpadAddress(NewAddress); }

    /**
     * @dev Upgrades The Mint Pass Factory's Active Launchpad Address
     */
    function __UpgradeFactoryMintPass(address NewAddress) external onlyOwner { ICustom(Params._FactoryMintPass)._____NewLaunchpadAddress(NewAddress); }

    /**
     * @dev Upgrades The Launchpad Registry's Active Launchpad Address
     */
    function __UpgradeLaunchpadRegistry(address NewAddress) external onlyOwner { ICustom(Params._LaunchpadRegistry)._____NewLaunchpadAddress(NewAddress); }

    /**
     * @dev Initiates Upgrade Of The Launchpad
     */
    function __UpgradeAll(address NewLaunchpadAddress) external onlyOwner
    {
        ICustom(Params._DutchMarketplace)._____NewLaunchpadAddress(NewLaunchpadAddress);
        ICustom(Params._LiveMint)._____NewLaunchpadAddress(NewLaunchpadAddress);
        ICustom(Params._FactoryMintedWorks)._____NewLaunchpadAddress(NewLaunchpadAddress);
        ICustom(Params._FactoryMintPass)._____NewLaunchpadAddress(NewLaunchpadAddress);
        ICustom(Params._LaunchpadRegistry)._____NewLaunchpadAddress(NewLaunchpadAddress);
    }

    /**
     * @dev Instantiates A New State
     */
    function __NewState(StateParameters memory _State) external onlyOwner { Params = _State; }

    /**
     * @dev Executes Arbitrary Transaction(s)
     */
    function __InitTransaction(address[] memory Targets, uint[] memory Values, bytes[] memory Datas) external onlyOwner
    {
        for (uint x; x < Targets.length; x++) 
        {
            (bool success,) = Targets[x].call{value:(Values[x])}(Datas[x]);
            require(success, "i have failed u anakin");
        }
    }

    /**
     * @dev Transfers Ownership Of The Contract
     */
    function __TransferOwnership(address NewOwner) external onlyOwner { Params._Owner = NewOwner; }

    /**
     * @dev Operator Access Control
     */
    modifier onlyOperator
    {
        if(Operator[msg.sender])
        {
            require(OperatorCooldown[msg.sender] >= block.timestamp, "Launchpad | onlyOperator | Operator Cooldown Not Reached");
            OperatorCooldown[msg.sender] = block.timestamp + 24 hours;
        }
        else { require(Admin[msg.sender] || msg.sender == Params._Owner, "Launchpad | onlyOperator | `msg.sender` Is Not Admin Or Owner Or Operator"); }
        _;
    }

    /**
     * @dev Admin Access Control
     */
    modifier onlyAdmin
    {
        require(Admin[msg.sender] || msg.sender == Params._Owner, "Launchpad | onlyAdmin | `msg.sender` Is Not Admin Or Owner");
        _;
    }

    /**
     * @dev onlyOwner Access Control
     */
    modifier onlyOwner
    {
        require(msg.sender == Params._Owner, "Launchpad | onlyOwner | `msg.sender` Is Not Owner");
        _;
    }
}

/**
 * @dev Interface For The Live Mint Smart Contract
 */
interface ILiveMint
{
    struct Params
    {
        address _MintPass;        // [0] -> _MintPass
        address _Minter;          // [1] -> _Minter
        address _PolyptychSource; // [2] -> _PolyptychSource
        uint _MaxSupply;          // [3] -> _MaxSupply
        uint _MintPassProjectID;  // [4] -> _MintPassProjectID
        uint _ArtBlocksProjectID; // [5] -> _ArtBlocksProjectID 
        uint _PolyStart;          // [6] -> _PolyStart
        uint _PolyEnd;            // [7] -> _PolyEnd
    }

    /**
     * @dev Initializes Live Mint & Returns LiveMintProjectID
     */
    function __InitLiveMint ( Params memory ) external returns ( uint );
}

/**
 * @dev Interface For The Marketplace Smart Contract
 */
interface IMarketplace 
{ 
    struct Sale
    {
        string _Name;                     // [0] -> _Name
        uint _ProjectIDMintPass;          // [1] -> _ProjectIDMintPass
        uint _ProjectIDArtBlocks;         // [2] -> _ProjectIDArtBlocks
        uint _PriceStart;                 // [3] -> _PriceStart
        uint _PriceEnd;                   // [4] -> _PriceEnd
        uint _MaxAmtPerPurchase;          // [5] -> _MaxAmtPerPurchase
        uint _MaximumAvailableForSale;    // [6] -> _MaximumAvailableForSale
        uint _StartingBlockUnixTimestamp; // [7] -> _StartingBlockUnixTimestamp
        uint _SecondsBetweenPriceDecay;   // [8] -> _SecondsBetweenPriceDecay
        uint _SaleStrip;                  // [9] -> _SaleStrip note: For Traditional MintPack transferFrom() Sales 
    }

    struct State
    {
        address _NFT;           // [0] -> _NFT
        address _Operator;      // [1] _Operator (Wallet That NFT Is Pulling From)
        uint _CurrentIndex;     // [2] _CurrentIndex (If Simple Sale Type, This Is The Next Token Index To Iterate Upon)
        uint _Type;             // [3] _SaleType (0 = Simple, 1 = TransferFrom, 2 = PurchaseTo, 3 = MintPack)
        bool _ActivePublic;     // [4] -> _ActivePublic
        bool _ActiveBrightList; // [5] -> _ActiveBrightList 
        bool _Discount;         // [6] -> _Discount
        bool _ActiveRespend;    // [7] -> _ActiveRespend
    }

    struct FixedPriceSale
    {
        uint _Price;             // [0] -> _Price
        uint _ProjectIDMintPass; // [1] -> _ProjectIDMintPass
        uint _Type;              // [2] -> _Type
        uint _ABProjectID;       // [3] -> _ABProjectID
        uint _AmountSold;        // [4] -> _AmountSold
        uint _AmountForSale;     // [5] -> _AmountForSale
        address _NFT;            // [6] -> _NFT
        bytes32 _Root;           // [7] -> _Root
    }

    /**
     * @dev Starts A Sale On The BasicMarketplace Contract
     */
    function __StartSale(FixedPriceSale memory) external;

    /**
     * @dev Initiates A New Sale On The DutchMarketplace Contract
     * Returns MarketplaceSaleID
     */
    function __StartSale (
        Sale memory _Sale, 
        State memory _State, 
        bytes32[] calldata RootsPrioriy, 
        bytes32[] calldata RootsAmounts, 
        uint[] calldata DiscountAmounts
    ) external returns ( uint );
}

/**
 * @dev Interface For Mint Pass Factory
 */
interface IMintPass
{
    struct Params
    {
        uint _MaxSupply;
        uint _MintPacks;
        uint _ArtistIDs;
        uint _ArtBlocksProjectID;
        uint _Reserve;
        string _MetadataURI;
    }

    /**
     * @dev Creates A New Mint Pass Project & Returns MintPassProjectID
     */
    function __InitMintPass ( Params memory ) external returns ( uint _MintPassID );

    /**
     * @dev Updates The Base URI For A Mint Pass Project
     */
    function __NewBaseURI ( uint MintPassProjectID, string calldata BaseURI ) external;
}

/**
 * @dev Interface For Minted Works, Either ArtBlocks or Non-ArtBlocks
 */
interface IMinter 
{ 
    /**
     * @dev Paramters For Custom Minted Work
     */
    struct ParamsCustom
    {
        string _Name;
        string _Symbol;
        string _MetadataMintedWork;
    }

    /**
     * @dev Paramters For Minted Work
     */
    struct ParamsArtBlocks
    {
        string _Name;
        address _ArtistAddress;
        address _ArtBlocksCore;
    }

    /**
     * @dev ArtBlocks Add Project
     */
    function addProject ( string calldata Name, address ArtistAddress, uint PricePerTokenInWei ) external;

    /**
     * @dev ArtBlocks Toggle Project Active
     */
    function toggleProjectIsActive( uint ProjectID ) external;

    /**
     * @dev Custom Add Project
     */
    function __addProject( ParamsCustom memory ) external;

    /**
     * @dev Updates Project Artist Address
     */
    function updateProjectArtistAddress ( uint ProjectID, address ArtistAddress ) external;

    /**
     * @dev Updates Project Currency Info
     */
    function updateProjectCurrencyInfo ( uint ProjectID, string memory CurrencySymbol, address ERC20 ) external;
}

/**
 * @dev Interface For The Launchpad Registry
 */
interface ILaunchpadRegistry
{
    struct Project
    {
        string _Name;
        bool _Active;
        bool _ArtBlocks;
        uint _ArtBlocksProjectID;
        uint _LiveMintArtistID;
        uint _MaxSupply;
        uint _MintPacks;
        uint _NumArtistIDs;
        uint _DutchMarketplaceSaleID;
        string _MetadataMintPass;
        string _MetadataMintedWork;
        address _MintPassAddress;
        address _MintedWorkAddress;
    }

    /**
     * @dev Adds A New Project To The Launchpad Registry
     */
    function __NewProject ( Project memory ) external returns (uint);

    /**
     * @dev Updates The Mint Pass URI For A Project 
     */
    function __NewMintPassURI ( uint MintPassProjectID, string calldata URI ) external;
    
    /**
     * @dev Returns ArtBlocksProjectID Of LaunchpadProjectID
     */
    function ViewArtBlocksProjectID ( uint ProjectID ) external view returns ( uint );
}

/**
 * @dev Interface To Upgrade The Launchpad Contract
 */
interface ICustom { function _____NewLaunchpadAddress ( address NewAddress ) external; }

/**
 * @dev Abstract Contract To Recieve The Next ProjectID From ArtBlocks
 */
abstract contract ArtBlocksCore { uint public nextProjectId; }
//SPDX-License-Identifier: MIT
/**
 * @dev @brougkr
 */
pragma solidity 0.8.19;
abstract contract LaunchpadEnabled
{
    /**
     * @dev The Launchpad Address
     */
    address public _LAUNCHPAD = 0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700;

    /**
     * @dev Updates The Launchpad Address From Launchpad (batch upgrade)
     */ 
    function _____NewLaunchpadAddress(address NewAddress) external onlyLaunchpad { _LAUNCHPAD = NewAddress; }

    /**
     * @dev Access Control Needed For A Contract To Be Able To Use The Launchpad
    */
    modifier onlyLaunchpad()
    {
        require(_LAUNCHPAD == msg.sender, "onlyLaunchpad: Caller Is Not Launchpad");
        _;
    }
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/** 
 * @dev @brougkr
 * The Launchpad Registry Contains Information About All Projects That Have Been Created Through The Launchpad Contract
 */
pragma solidity 0.8.19;
contract LaunchpadRegistry
{   
    struct Project
    {
        string _Name;
        bool _Active;
        bool _ArtBlocks;
        uint _ArtBlocksProjectID;
        uint _LiveMintArtistID;
        uint _MaxSupply;
        uint _MintPacks;
        uint _NumArtistIDs;
        uint _MarketplaceSaleID;
        string _MetadataMintedWork;
        string _MetadataMintPass;
        address _MintPassAddress;
        address _MintedWorkAddress;
    }

    uint public UniqueProjectsInvoked;
    bytes32 private constant _AUTHORIZED = keccak256("AUTHORIZED");
    bytes32 private constant _ADMIN = keccak256("ADMIN");
    bytes32 private constant _OWNER = keccak256("OWNER");
    mapping(uint=>Project) public Projects;
    mapping(address=>bytes32) public Role;

    event NewProjectInvoked(uint ProjectID);
    event OwnershipTransferred(address OldOwner, address NewOwner);

    constructor() 
    { 
        Role[0xB96E81f80b3AEEf65CB6d0E280b15FD5DBE71937] = _ADMIN; // brightmoments.eth
        Role[0x18B7511938FBe2EE08ADf3d4A24edB00A5C9B783] = _ADMIN; // phil.brightmoments.eth
        Role[0x38E27a59d3cffB945aC8d41b7c398618354c08F6] = _ADMIN; // gitpancake.brightmoments.eth
        Role[msg.sender] = _OWNER;
    }

    /**
     * @dev Initializes A New Project Into The Launchpad Registry
     */
    function __NewProject(Project memory _Project) external onlyAuthorized returns (uint)
    {
        Projects[UniqueProjectsInvoked] = _Project;
        emit NewProjectInvoked(UniqueProjectsInvoked);
        UniqueProjectsInvoked++;
        return (UniqueProjectsInvoked - 1);
    }

    /**
     * @dev Updates The BaseURI For A Project
     */
    function __NewMintPassURI(uint ProjectID, string memory URI) external onlyAuthorized { Projects[ProjectID]._MetadataMintedWork = URI; }

    /**
     * @dev Updates The Minted Work Address
     */
    function ___NewMintedWorkURI(uint ProjectID, string calldata URI) external onlyAdmin { Projects[ProjectID]._MetadataMintedWork = URI; }

    /**
     * @dev Updates The Minted Pass Metadata URI
     */
    function ___NewMintPassURI(uint ProjectID, string calldata URI) external onlyAdmin { Projects[ProjectID]._MetadataMintPass = URI; }

    /**
     * @dev Adds An Admin
     */
    function ____AdminAdd(address Wallet) external onlyOwner { Role[Wallet] = _ADMIN; }

    /**
     * @dev Removes An Admin
     */
    function ____AdminRemove(address Wallet) external onlyOwner { Role[Wallet] = 0x0; }

    /**
     * @dev Authorizes A Contract Address
     */
    function ____AuthorizeContract(address ContractAddress) external onlyOwner { Role[ContractAddress] = _AUTHORIZED; }

    /**
     * @dev Deauthorizes A Contract Address
     */
    function ____DeauthorizeContract(address ContractAddress) external onlyOwner { Role[ContractAddress] = 0x0; }

    /**
     * @dev Transfers Ownership Of The Contract
     */
    function ____TransferOwnership(address NewOwner) external onlyOwner 
    { 
        Role[msg.sender] = 0x0;
        Role[NewOwner] = _OWNER; 
        emit OwnershipTransferred(msg.sender, NewOwner);
    }

    /**
     * @dev Views A Project
     */
    function ViewProject(uint ProjectID) public view returns(Project memory) { return Projects[ProjectID]; }

    /**
     * @dev Returns An Array Of Projects
     */
    function ViewProjects(uint[] calldata Indexes) public view returns(Project[] memory) 
    { 
        Project[] memory _Projects = new Project[](Indexes.length);
        for(uint x; x < Indexes.length; x++) { _Projects[x] = Projects[Indexes[x]]; }
        return _Projects;
    }

    /**
     * @dev Views Projects Within A Range (StartingIndex, EndingIndex) Inclusive
     */
    function ViewProjectsInRange(uint StartingIndex, uint EndingIndex) public view returns(Project[] memory) 
    { 
        Project[] memory _Projects = new Project[](EndingIndex - StartingIndex);
        for(uint x; x < EndingIndex - StartingIndex; x++) { _Projects[x] = Projects[StartingIndex + x]; }
        return _Projects;
    }

    /**
     * @dev Returns Active Projects
     */
    function ViewActiveProjects() public view returns(Project[] memory) 
    { 
        uint Found;
        uint[] memory ProjectIDs = new uint[](UniqueProjectsInvoked);
        for(uint x; x < UniqueProjectsInvoked; x++)
        {
            if(Projects[x]._Active)
            {
                ProjectIDs[Found] = x;
                Found++;
            }
        }
        Project[] memory _ProjectIDs = new Project[](Found);
        for(uint y; y < Found; y++)
        {
            _ProjectIDs[y] = Projects[ProjectIDs[y]];
        }
        return _ProjectIDs;
    }

    /**
     * @dev Returns The Associated ArtBlocks ProjectID Of A Launchpad Project (if applicable)
     * note: Returns Max Integer If The Launchpad ProjectID Is Not Associated With An ArtBlocks Project
     */
    function ViewArtBlocksProjectID(uint LaunchpadProjectID) public view returns(uint) 
    { 
        return Projects[LaunchpadProjectID]._ArtBlocksProjectID; 
    }

    /**
     * @dev Returns The Minted Work BaseURI For A Project
     */
    function ViewBaseURIMintedWork(uint ProjectID) public view returns(string memory) 
    { 
        return Projects[ProjectID]._MetadataMintedWork; 
    }
    
    /**
     * @dev Returns The Mint Pass BaseURI For A Project
     */
    function ViewBaseURIMintPass(uint ProjectID) public view returns(string memory) 
    { 
        return Projects[ProjectID]._MetadataMintPass; 
    }

    /**
     * @dev Admin Access Modifier
     */
    modifier onlyAuthorized
    {
        require(Role[msg.sender] == _AUTHORIZED, "Registry: `msg.sender` Is Not Authorized");
        _;
    }

    /**
     * @dev Admin Access Modifier
     */
    modifier onlyAdmin
    {
        require(Role[msg.sender] == _ADMIN || Role[msg.sender] == _OWNER, "Registry: `msg.sender` Is Not Admin Or Owner");
        _;
    }

    /**
     * @dev Owner Access Modifier
     */
    modifier onlyOwner
    {
        require(Role[msg.sender] == _OWNER, "Registry: `msg.sender` Is Not Owner");
        _;
    }
}
// SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import { IERC721 } from "@openzeppelin/contracts/interfaces/IERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IMinter } from "./IMinter.sol";
import { IMP } from "./IMP.sol";
import { IGT } from "./IGT.sol";
import { LaunchpadEnabled } from "./LaunchpadEnabled.sol";
contract LiveMint is Ownable, ReentrancyGuard, LaunchpadEnabled
{  
    struct City
    {
        string _Name;         // _Name
        uint _QRCurrentIndex; // _QRCurrentIndex (Should be Always Be (333 * (City# % 7)) + 1000
        address _ERC20;       // _ERC20 
        bytes32 _Root;        // _Root
    }

    struct Artist
    {
        address _MintPass;        // _MintPass
        address _Minter;          // _Minter
        address _PolyptychSource; // _PolyptychSource
        uint _MaxSupply;          // _MaxSupply
        uint _MintPassProjectID;  // _MintPassProjectID
        uint _ArtBlocksProjectID; // _ArtBlocksProjectID 
        uint _PolyStart;          // _PolyStart
        uint _PolyEnd;            // _PolyEnd
    }

    struct User
    {
        bool _Eligible;   // _Eligible
        uint _Allocation; // _Allocation
    }

    /*-------------------*/
    /*  STATE VARIABLES  */
    /*-------------------*/

    bytes32 private constant _AUTHORIZED = keccak256("AUTHORIZED");                      // Authorized Role
    bytes32 private constant _MINTER_ROLE = keccak256("MINTER_ROLE");                    // Minter Role
    bytes32 private constant _ADMIN_ROLE = keccak256("ADMIN_ROLE");                      // Admin Role
    uint private constant ONE_MILLION = 1000000;                                         // One Million         
    address private constant _DN = 0x00000000000076A84feF008CDAbe6409d2FE638B;           // Delegation Registry
    address private constant _GOLDEN_TOKEN = 0x985e1932FFd2aA4bC9cE611DFe12816A248cD2cE;           // Golden Token Address
    address private constant _CITIZEN_MINTER = 0xDd06d8483868Cd0C5E69C24eEaA2A5F2bEaFd42b;         // ArtBlocks Minter Contract
    address private constant _BRT_MULTISIG = 0xB96E81f80b3AEEf65CB6d0E280b15FD5DBE71937;           // BRT Multisig
    address public _MintPassFactory;                                                     // MintPass Factory    
    uint public _CurrentCityIndex = 6;                                                   // Current City Index
    uint public _UniqueArtistsInvoked;                                                   // Unique Artists Invoked

    /*-------------------*/
    /*     MAPPINGS      */
    /*-------------------*/
    
    mapping(uint => Artist) public Artists;                              // [ArtistID] => Artist
    mapping(uint => City) public Cities;                                 // [CityIndex] => City Struct
    mapping(uint => mapping(address => bool)) public _QRRedeemed;        // [CityIndex][Wallet] => If User Has Redeemed QR
    mapping(uint => mapping(address => uint)) public _QRAllocation;      // [CityIndex][Wallet] => Wallet's QR Code Allocation
    mapping(uint => mapping(uint => address)) public _BrightListCitizen; // [CityIndex][TicketID] => Address Of CryptoCitizen Minting Recipient 
    mapping(uint => mapping(uint => address)) public _BrightListArtist;  // [ArtistID][TicketID] => Address Of Artist NFT Recipient
    mapping(uint => mapping(uint => string)) public _DataArtists;        // [ArtistID][TicketID] => Artist Data
    mapping(uint => mapping(uint => string)) public _DataCitizens;       // [CityIndex][TicketID] => Data For Golden Token Checkins
    mapping(uint => mapping(uint => uint)) public _MintedTokenIDCitizen; // [CityIndex][TicketID] => MintedTokenID
    mapping(uint => mapping(uint => uint)) public _MintedTokenIDArtist;  // [ArtistID][TicketID] => MintedTokenID
    mapping(uint => mapping(uint => bool)) public _MintedArtist;         // [ArtistID][TicketID] => If Minted
    mapping(uint => mapping(uint => bool)) public _MintedCitizen;        // [CityIndex][TicketID] => If Golden Ticket ID Has Minted Or Not
    mapping(address => bytes32) public Role;                             // [Wallet] => BRT Minter Role
    mapping(uint=>uint) public AmountRemaining;                          // [ArtistID] => Mints Remaining
    mapping(uint=>mapping(uint=>uint)) public _ArtBlocksProjectID;       // [ArtistID][TicketID] => ArtBlocksProjectID

    /*-------------------*/
    /*      EVENTS       */
    /*-------------------*/

    /**
     * @dev Emitted When `Redeemer` IRL-mints CryptoCitizen Corresponding To Their Redeemed `TicketID`.
     **/
    event LiveMintComplete(address indexed Redeemer, uint TicketID, uint TokenID, string Data);

    /**
     * @dev Emitted When `Redeemer` IRL-mints A Artist NFT Corresponding To Their Redeemed `TicketID`.
     */
    event LiveMintCompleteArtist(address Recipient, uint ArtistID, uint TicketID, uint MintedWorkTokenID);

    /**
     * @dev Emitted When An Artist Mint Pass Is Redeemed
     */
    event ArtistMintPassRedeemed(address Redeemer, uint ArtistIDs, uint TicketIDs, string Data, string Type);

    /**
     * @dev Emitted When `Redeemer` Redeems Golden Token Corresponding To `TicketID` 
     **/
    event GoldenTokenRedeemed(address indexed Redeemer, uint TicketID, string Data, string Type);

    /**
     * @dev Emitted When `Redeemer` Redeems Golden Token Corresponding To `TicketID` 
     **/
    event QRRedeemed(address indexed Redeemer, uint TicketID, string Data, string Type);
    
    /**
     * @dev Emitted When A Reservation Is Wiped
     */
    event ReservationWiped(uint TicketID, address Redeemer, string Data);

    /**
     * @dev Emitted When A Contract Is Authorized
     */
    event AuthorizedContract(address NewAddress);

    /**
     * @dev Emitted When A Contract Is Deauthorized
     */
    event DeauthorizedContract(address NewAddress);


    /*-------------------*/
    /*    CONSTRUCTOR    */
    /*-------------------*/

    constructor()
    { 
        Cities[0]._Name = "CryptoGalacticans"; 
        Cities[1]._Name = "CryptoVenetians";
        Cities[2]._Name = "CryptoNewYorkers";
        Cities[3]._Name = "CryptoBerliners";
        Cities[4]._Name = "CryptoLondoners";
        Cities[5]._Name = "CryptoMexas";
        Cities[6]._Name = "CryptoTokyites";
        Cities[7]._Name = "CryptoCitizen City #8";
        Cities[8]._Name = "CryptoCitizen City #9";
        Cities[9]._Name = "CryptoCitizen City #10";
        Role[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = _ADMIN_ROLE;  // `operator.brightmoments.eth`
        Role[0x1A0a3E3AE390a0710f8A6d00587082273eA8F6C9] = _MINTER_ROLE; // BRT Minter #1
        Role[0x4d8013b0c264034CBf22De9DF33e22f58D52F207] = _MINTER_ROLE; // BRT Minter #2
        Role[0x4D9A8CF2fE52b8D49C7F7EAA87b2886c2bCB4160] = _MINTER_ROLE; // BRT Minter #3
        Role[0x124fd966A0D83aA020D3C54AE2c9f4800b46F460] = _MINTER_ROLE; // BRT Minter #4
        Role[0x100469feA90Ac1Fe1073E1B2b5c020A8413635c4] = _MINTER_ROLE; // BRT Minter #5
        Role[0x756De4236373fd17652b377315954ca327412bBA] = _MINTER_ROLE; // BRT Minter #6
        Role[0xc5Dfba6ef7803665C1BDE478B51Bd7eB257A2Cb9] = _MINTER_ROLE; // BRT Minter #7
        Role[0xFBF32b29Bcf8fEe32d43a4Bfd3e7249daec457C0] = _MINTER_ROLE; // BRT Minter #8
        Role[0xF2A15A83DEE7f03C70936449037d65a1C100FF27] = _MINTER_ROLE; // BRT Minter #9
        Role[0x1D2BAB965a4bB72f177Cd641C7BacF3d8257230D] = _MINTER_ROLE; // BRT Minter #10
        Role[0x2e51E8b950D72BDf003b58E357C2BA28FB77c7fB] = _MINTER_ROLE; // BRT Minter #11
        Role[0x8a7186dECb91Da854090be8226222eA42c5eeCb6] = _MINTER_ROLE; // BRT Minter #12
        Role[0x7603C5eed8e57Ad795ec5F0081eFB21d1eEBf937] = _MINTER_ROLE; // BRT Minter #13
        Role[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = _AUTHORIZED;  // `operator.brightmoments.eth`
    }

    /*-------------------*/
    /*  PUBLIC FUNCTIONS */
    /*-------------------*/

    /**
     * @dev Redeems Golden Tokens & BrightLists Address To Receive CryptoCitizen
     **/
    function RedeemGT (
        uint[] calldata TicketIDs, 
        string[] calldata Data,
        string[] calldata Type
    ) external nonReentrant {
        address Recipient;
        for(uint x; x < TicketIDs.length; x++)
        {
            require(
                IERC721(_GOLDEN_TOKEN).ownerOf(TicketIDs[x]) == msg.sender, 
                "LiveMint: Sender Does Not Own Token With The Input Token ID"
            );
            Recipient = IGT(_GOLDEN_TOKEN)._LiveMintBurn(TicketIDs[x]);
            require(Recipient == msg.sender, "LiveMint: Recipient Must Be Valid Owner");
            _BrightListCitizen[_CurrentCityIndex][TicketIDs[x]] = msg.sender;
            _DataCitizens[_CurrentCityIndex][TicketIDs[x]] = Data[x];
            emit GoldenTokenRedeemed(msg.sender, TicketIDs[x], Data[x], Type[x]);
        }
    }

    /**
     * @dev Redeems Artist Mint Pass & BrightLists Address To Receive A NFT
     **/
    function RedeemAP (
        uint[] calldata ArtistIDs,
        uint[] calldata TicketIDs, 
        string[] calldata Data,
        string[] calldata Type
    ) external nonReentrant {
        address Recipient;
        uint ArtBlocksProjectID;
        uint Start;
        uint MaxSupply;
        uint End;
        uint CurrentTicketID;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            // Start = Artists[ArtistIDs[ArtistID]]._MintPassProjectID * ONE_MILLION;
            MaxSupply = Artists[ArtistIDs[ArtistID]]._MaxSupply;
            // End = Start + MaxSupply;
            for(uint TicketID; TicketID < TicketIDs.length; TicketID++)
            {
                CurrentTicketID = TicketIDs[TicketID];
                // require(
                //     CurrentTicketID >= Start && CurrentTicketID < End,
                //     "LiveMint: Ticket ID Is Not Valid For The Input Artist ID"
                // );
                require(
                    IERC721(_MintPassFactory).ownerOf(CurrentTicketID) == msg.sender, 
                    "LiveMint: Sender Does Not Own Token With The Input Token ID"
                );
                require(
                    _BrightListArtist[ArtistIDs[ArtistID]][CurrentTicketID] == address(0),
                    "LiveMint: Address Cannot Be Overwritten"
                );
                (Recipient, ArtBlocksProjectID) = IMP(_MintPassFactory)._LiveMintBurn(CurrentTicketID);
                _BrightListArtist[ArtistIDs[ArtistID]][CurrentTicketID] = Recipient;
                _ArtBlocksProjectID[ArtistIDs[ArtistID]][CurrentTicketID] = ArtBlocksProjectID;
                _DataArtists[ArtistIDs[ArtistID]][CurrentTicketID] = Data[TicketID];
                emit ArtistMintPassRedeemed(Recipient, ArtistIDs[ArtistID], CurrentTicketID, Data[TicketID], Type[TicketID]);
            }
        }
    } 
    
    /**
     * @dev Redeems Spot For IRL Minting
     */
    function RedeemQR(string[] calldata Data, string[] calldata Type, bytes32[] calldata Proof, address Vault) external nonReentrant 
    {        
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(IDelegationRegistry(_DN).checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } } 
        require(readQREligibility(Recipient, Proof), "LiveMint: User Is Not Eligible To Redeem QR");
        require(Data.length == Type.length, "LiveMint: Data And Type Arrays Must Be Equal Length");
        require(
            Data.length == _QRAllocation[_CurrentCityIndex][Recipient] // Must Equal User's QR Allocation
            ||
            _QRRedeemed[_CurrentCityIndex][Recipient] == false && Data.length == 1, // Must Be First Time Redeeming
            "LiveMint: Data And Type Arrays Must Be Equal To Allocation, Or 1, If First Time Redeeming"
        );
        if(_QRAllocation[_CurrentCityIndex][Recipient] == 0) // User Is Able To Redeem Explicitly 1 QR Code
        {
            require(!_QRRedeemed[_CurrentCityIndex][Recipient], "LiveMint: User Has Already Redeemed");
            _DataCitizens[_CurrentCityIndex][Cities[_CurrentCityIndex]._QRCurrentIndex] = Data[0];
            _BrightListCitizen[_CurrentCityIndex][Cities[_CurrentCityIndex]._QRCurrentIndex] = Recipient;
            emit QRRedeemed(Recipient, Cities[_CurrentCityIndex]._QRCurrentIndex, Data[0], Type[0]);
            Cities[_CurrentCityIndex]._QRCurrentIndex++; 
        }
        else // User Is Able To Redeem More Than 1 QR Code Because Their QRAllocation > 0
        {
            uint _Allocation = _QRAllocation[_CurrentCityIndex][Recipient];
            uint _CurrentQR = Cities[_CurrentCityIndex]._QRCurrentIndex;
            uint _Limit = _Allocation + _CurrentQR;
            uint _Counter;
            _QRAllocation[_CurrentCityIndex][Recipient] = 0;
            Cities[_CurrentCityIndex]._QRCurrentIndex = _Limit;
            for(_CurrentQR; _CurrentQR < _Limit; _CurrentQR++)
            {
                _DataCitizens[_CurrentCityIndex][_CurrentQR] = Data[_Counter];
                _BrightListCitizen[_CurrentCityIndex][_CurrentQR] = Recipient;
                emit QRRedeemed(Recipient, _CurrentQR, Data[_Counter], Type[_Counter]);
                _Counter++;
            }
        }
        _QRRedeemed[_CurrentCityIndex][Recipient] = true;
    }

    /*--------------------*/
    /*    LIVE MINTING    */
    /*--------------------*/

    /**
     * @dev Batch Mints Verified Users On The Brightlist CryptoCitizens
     * note: { For CryptoCitizen Cities }
     */
    function _LiveMintCitizen(uint[] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        uint MintedWorkTokenID;
        for(uint TicketID; TicketID < TicketIDs.length; TicketID++)
        {
            require(!_MintedCitizen[_CurrentCityIndex][TicketIDs[TicketID]], "LiveMint: Golden Token Already Minted");
            if(_BrightListCitizen[_CurrentCityIndex][TicketIDs[TicketID]] != address(0))
            {
                Recipient = _BrightListCitizen[_CurrentCityIndex][TicketIDs[TicketID]];
            }
            else if (TicketIDs[TicketID] < 333)
            { 
                Recipient = IGT(_GOLDEN_TOKEN)._LiveMintBurn(TicketIDs[TicketID]); 
            }
            require(Recipient != address(0), "LiveMint: Invalid Recipient");
            _MintedCitizen[_CurrentCityIndex][TicketIDs[TicketID]] = true;
            MintedWorkTokenID = IMinter(_CITIZEN_MINTER).purchaseTo(Recipient, _CurrentCityIndex);
            _MintedTokenIDCitizen[_CurrentCityIndex][TicketIDs[TicketID]] = MintedWorkTokenID;
            emit LiveMintComplete(Recipient, TicketIDs[TicketID], MintedWorkTokenID, _DataCitizens[_CurrentCityIndex][TicketIDs[TicketID]]); 
        }
    }

    /**
     * @dev Burns Artist Mint Pass In Exchange For The Minted Work
     * note: { For Instances Where Multiple Artists Share The Same Mint Pass & Return (Recipient, ArtBlocksProjectID) }
     */
    function _LiveMintArtist(uint ArtistID, uint[] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        address MintPass = Artists[ArtistID]._MintPass;
        address Minter = Artists[ArtistID]._Minter;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        uint Start = Artists[ArtistID]._MintPassProjectID * ONE_MILLION;
        uint MaxSupply = Artists[ArtistID]._MaxSupply;
        uint End = Start + MaxSupply;
        require(AmountRemaining[ArtistID] > 0, "LiveMint: ArtistID Mint Limit Reached");
        require(TicketIDs.length <= AmountRemaining[ArtistID], "LiveMint: TicketID Length Exceeds ArtistID Mint Limit");
        AmountRemaining[ArtistID] = AmountRemaining[ArtistID] - TicketIDs.length;
        for(uint x; x < TicketIDs.length; x++)
        {
            TicketID = TicketIDs[x];
            require(TicketID >= Start && TicketID < End, "LiveMint: Ticket ID Is Not Valid For The Input Artist ID");
            require(!_MintedArtist[ArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
            _MintedArtist[ArtistID][TicketID] = true;
            if(_BrightListArtist[ArtistID][TicketID] == address(0))
            {
                (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
            }
            else
            {
                Recipient = _BrightListArtist[ArtistID][TicketID];
                ArtBlocksProjectID = _ArtBlocksProjectID[ArtistID][TicketID];
            }
            MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID);
            _MintedTokenIDArtist[ArtistID][TicketID] = MintedWorkTokenID;
            emit LiveMintCompleteArtist(Recipient, ArtistID, TicketID, MintedWorkTokenID);
        }
    }

    /**
     * @dev Burns Artist Mint Pass In Exchange For The Minted Work
     * note: { For Instances Where Multiple Artists Share The Same Mint Pass & Return (Recipient, ArtBlocksProjectID) }
     */
    function _LiveMintArtistBatch(uint[] calldata ArtistIDs, uint[][] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        uint ActiveArtistID;
        for(uint ArtistIDIndex; ArtistIDIndex < ArtistIDs.length; ArtistIDIndex++)
        {
            ActiveArtistID = ArtistIDs[ArtistIDIndex];
            uint Start = Artists[ActiveArtistID]._MintPassProjectID * ONE_MILLION;
            uint MaxSupply = Artists[ActiveArtistID]._MaxSupply;
            uint End = Start + MaxSupply;
            address MintPass = Artists[ActiveArtistID]._MintPass;
            address Minter = Artists[ActiveArtistID]._Minter;
            require(AmountRemaining[ActiveArtistID] > 0, "LiveMint: ArtistID Mint Limit Reached");
            require(TicketIDs[ArtistIDIndex].length <= AmountRemaining[ActiveArtistID], "LiveMint: TicketID Length Exceeds ArtistID Mint Limit");
            AmountRemaining[ActiveArtistID] = AmountRemaining[ActiveArtistID] - TicketIDs[ArtistIDIndex].length;
            for(uint TicketIDIndex; TicketIDIndex < TicketIDs[ArtistIDIndex].length; TicketIDIndex++)
            {
                TicketID = TicketIDs[ArtistIDIndex][TicketIDIndex];
                require(TicketID >= Start && TicketID < End, "LiveMint: Ticket ID Is Not Valid For The Input Artist ID");
                require(!_MintedArtist[ActiveArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
                _MintedArtist[ActiveArtistID][TicketID] = true;
                if(_BrightListArtist[ActiveArtistID][TicketID] == address(0))
                {
                    (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
                }
                else
                {
                    Recipient = _BrightListArtist[ActiveArtistID][TicketID];
                    ArtBlocksProjectID = _ArtBlocksProjectID[ActiveArtistID][TicketID];
                }
                MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID);
                _MintedTokenIDArtist[ActiveArtistID][TicketID] = MintedWorkTokenID;
                emit LiveMintCompleteArtist(Recipient, ActiveArtistID, TicketID, MintedWorkTokenID);
            }

        }
    }

    /**
     * @dev Batch Mints Artists With ArtBlocks Polyptych Minter
     */
    function _LiveMintArtistPoly(uint ArtistID, uint[] calldata TicketIDs) external onlyMinter
    {
        address Source = Artists[ArtistID]._PolyptychSource;
        address Minter = Artists[ArtistID]._Minter;
        uint ArtBlocksProjectID = Artists[ArtistID]._ArtBlocksProjectID;
        uint PolyStart = Artists[ArtistID]._PolyStart;
        uint PolyEnd = Artists[ArtistID]._PolyEnd;
        require(Source != address(0), "LiveMint: Invalid Minter Setup");
        require(AmountRemaining[ArtistID] > 0, "LiveMint: ArtistID Mint Limit Reached");
        require(TicketIDs.length <= AmountRemaining[ArtistID], "LiveMint: TicketID [] Length Exceeds ArtistID Mint Limit");
        address Recipient;
        uint MintedWorkTokenID;
        uint TicketID;
        AmountRemaining[ArtistID] = AmountRemaining[ArtistID] - TicketIDs.length;
        for(uint x; x < TicketIDs.length; x++)
        {
            TicketID = TicketIDs[x];
            require(!_MintedArtist[ArtistID][TicketID], "LiveMint: Input TicketID Already Minted");
            _MintedArtist[ArtistID][TicketID] = true;
            require(TicketID >= PolyStart && TicketID <= PolyEnd, "LiveMint: Input TicketID Is Not Valid For The Input Artist ID");
            Recipient = IERC721(Source).ownerOf(TicketID);
            require(Recipient != address(0), "LiveMint: Invalid Recipient");
            MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID, Source, TicketID);
            _MintedTokenIDArtist[ArtistID][TicketID] = MintedWorkTokenID;
            emit LiveMintCompleteArtist(Recipient, ArtistID, TicketID, MintedWorkTokenID);
        }
    }

    /*-------------------*/
    /*  OWNER FUNCTIONS  */
    /*-------------------*/

    /**
     * @dev Grants Address BRT Minter Role
     **/
    function __AddMinter(address Minter) external onlyOwner { Role[Minter] = _MINTER_ROLE; }
    
    /**
     * @dev Deactivates Address From BRT Minter Role
     **/
    function __RemoveMinter(address Minter) external onlyOwner { Role[Minter] = 0x0; }

    /**
     * @dev Changes The Mint Pass Factory Contract Address
     */
    function __ChangeMintPassFactory(address Contract) external onlyOwner { _MintPassFactory = Contract; }

    /**
     * @dev Changes Mint Pass Address For Artist LiveMints
     */
    function __ChangeMintPass(uint ProjectID, address Contract) external onlyOwner { Artists[ProjectID]._MintPass = Contract; }

    /**
     * @dev Changes Merkle Root For Citizen LiveMints
     */
    function __ChangeRootCitizen(bytes32 NewRoot) external onlyOwner { Cities[_CurrentCityIndex]._Root = NewRoot; }

    /**
     * @dev Overwrites QR Allocation
     */
    function __QRAllocationsOverwrite(address[] calldata Addresses, uint[] calldata Amounts) external onlyOwner
    {
        require(Addresses.length == Amounts.length, "LiveMint: Input Arrays Must Match");
        for(uint x; x < Addresses.length; x++) { _QRAllocation[_CurrentCityIndex][Addresses[x]] = Amounts[x]; }
    }

    /**
     * @dev Increments QR Allocations
     */
    function __QRAllocationsIncrement(address[] calldata Addresses, uint[] calldata Amounts) external onlyOwner
    {
        require(Addresses.length == Amounts.length, "LiveMint: Input Arrays Must Match");
        for(uint x; x < Addresses.length; x++) { _QRAllocation[_CurrentCityIndex][Addresses[x]] += Amounts[x]; }
    }

    /**
     * @dev Mints To Multisig
     */
    function __QRAllocationsSetNoShow(uint[] calldata TicketIDs) external onlyOwner
    {
        for(uint TicketIndex; TicketIndex < TicketIDs.length; TicketIndex++)
        {
            require(!_MintedCitizen[_CurrentCityIndex][TicketIDs[TicketIndex]], "LiveMint: Ticket ID Already Minted");
            _BrightListCitizen[_CurrentCityIndex][TicketIDs[TicketIndex]] = _BRT_MULTISIG;
        }
    }

    /**
     * @dev Changes QR Current Index
     */
    function __ChangeQRIndex(uint NewIndex) external onlyOwner { Cities[_CurrentCityIndex]._QRCurrentIndex = NewIndex; }

    /**
     * @dev Batch Approves BRT For Purchasing
     */
    function __BatchApproveERC20(address[] calldata ERC20s, address[] calldata Operators) external onlyOwner
    {
        require(ERC20s.length == Operators.length, "LiveMint: Arrays Must Be Equal Length");
        for(uint x; x < ERC20s.length; x++) { IERC20(ERC20s[x]).approve(Operators[x], 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff); }
    }

    /**
     * @dev Instantiates New City
     * note: CityIndex Always Corresponds To ArtBlocks ProjectID
     */
    function __NewCity (
        string calldata Name,
        uint CityIndex,
        uint QRIndex,
        address ERC20
    ) external onlyOwner {
        Cities[CityIndex] = City(
            Name,
            QRIndex,
            ERC20,
            0x6942069420694206942069420694206942069420694206942069420694206942
        );
    }

    /**
     * @dev Overrides An Artist
     */
    function __OverrideArtist(uint ArtistID, Artist memory NewArtist) external onlyOwner { Artists[ArtistID] = NewArtist; }

    /**
     * @dev Instantiates A New City
     */
    function __NewCityStruct(uint CityIndex, City memory NewCity) external onlyOwner { Cities[CityIndex] = NewCity; }

    /**
     * @dev Returns An Artist Struct
     */
    function __NewArtistStruct(uint ArtistID, Artist memory NewArtist) external onlyOwner { Artists[ArtistID] = NewArtist; }

    /**
     * @dev Changes The Minter Address For An Artist
     */
    function __NewArtistMinter(uint ArtistID, address Minter) external onlyOwner { Artists[ArtistID]._Minter = Minter; }

    /**
     * @dev Withdraws Any Ether Mistakenly Sent to Contract to Multisig
     **/
    function __WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Withdraws ERC20 Tokens to Multisig
     **/
    function __WithdrawERC20(address TokenAddress) external onlyOwner 
    { 
        IERC20 erc20Token = IERC20(TokenAddress);
        uint balance = erc20Token.balanceOf(address(this));
        require(balance > 0, "0 ERC20 Balance At `TokenAddress`");
        erc20Token.transfer(msg.sender, balance);
    }

    /**
     * @dev Withdraws Any NFT Mistakenly Sent To This Contract.
     */
    function __WithdrawERC721(address ContractAddress, address Recipient, uint TokenID) external onlyOwner
    {
        IERC721(ContractAddress).transferFrom(address(this), Recipient, TokenID);
    }

    /**
     * @dev Authorizes A Contract To Mint
     */
    function ____AuthorizeContract(address NewAddress) external onlyOwner 
    { 
        Role[NewAddress] = _AUTHORIZED; 
        emit AuthorizedContract(NewAddress);
    }

    /**
     * @dev Deauthorizes A Contract From Minting
     */
    function ___DeauthorizeContract(address NewAddress) external onlyOwner 
    { 
        Role[NewAddress] = 0x0; 
        emit DeauthorizedContract(NewAddress);
    }
    
    /*-------------------*/
    /*    PUBLIC VIEW    */
    /*-------------------*/

    /**
     * @dev Returns If User Is Eligible To Redeem QR Code
     */
    function readEligibility(address Recipient, bytes32[] memory Proof) public view returns(User memory)
    {
        bool Eligible = readQREligibility(Recipient, Proof);
        uint Allocation;
        if(Eligible && _QRAllocation[_CurrentCityIndex][Recipient] > 0) { Allocation = _QRAllocation[_CurrentCityIndex][Recipient]; }
        return User(Eligible, Allocation);
    }

    /**
     * @dev Returns If User Is Eligible To Redeem QR Code
     */
    function readQREligibility(address Recipient, bytes32[] memory Proof) public view returns(bool)
    {
        bytes32 Leaf = keccak256(abi.encodePacked(Recipient));
        bool BrightListEligible = MerkleProof.verify(Proof, Cities[_CurrentCityIndex]._Root, Leaf);
        if(
            (BrightListEligible && !_QRRedeemed[_CurrentCityIndex][Recipient])
            || 
            (BrightListEligible && _QRAllocation[_CurrentCityIndex][Recipient] > 0)
            
        ) { return true; }
        else { return false; }
    }

    /**
     * @dev Returns An Array Of Unminted Golden Tokens
     */
    function readCitizenUnmintedTicketIDs() public view returns(uint[] memory)
    {
        uint[] memory UnmintedTokenIDs = new uint[](1000);
        uint Counter;
        uint CityIDBuffer = _CurrentCityIndex % 7 * 1000;
        for(uint TokenID; TokenID < 1000; TokenID++)
        {
            uint _TokenID = TokenID + CityIDBuffer;
            if(
                !_MintedCitizen[_CurrentCityIndex][_TokenID]
                &&
                _BrightListCitizen[_CurrentCityIndex][_TokenID] != address(0)
            ) 
            { 
                UnmintedTokenIDs[Counter] = _TokenID; 
                Counter++;
            }
        }
        uint[] memory FormattedUnMintedTokenIDs = new uint[](Counter);
        uint Found;
        for(uint FormattedTokenID; FormattedTokenID < Counter; FormattedTokenID++)
        {
            if(UnmintedTokenIDs[FormattedTokenID] != 0 || (UnmintedTokenIDs[FormattedTokenID] == 0 && FormattedTokenID == 0))
            {
                FormattedUnMintedTokenIDs[Found] = UnmintedTokenIDs[FormattedTokenID];
                Found++;
            }
        }
        return FormattedUnMintedTokenIDs;
    }

    /**
     * @dev Returns An Array Of Unminted Golden Tokens
     */
    function readCitizenMintedTicketIDs(uint CityID) public view returns(uint[] memory)
    {
        uint[] memory MintedTokenIDs = new uint[](1000);
        uint Counter;
        uint CityIDBuffer = (CityID % 7) * 1000;
        uint _TicketID;
        for(uint TicketID; TicketID < 1000; TicketID++)
        {
            _TicketID = TicketID + CityIDBuffer;
            if(_MintedCitizen[CityID][_TicketID]) 
            { 
                MintedTokenIDs[Counter] = _TicketID; 
                Counter++;
            }
        }
        uint[] memory FormattedMintedTokenIDs = new uint[](Counter);
        uint Found;
        for(uint FormattedTokenID; FormattedTokenID < Counter; FormattedTokenID++)
        {
            if(MintedTokenIDs[FormattedTokenID] != 0 || (MintedTokenIDs[FormattedTokenID] == 0 && FormattedTokenID == 0))
            {
                FormattedMintedTokenIDs[Found] = MintedTokenIDs[FormattedTokenID];
                Found++;
            }
        }
        return FormattedMintedTokenIDs;
    }

    /**
     * @dev Returns A 2d Array Of Checked In & Unminted TicketIDs Awaiting A Mint
     */
    function readCitizenCheckedInTicketIDs() public view returns(uint[] memory TokenIDs)
    {
        uint[] memory _TokenIDs = new uint[](1000);
        uint CityIDBuffer = (_CurrentCityIndex % 7) * 1000;
        uint _TicketID;
        uint Counter;
        for(uint TicketID; TicketID < 1000; TicketID++)
        {
            _TicketID = TicketID + CityIDBuffer;
            if(
                !_MintedCitizen[_CurrentCityIndex][_TicketID]
                &&
                _BrightListCitizen[_CurrentCityIndex][_TicketID] != address(0)
            ) 
            { 
                _TokenIDs[Counter] = _TicketID; 
                Counter++;
            }
        }
        uint[] memory FormattedCheckedInTickets = new uint[](Counter);
        uint Found;
        for(uint x; x < Counter; x++)
        {
            if(_TokenIDs[x] != 0 || (_TokenIDs[x] == 0 && x == 0))
            {
                FormattedCheckedInTickets[Found] = _TokenIDs[x];
                Found++;
            }
        }
        return FormattedCheckedInTickets;
    }

    /**
     * @dev Returns A 2d Array Of Minted ArtistIDs
     */
    function readArtistUnmintedTicketIDs(uint[] calldata ArtistIDs, uint Range) public view returns(uint[][] memory TokenIDs)
    {
        uint[][] memory _TokenIDs = new uint[][](ArtistIDs.length);
        uint Index;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            uint[] memory UnmintedArtistTokenIDs = new uint[](Range);
            uint Counter;
            for(uint TokenID; TokenID < Range; TokenID++)
            {
                bool TicketIDBurned;
                try IERC721(_MintPassFactory).ownerOf(TokenID) { } // checks if token is burned
                catch { TicketIDBurned = true; }
                if(
                    !_MintedArtist[ArtistIDs[ArtistID]][TokenID]
                    &&
                    (
                        _BrightListArtist[ArtistIDs[ArtistID]][TokenID] != address(0)
                        ||
                        TicketIDBurned == false
                    )
                ) 
                { 
                    UnmintedArtistTokenIDs[Counter] = TokenID; 
                    Counter++;
                }
            }
            uint[] memory FormattedUnMintedArtistIDs = new uint[](Counter);
            uint Found;
            for(uint x; x < Counter; x++)
            {
                if(UnmintedArtistTokenIDs[x] != 0 || (UnmintedArtistTokenIDs[x] == 0 && x == 0))
                {
                    FormattedUnMintedArtistIDs[Found] = UnmintedArtistTokenIDs[x];
                    Found++;
                }
            }
            _TokenIDs[Index] = FormattedUnMintedArtistIDs;
            Index++;
        }
        return (_TokenIDs);
    }

    /**
     * @dev Returns A 2d Array Of Minted ArtistIDs
     */
    function readArtistMintedTicketIDs(uint[] calldata ArtistIDs, uint Range) public view returns(uint[][] memory TokenIDs)
    {
        uint[][] memory _TokenIDs = new uint[][](ArtistIDs.length);
        uint Index;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            uint[] memory MintedTokenIDs = new uint[](Range);
            uint Counter;
            for(uint TokenID; TokenID < Range; TokenID++)
            {
                if(_MintedArtist[ArtistIDs[ArtistID]][TokenID])
                { 
                    MintedTokenIDs[Counter] = TokenID; 
                    Counter++;
                }
            }
            uint[] memory FormattedMintedTokenIDs = new uint[](Counter);
            uint Found;
            for(uint x; x < Counter; x++)
            {
                if(MintedTokenIDs[x] != 0 || (MintedTokenIDs[x] == 0 && x == 0))
                {
                    FormattedMintedTokenIDs[Found] = MintedTokenIDs[x];
                    Found++;
                }
            }
            _TokenIDs[Index] = FormattedMintedTokenIDs;
            Index++;
        }
        return (_TokenIDs);
    }

    /**
     * @dev Returns Original Recipients Of CryptoCitizens
     */
    function readCitizenBrightList(uint CityIndex) public view returns(address[] memory Recipients)
    {
        address[] memory _Recipients = new address[](1000);
        uint Start = (CityIndex % 7) * 1000;
        for(uint x; x < 1000; x++) { _Recipients[x] = _BrightListCitizen[CityIndex][Start+x]; }
        return _Recipients;
    }

    /**
     * @dev Returns Original Recipient Of Artist NFTs
     */
    function readArtistBrightList(uint ArtistID, uint Range) public view returns(address[] memory Recipients)
    {
        address[] memory _Recipients = new address[](Range);
        for(uint x; x < Range; x++) { _Recipients[x] = _BrightListArtist[ArtistID][x]; }
        return _Recipients;    
    }

    /**
     * @dev Returns The City Struct At Index Of `CityIndex`
     */
    function readCitizenCity(uint CityIndex) public view returns(City memory) { return Cities[CityIndex]; }

    /**
     * @dev Returns The Artist Struct At Index Of `ArtistID`
     */
    function readArtist(uint ArtistID) public view returns(Artist memory) { return Artists[ArtistID]; }

    /**
     * @dev Returns A Minted Work TokenID Corresponding To The Input Artist TicketID 
     */
    function readArtistMintedTokenID(uint ArtistID, uint TicketID) external view returns (uint)
    {
        if(!_MintedArtist[ArtistID][TicketID]) { return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; }
        else { return _MintedTokenIDArtist[ArtistID][TicketID]; }
    }

    /**
     * @dev Returns A Minted Citizen TokenID Corresponding To Input TicketID
     */
    function readCitizenMintedTokenID(uint CityIndex, uint TicketID) external view returns(uint)
    {
        if(!_MintedCitizen[CityIndex][TicketID]) { return type(uint).max; }
        else { return _MintedTokenIDCitizen[CityIndex][TicketID]; }  
    }
    
    /*-------------------------*/
    /*        LAUNCHPAD        */
    /*-------------------------*/

    /**
     * @dev Initializes A LiveMint Artist
     */
    function __InitLiveMint(Artist memory _Params) external onlyAdmin returns (uint)
    {
        AmountRemaining[_UniqueArtistsInvoked] = _Params._MaxSupply;
        Artists[_UniqueArtistsInvoked] = _Params;
        _UniqueArtistsInvoked++;
        return _UniqueArtistsInvoked - 1;
    }

    /*-------------------------*/
    /*     ACCESS MODIFIERS    */
    /*-------------------------*/

    /**
     * @dev Access Modifier That Allows Only BrightListed BRT Minters
     **/
    modifier onlyMinter() 
    {
        require(Role[msg.sender] == _MINTER_ROLE, "LiveMint | onlyMinter | Caller Is Not Approved BRT Minter");
        _;
    }

    /**
     * @dev Access Modifier That Allows Only Authorized Contracts
     */
    modifier onlyAdmin()
    {
        require(Role[msg.sender] == _AUTHORIZED || msg.sender == _LAUNCHPAD || msg.sender == owner(), "LiveMint | onlyAdmin | Caller Is Not Approved Admin");
        _;
    }
}
interface IDelegationRegistry
{
    /**
     * @dev Checks If A Vault Has Delegated To The Delegate
     */
    function checkDelegateForAll(address delegate, address delegator) external view returns (bool);
}
//SPDX-License-Identifier: MIT
/**
 * @title LiveMintEnabled
 * @dev @brougkr
 * note: This Contract Is Used To Enable LiveMint To Purchase Tokens From Your Contract
 * note: This Contract Should Be Imported and Included In The `is` Portion Of The Contract Declaration, ex. `contract NFT is Ownable, LiveMintEnabled`
 * note: You Can Copy Or Modify The Example Functions Below To Implement The Two Functions In Your Contract
 */
pragma solidity 0.8.19;
abstract contract LiveMintEnabled
{
    /**
     * @dev LiveMint purchaseTo
     * note: Should Be Implemented With onlyLiveMint Access Modifier
     * note: Should Return The TokenID Being Transferred To The Recipient
     */
    function purchaseTo(address Recipient) external virtual returns (uint tokenID);

    // purchaseTo() EXAMPLE: 
    // Here Is An Example Of The Function Implemented In An Standard ERC721 Contract (you can copy paste the function below into your contract)
    // function purchaseTo(address Recipient) override virtual external onlyLiveMint returns (uint tokenID) 
    // {
    //     _mint(Recipient, 1);
    //     return (totalSupply() - 1);
    // }

    /**
     * @dev ChangeLiveMintAddress Changes The LiveMint Address | note: Should Be Implemented To Include onlyOwner Or Similar Access Modifier
     */
    function _ChangeLiveMintAddress(address LiveMintAddress) external virtual;

    // _ChangeLiveMintAddress EXAMPLE: 
    // Here Is An Example Of The Function Implemented In An Standard ERC721 Contract (you can copy paste the function below into your contract)
    // function _ChangeLiveMintAddress(address LiveMintAddress) override virtual external onlyOwner { _LIVE_MINT_ADDRESS = LiveMintAddress; }

    /**
     * @dev LiveMint Address
     */
    address public _LIVE_MINT_ADDRESS = 0x76375092724A9cE835d117106E0F374E85EFa42B; 

    /**
     * @dev Access Modifier For LiveMint
     */
    modifier onlyLiveMint
    {
        require(msg.sender == _LIVE_MINT_ADDRESS, "onlyLiveMint: msg.sender Is Not The LiveMint Contract");
        _;
    }
}
// SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import { IERC721 } from "@openzeppelin/contracts/interfaces/IERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IMinter } from "./IMinter.sol";
import { IMP } from "./IMP.sol";
import { IGT } from "./IGT.sol";
import { LaunchpadEnabled } from "./LaunchpadEnabled.sol";
contract LiveMintTokyo is Ownable, ReentrancyGuard, LaunchpadEnabled
{  
    struct City
    {
        string _Name;         // _Name
        uint _QRCurrentIndex; // _QRCurrentIndex (Should be Always Be 333 + (333 * (City# % 6))
        address _ERC20;       // _ERC20 
        bytes32 _Root;        // _Root
    }

    struct Artist
    {
        address _MintPass;        // _MintPass
        address _Minter;          // _Minter
        address _PolyptychSource; // _PolyptychSource
        uint _MaxSupply;          // _MaxSupply
        uint _MintPassProjectID;  // _MintPassProjectID
        uint _ArtBlocksProjectID; // _ArtBlocksProjectID 
        uint _PolyStart;          // _PolyStart
        uint _PolyEnd;            // _PolyEnd
    }

    struct User
    {
        bool _Eligible;   // _Eligible
        uint _Allocation; // _Allocation
    }

    /*-------------------*/
    /*  STATE VARIABLES  */
    /*-------------------*/

    bytes32 private constant _AUTHORIZED = keccak256("AUTHORIZED");                        // Authorized Role
    bytes32 private constant _MINTER_ROLE = keccak256("MINTER_ROLE");                      // Minter Role
    address private constant _DN = 0x00000000000076A84feF008CDAbe6409d2FE638B;             // delegate.cash Delegation Registry
    address private constant _GOLDEN_TOKEN = 0x985e1932FFd2aA4bC9cE611DFe12816A248cD2cE;   // Golden Token Address
    address private constant _CITIZEN_MINTER = 0xDd06d8483868Cd0C5E69C24eEaA2A5F2bEaFd42b; // ArtBlocks Minter Contract
    address private constant _BRT_MULTISIG = 0xB96E81f80b3AEEf65CB6d0E280b15FD5DBE71937;   // BRT Multisig
    address public _Pindar;                                                                // Pindar Van Arman's Custom Minter Contract
    uint public _CurrentCityIndex = 6;                                                     // Current City Index
    uint public _UniqueArtistsInvoked;                                                     // Unique Artists Invoked

    /*-------------------*/
    /*     MAPPINGS      */
    /*-------------------*/
    
    mapping(uint => Artist) public Artists;                              // [ArtistID] => Artist
    mapping(uint => City) public Cities;                                 // [CityIndex] => City Struct
    mapping(uint => mapping(address => bool)) public _QRRedeemed;        // [CityIndex][Wallet] => If User Has Redeemed QR
    mapping(uint => mapping(address => uint)) public _QRAllocation;      // [CityIndex][Wallet] => Wallet's QR Code Allocation
    mapping(uint => mapping(uint => address)) public _BrightListCitizen; // [CityIndex][TicketID] => Address Of CryptoCitizen Minting Recipient 
    mapping(uint => mapping(uint => address)) public _BrightListArtist;  // [ArtistID][TicketID] => Address Of Artist NFT Recipient
    mapping(uint => mapping(uint => string)) public _DataArtists;        // [ArtistID][TicketID] => Artist Data
    mapping(uint => mapping(uint => string)) public _DataCitizens;       // [CityIndex][TicketID] => Data For Golden Token Checkins
    mapping(uint => mapping(uint => uint)) public _MintedTokenIDCitizen; // [CityIndex][TicketID] => MintedTokenID
    mapping(uint => mapping(uint => uint)) public _MintedTokenIDArtist;  // [ArtistID][TicketID] => MintedTokenID
    mapping(uint => mapping(uint => bool)) public _MintedArtist;         // [ArtistID][TicketID] => If Minted
    mapping(uint => mapping(uint => bool)) public _MintedCitizen;        // [CityIndex][TicketID] => If Golden Ticket ID Has Minted Or Not
    mapping(uint => mapping(uint => uint)) public _ArtBlocksProjectID;   // [ArtistID][TicketID] => ArtBlocksProjectID
    mapping(address => bytes32) public Role;                             // [Wallet] => BRT Minter Role
    mapping(uint => uint) public AmountRemaining;                        // [ArtistID] => Mints Remaining

    /*-------------------*/
    /*      EVENTS       */
    /*-------------------*/

    /**
     * @dev Emitted When `Redeemer` IRL-mints CryptoCitizen Corresponding To Their Redeemed `TicketID`.
     **/
    event LiveMintComplete(address Redeemer, uint TicketID, uint TokenID, string Data);

    /**
     * @dev Emitted When `Redeemer` IRL-mints A Artist NFT Corresponding To Their Redeemed `TicketID`.
     */
    event LiveMintCompleteArtist(address Recipient, uint ArtistID, uint TicketID, uint MintedWorkTokenID);

    /**
     * @dev Emitted When `Redeemer` Redeems Golden Token Corresponding To `TicketID` 
     **/
    event QRRedeemed(address Redeemer, uint TicketID, string Data, string Type);

    /**
     * @dev Emitted When A Contract Is Authorized
     */
    event AuthorizedContract(address NewAddress);

    /**
     * @dev Emitted When A Contract Is Deauthorized
     */
    event DeauthorizedContract(address NewAddress);

    /*-------------------*/
    /*    CONSTRUCTOR    */
    /*-------------------*/

    constructor()
    { 
        Cities[0]._Name = "CryptoGalacticans";  
        Cities[1]._Name = "CryptoVenetians";    
        Cities[2]._Name = "CryptoNewYorkers";   
        Cities[3]._Name = "CryptoBerliners";    
        Cities[4]._Name = "CryptoLondoners";    
        Cities[5]._Name = "CryptoMexas";        
        Cities[6]._Name = "CryptoTokyites";     
        Cities[6]._QRCurrentIndex = 333;
        Cities[6]._Root = 0x255b8b82ee0d1823cdc3cf859efacfee1111414bacab649a7e8bea9cd48a0ed3;
        Cities[7]._Name = "CryptoCitizen City #8"; 
        Cities[7]._QRCurrentIndex = 666;
        Cities[8]._Name = "CryptoCitizen City #9";
        Cities[8] ._QRCurrentIndex = 999;
        Cities[9]._Name = "CryptoCitizen City #10";
        Cities[10]._QRCurrentIndex = 1332; 
        Role[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = _AUTHORIZED;  // `operator.brightmoments.eth`
        Role[0x1A0a3E3AE390a0710f8A6d00587082273eA8F6C9] = _MINTER_ROLE; // BRT Minter #1
        Role[0x4d8013b0c264034CBf22De9DF33e22f58D52F207] = _MINTER_ROLE; // BRT Minter #2
        Role[0x4D9A8CF2fE52b8D49C7F7EAA87b2886c2bCB4160] = _MINTER_ROLE; // BRT Minter #3
        Role[0x124fd966A0D83aA020D3C54AE2c9f4800b46F460] = _MINTER_ROLE; // BRT Minter #4
        Role[0x100469feA90Ac1Fe1073E1B2b5c020A8413635c4] = _MINTER_ROLE; // BRT Minter #5
        Role[0x756De4236373fd17652b377315954ca327412bBA] = _MINTER_ROLE; // BRT Minter #6
        Role[0xc5Dfba6ef7803665C1BDE478B51Bd7eB257A2Cb9] = _MINTER_ROLE; // BRT Minter #7
        Role[0xFBF32b29Bcf8fEe32d43a4Bfd3e7249daec457C0] = _MINTER_ROLE; // BRT Minter #8
        Role[0xF2A15A83DEE7f03C70936449037d65a1C100FF27] = _MINTER_ROLE; // BRT Minter #9
        Role[0x1D2BAB965a4bB72f177Cd641C7BacF3d8257230D] = _MINTER_ROLE; // BRT Minter #10
        Role[0x2e51E8b950D72BDf003b58E357C2BA28FB77c7fB] = _MINTER_ROLE; // BRT Minter #11
        Role[0x8a7186dECb91Da854090be8226222eA42c5eeCb6] = _MINTER_ROLE; // BRT Minter #12
    }

    /*---------------------*/
    /*    QR REDEMPTION    */
    /*---------------------*/

    /**
     * @dev Redeems Spot For IRL Minting
     */
    function RedeemQR(string[] calldata Data, string[] calldata Type, bytes32[] calldata Proof, address Vault, uint Amount) external nonReentrant 
    {        
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(IDelegationRegistry(_DN).checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } } 
        require(readQREligibility(Recipient, Proof), "LiveMint: User Is Not Eligible To Redeem QR");
        if(_QRAllocation[_CurrentCityIndex][Recipient] == 0) // User Is Able To Redeem Explicitly 1 QR Code
        {
            require(!_QRRedeemed[_CurrentCityIndex][Recipient], "LiveMint: User Has Already Redeemed");
            _DataCitizens[_CurrentCityIndex][Cities[_CurrentCityIndex]._QRCurrentIndex] = Data[0];
            _BrightListCitizen[_CurrentCityIndex][Cities[_CurrentCityIndex]._QRCurrentIndex] = Recipient;
            emit QRRedeemed(Recipient, Cities[_CurrentCityIndex]._QRCurrentIndex, Data[0], Type[0]);
            Cities[_CurrentCityIndex]._QRCurrentIndex++; 
        }
        else // User Is Able To Redeem More Than 1 QR Code Because Their QRAllocation > 0
        {
            require(Amount <= _QRAllocation[_CurrentCityIndex][Recipient], "LiveMint: Amount Must Be Less Than Or Equal To QRAllocation");
            uint _CurrentQR = Cities[_CurrentCityIndex]._QRCurrentIndex;
            uint _Limit = Amount + _CurrentQR;
            uint _Counter;
            _QRAllocation[_CurrentCityIndex][Recipient] -= Amount;
            Cities[_CurrentCityIndex]._QRCurrentIndex = _Limit;
            for(_CurrentQR; _CurrentQR < _Limit; _CurrentQR++)
            {
                _DataCitizens[_CurrentCityIndex][_CurrentQR] = Data[_Counter];
                _BrightListCitizen[_CurrentCityIndex][_CurrentQR] = Recipient;
                emit QRRedeemed(Recipient, _CurrentQR, Data[_Counter], Type[_Counter]);
                _Counter++;
            }
        }
        _QRRedeemed[_CurrentCityIndex][Recipient] = true;
    }

    /*--------------------*/
    /*    LIVE MINTING    */
    /*--------------------*/

    /**
     * @dev Batch Mints Verified Users On The Brightlist CryptoCitizens
     * note: { For CryptoCitizen Cities }
     */
    function _LiveMintCitizen(uint[] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        uint MintedWorkTokenID;
        for(uint TicketID; TicketID < TicketIDs.length; TicketID++)
        {
            require(!_MintedCitizen[_CurrentCityIndex][TicketIDs[TicketID]], "LiveMint: Golden Token Already Minted");
            if(_BrightListCitizen[_CurrentCityIndex][TicketIDs[TicketID]] != address(0))
            {
                Recipient = _BrightListCitizen[_CurrentCityIndex][TicketIDs[TicketID]];
            }
            else if (TicketIDs[TicketID] < 333) { Recipient = IGT(_GOLDEN_TOKEN)._LiveMintBurn(TicketIDs[TicketID]); }
            else { revert("LiveMint: Invalid TicketID"); }
            require(Recipient != address(0), "LiveMint: Invalid Recipient");
            _MintedCitizen[_CurrentCityIndex][TicketIDs[TicketID]] = true;
            MintedWorkTokenID = IMinter(_CITIZEN_MINTER).purchaseTo(Recipient, _CurrentCityIndex);
            _MintedTokenIDCitizen[_CurrentCityIndex][TicketIDs[TicketID]] = MintedWorkTokenID;
            emit LiveMintComplete(Recipient, TicketIDs[TicketID], MintedWorkTokenID, _DataCitizens[_CurrentCityIndex][TicketIDs[TicketID]]); 
        }
    }

    /**
     * @dev Burns Artist Mint Pass In Exchange For The Minted Work
     * note: { For Instances Where Multiple Artists Share The Same Mint Pass & Return (Recipient, ArtBlocksProjectID) }
     */
    function _LiveMintArtist(uint ArtistID, uint[] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        address MintPass = Artists[ArtistID]._MintPass;
        address Minter = Artists[ArtistID]._Minter;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        require(AmountRemaining[ArtistID] > 0, "LiveMint: ArtistID Mint Limit Reached");
        require(TicketIDs.length <= AmountRemaining[ArtistID], "LiveMint: TicketID Length Exceeds ArtistID Mint Limit");
        AmountRemaining[ArtistID] = AmountRemaining[ArtistID] - TicketIDs.length;
        for(uint x; x < TicketIDs.length; x++)
        {
            TicketID = TicketIDs[x];
            require(!_MintedArtist[ArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
            _MintedArtist[ArtistID][TicketID] = true;
            (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
            if(ArtBlocksProjectID == 100) { MintedWorkTokenID = IMinter(_Pindar).purchaseTo(Recipient); } // Pindar Custom Contract 
            else { MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID); } // Pre-Defined Minter Contract
            _MintedTokenIDArtist[ArtistID][TicketID] = MintedWorkTokenID;
            emit LiveMintCompleteArtist(Recipient, ArtistID, TicketID, MintedWorkTokenID);
        }
    }

    /**
     * @dev Burns Artist Mint Pass In Exchange For The Minted Work
     * note: { For Instances Where Multiple Artists Share The Same Mint Pass & Return (Recipient, ArtBlocksProjectID) }
     */
    function _LiveMintArtistBatch(uint[] calldata ArtistIDs, uint[][] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        address MintPass;
        address Minter;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        uint ActiveArtistID;
        for(uint ArtistIDIndex; ArtistIDIndex < ArtistIDs.length; ArtistIDIndex++)
        {
            ActiveArtistID = ArtistIDs[ArtistIDIndex];
            MintPass = Artists[ActiveArtistID]._MintPass;
            Minter = Artists[ActiveArtistID]._Minter;
            for(uint TicketIDIndex; TicketIDIndex < TicketIDs[ArtistIDIndex].length; TicketIDIndex++)
            {
                TicketID = TicketIDs[ArtistIDIndex][TicketIDIndex];
                require(!_MintedArtist[ActiveArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
                _MintedArtist[ActiveArtistID][TicketID] = true;
                (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
                if(ArtBlocksProjectID == 100) { MintedWorkTokenID = IMinter(_Pindar).purchaseTo(Recipient); }
                else { MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID); }
                _MintedTokenIDArtist[ActiveArtistID][TicketID] = MintedWorkTokenID;
                emit LiveMintCompleteArtist(Recipient, ActiveArtistID, TicketID, MintedWorkTokenID);
            }
        }
    }

    /*-------------------*/
    /*  OWNER FUNCTIONS  */
    /*-------------------*/

    /**
     * @dev Grants Address BRT Minter Role
     **/
    function __AddMinter(address Minter) external onlyOwner { Role[Minter] = _MINTER_ROLE; }
    
    /**
     * @dev Deactivates Address From BRT Minter Role
     **/
    function __RemoveMinter(address Minter) external onlyOwner { Role[Minter] = 0x0; }

    /**
     * @dev Changes Mint Pass Address For Artist LiveMints
     */
    function __ChangeMintPass(uint ProjectID, address Contract) external onlyOwner { Artists[ProjectID]._MintPass = Contract; }

    /**
     * @dev Changes Merkle Root For Citizen LiveMints
     */
    function __ChangeRootCitizen(bytes32 NewRoot) external onlyOwner { Cities[_CurrentCityIndex]._Root = NewRoot; }

    /**
     * @dev Overwrites QR Allocation
     */
    function __QRAllocationsOverwrite(address[] calldata Addresses, uint[] calldata Amounts) external onlyOwner
    {
        require(Addresses.length == Amounts.length, "LiveMint: Input Arrays Must Match");
        for(uint x; x < Addresses.length; x++) { _QRAllocation[_CurrentCityIndex][Addresses[x]] = Amounts[x]; }
    }

    /**
     * @dev Increments QR Allocations
     */
    function __QRAllocationsIncrement(address[] calldata Addresses, uint[] calldata Amounts) external onlyOwner
    {
        require(Addresses.length == Amounts.length, "LiveMint: Input Arrays Must Match");
        for(uint x; x < Addresses.length; x++) { _QRAllocation[_CurrentCityIndex][Addresses[x]] += Amounts[x]; }
    }

    /**
     * @dev Mints To Multisig
     */
    function __QRAllocationsSetNoShow(uint[] calldata TicketIDs) external onlyOwner
    {
        for(uint TicketIndex; TicketIndex < TicketIDs.length; TicketIndex++)
        {
            require(!_MintedCitizen[_CurrentCityIndex][TicketIDs[TicketIndex]], "LiveMint: Ticket ID Already Minted");
            _BrightListCitizen[_CurrentCityIndex][TicketIDs[TicketIndex]] = _BRT_MULTISIG;
        }
    }

    /**
     * @dev Changes QR Current Index
     */
    function __ChangeQRIndex(uint NewIndex) external onlyOwner { Cities[_CurrentCityIndex]._QRCurrentIndex = NewIndex; }

    /**
     * @dev Changes Pindar's Minter Address
     */
    function __ChangePindarAddress(address NewAddress) external onlyOwner { _Pindar = NewAddress; }

    /**
     * @dev Batch Approves BRT For Purchasing
     */
    function __BatchApproveERC20(address[] calldata ERC20s, address[] calldata Operators) external onlyOwner
    {
        require(ERC20s.length == Operators.length, "LiveMint: Arrays Must Be Equal Length");
        for(uint x; x < ERC20s.length; x++) { IERC20(ERC20s[x]).approve(Operators[x], 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff); }
    }

    /**
     * @dev Instantiates New City
     * note: CityIndex Always Corresponds To ArtBlocks ProjectID
     */
    function __NewCity (
        string calldata Name,
        uint CityIndex,
        uint QRIndex,
        address ERC20
    ) external onlyOwner {
        Cities[CityIndex] = City(
            Name,
            QRIndex,
            ERC20,
            0x6942069420694206942069420694206942069420694206942069420694206942
        );
    }

    /**
     * @dev Overrides An Artist
     */
    function __OverrideArtist(uint ArtistID, Artist memory NewArtist) external onlyOwner { Artists[ArtistID] = NewArtist; }

    /**
     * @dev Instantiates A New City
     */
    function __NewCityStruct(uint CityIndex, City memory NewCity) external onlyOwner { Cities[CityIndex] = NewCity; }

    /**
     * @dev Returns An Artist Struct
     */
    function __NewArtistStruct(uint ArtistID, Artist memory NewArtist) external onlyOwner { Artists[ArtistID] = NewArtist; }

    /**
     * @dev Changes The Minter Address For An Artist
     */
    function __NewArtistMinter(uint ArtistID, address Minter) external onlyOwner { Artists[ArtistID]._Minter = Minter; }

    /**
     * @dev Withdraws Any Ether Mistakenly Sent to Contract to Multisig
     **/
    function __WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Withdraws ERC20 Tokens to Multisig
     **/
    function __WithdrawERC20(address TokenAddress) external onlyOwner 
    { 
        IERC20 erc20Token = IERC20(TokenAddress);
        uint balance = erc20Token.balanceOf(address(this));
        require(balance > 0, "LiveMint: 0 ERC20 Balance At `TokenAddress`");
        erc20Token.transfer(msg.sender, balance);
    }

    /**
     * @dev Withdraws Any NFT Mistakenly Sent To This Contract.
     */
    function __WithdrawERC721(address ContractAddress, address Recipient, uint TokenID) external onlyOwner
    {
        IERC721(ContractAddress).transferFrom(address(this), Recipient, TokenID);
    }

    /**
     * @dev Authorizes A Contract To Mint
     */
    function ____AuthorizeContract(address NewAddress) external onlyOwner 
    { 
        Role[NewAddress] = _AUTHORIZED; 
        emit AuthorizedContract(NewAddress);
    }

    /**
     * @dev Deauthorizes A Contract From Minting
     */
    function ___DeauthorizeContract(address NewAddress) external onlyOwner 
    { 
        Role[NewAddress] = 0x0; 
        emit DeauthorizedContract(NewAddress);
    }
    
    /*-------------------*/
    /*    PUBLIC VIEW    */
    /*-------------------*/

    /**
     * @dev Returns A User's QR Allocation Amount, Or 0 If Not Eligible
     */
    function readEligibility(address Recipient, bytes32[] memory Proof) public view returns(uint)
    {
        bool Eligible = readQREligibility(Recipient, Proof);
        if(!Eligible) { return 0; }
        else if(Eligible && _QRAllocation[_CurrentCityIndex][Recipient] > 0) { return _QRAllocation[_CurrentCityIndex][Recipient]; }
        else if(Eligible) { return 1; }
        else { return 0; }
    }

    /**
     * @dev Returns If User Is Eligible To Redeem QR Code
     */
    function readQREligibility(address Recipient, bytes32[] memory Proof) public view returns(bool)
    {
        bytes32 Leaf = keccak256(abi.encodePacked(Recipient));
        bool BrightListEligible = MerkleProof.verify(Proof, Cities[_CurrentCityIndex]._Root, Leaf);
        if(
            (BrightListEligible && !_QRRedeemed[_CurrentCityIndex][Recipient])
            || 
            (BrightListEligible && _QRAllocation[_CurrentCityIndex][Recipient] > 0)
            
        ) { return true; }
        else { return false; }
    }

    /**
     * @dev Returns An Array Of Unminted Golden Tokens
     */
    function readCitizenUnmintedTicketIDs() public view returns(uint[] memory)
    {
        uint[] memory UnmintedTokenIDs = new uint[](1000);
        uint Counter;
        uint CityIDBuffer = _CurrentCityIndex % 6 * 333;
        uint _TokenID;
        for(uint TokenID; TokenID < 1000; TokenID++)
        {
            _TokenID = TokenID + CityIDBuffer;
            if
            (
                !_MintedCitizen[_CurrentCityIndex][_TokenID]
                &&
                _BrightListCitizen[_CurrentCityIndex][_TokenID] != address(0)
            ) 
            { 
                UnmintedTokenIDs[Counter] = _TokenID; 
                Counter++;
            }
        }
        uint[] memory FormattedUnMintedTokenIDs = new uint[](Counter);
        uint Found;
        for(uint FormattedTokenID; FormattedTokenID < Counter; FormattedTokenID++)
        {
            if(UnmintedTokenIDs[FormattedTokenID] != 0 || (UnmintedTokenIDs[FormattedTokenID] == 0 && FormattedTokenID == 0))
            {
                FormattedUnMintedTokenIDs[Found] = UnmintedTokenIDs[FormattedTokenID];
                Found++;
            }
        }
        return FormattedUnMintedTokenIDs;
    }

    /**
     * @dev Returns An Array Of Unminted Golden Tokens
     */
    function readCitizenMintedTicketIDs(uint CityID) public view returns(uint[] memory)
    {
        uint[] memory MintedTokenIDs = new uint[](1000);
        uint Counter;
        uint CityIDBuffer = (CityID % 6) * 333;
        uint _TicketID;
        for(uint TicketID; TicketID < 1000; TicketID++)
        {
            _TicketID = TicketID + CityIDBuffer;
            if(_MintedCitizen[CityID][_TicketID]) 
            { 
                MintedTokenIDs[Counter] = _TicketID; 
                Counter++;
            }
        }
        uint[] memory FormattedMintedTokenIDs = new uint[](Counter);
        uint Found;
        for(uint FormattedTokenID; FormattedTokenID < Counter; FormattedTokenID++)
        {
            if(MintedTokenIDs[FormattedTokenID] != 0 || (MintedTokenIDs[FormattedTokenID] == 0 && FormattedTokenID == 0))
            {
                FormattedMintedTokenIDs[Found] = MintedTokenIDs[FormattedTokenID];
                Found++;
            }
        }
        return FormattedMintedTokenIDs;
    }

    /**
     * @dev Returns A 2d Array Of Checked In & Unminted TicketIDs Awaiting A Mint
     */
    function readCitizenCheckedInTicketIDs() public view returns(uint[] memory TokenIDs)
    {
        uint[] memory _TokenIDs = new uint[](1000);
        uint CityIDBuffer = (_CurrentCityIndex % 6) * 333;
        uint _TicketID;
        uint Counter;
        for(uint TicketID; TicketID < 1000; TicketID++)
        {
            _TicketID = TicketID + CityIDBuffer;
            if(
                !_MintedCitizen[_CurrentCityIndex][_TicketID]
                &&
                _BrightListCitizen[_CurrentCityIndex][_TicketID] != address(0)
            ) 
            { 
                _TokenIDs[Counter] = _TicketID; 
                Counter++;
            }
        }
        uint[] memory FormattedCheckedInTickets = new uint[](Counter);
        uint Found;
        for(uint x; x < Counter; x++)
        {
            if(_TokenIDs[x] != 0 || (_TokenIDs[x] == 0 && x == 0))
            {
                FormattedCheckedInTickets[Found] = _TokenIDs[x];
                Found++;
            }
        }
        return FormattedCheckedInTickets;
    }

    /**
     * @dev Returns A 2d Array Of Minted ArtistIDs
     */
    function readArtistUnmintedTicketIDs(uint[] calldata ArtistIDs, uint Range) public view returns(uint[][] memory TokenIDs)
    {
        uint[][] memory _TokenIDs = new uint[][](ArtistIDs.length);
        uint Index;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            address _Mintpass = Artists[ArtistID]._MintPass;
            uint[] memory UnmintedArtistTokenIDs = new uint[](Range);
            uint Counter;
            for(uint TokenID; TokenID < Range; TokenID++)
            {
                bool TicketIDBurned;
                try IERC721(_Mintpass).ownerOf(TokenID) { } // checks if token is burned
                catch { TicketIDBurned = true; }
                if(
                    !_MintedArtist[ArtistIDs[ArtistID]][TokenID]
                    &&
                    (
                        _BrightListArtist[ArtistIDs[ArtistID]][TokenID] != address(0)
                        ||
                        TicketIDBurned == false
                    )
                ) 
                { 
                    UnmintedArtistTokenIDs[Counter] = TokenID; 
                    Counter++;
                }
            }
            uint[] memory FormattedUnMintedArtistIDs = new uint[](Counter);
            uint Found;
            for(uint x; x < Counter; x++)
            {
                if(UnmintedArtistTokenIDs[x] != 0 || (UnmintedArtistTokenIDs[x] == 0 && x == 0))
                {
                    FormattedUnMintedArtistIDs[Found] = UnmintedArtistTokenIDs[x];
                    Found++;
                }
            }
            _TokenIDs[Index] = FormattedUnMintedArtistIDs;
            Index++;
        }
        return (_TokenIDs);
    }

    /**
     * @dev Returns A 2d Array Of Minted ArtistIDs
     */
    function readArtistMintedTicketIDs(uint[] calldata ArtistIDs, uint Range) public view returns(uint[][] memory TokenIDs)
    {
        uint[][] memory _TokenIDs = new uint[][](ArtistIDs.length);
        uint Index;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            uint[] memory MintedTokenIDs = new uint[](Range);
            uint Counter;
            for(uint TokenID; TokenID < Range; TokenID++)
            {
                if(_MintedArtist[ArtistIDs[ArtistID]][TokenID])
                { 
                    MintedTokenIDs[Counter] = TokenID; 
                    Counter++;
                }
            }
            uint[] memory FormattedMintedTokenIDs = new uint[](Counter);
            uint Found;
            for(uint x; x < Counter; x++)
            {
                if(MintedTokenIDs[x] != 0 || (MintedTokenIDs[x] == 0 && x == 0))
                {
                    FormattedMintedTokenIDs[Found] = MintedTokenIDs[x];
                    Found++;
                }
            }
            _TokenIDs[Index] = FormattedMintedTokenIDs;
            Index++;
        }
        return (_TokenIDs);
    }

    /**
     * @dev Returns Original Recipients Of CryptoCitizens
     */
    function readCitizenBrightList(uint CityIndex) public view returns(address[] memory Recipients)
    {
        address[] memory _Recipients = new address[](1000);
        uint Start = (CityIndex % 6) * 333;
        for(uint x; x < 1000; x++) { _Recipients[x] = _BrightListCitizen[CityIndex][Start+x]; }
        return _Recipients;
    }

    /**
     * @dev Returns Original Recipient Of Artist NFTs
     */
    function readArtistBrightList(uint ArtistID, uint Range) public view returns(address[] memory Recipients)
    {
        address[] memory _Recipients = new address[](Range);
        for(uint x; x < Range; x++) { _Recipients[x] = _BrightListArtist[ArtistID][x]; }
        return _Recipients;    
    }

    /**
     * @dev Returns The City Struct At Index Of `CityIndex`
     */
    function readCitizenCity(uint CityIndex) public view returns(City memory) { return Cities[CityIndex]; }

    /**
     * @dev Returns The Artist Struct At Index Of `ArtistID`
     */
    function readArtist(uint ArtistID) public view returns(Artist memory) { return Artists[ArtistID]; }

    /**
     * @dev Returns A Minted Work TokenID Corresponding To The Input Artist TicketID 
     */
    function readArtistMintedTokenID(uint ArtistID, uint TicketID) external view returns (uint)
    {
        if(!_MintedArtist[ArtistID][TicketID]) { return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; }
        else { return _MintedTokenIDArtist[ArtistID][TicketID]; }
    }

    /**
     * @dev Returns A Minted Citizen TokenID Corresponding To Input TicketID
     */
    function readCitizenMintedTokenID(uint CityIndex, uint TicketID) external view returns(uint)
    {
        if(!_MintedCitizen[CityIndex][TicketID]) { return type(uint).max; }
        else { return _MintedTokenIDCitizen[CityIndex][TicketID]; }  
    }
    
    /*-------------------------*/
    /*        LAUNCHPAD        */
    /*-------------------------*/

    /**
     * @dev Initializes A LiveMint Artist
     */
    function __InitLiveMint(Artist memory _Params) external onlyAdmin returns (uint)
    {
        AmountRemaining[_UniqueArtistsInvoked] = _Params._MaxSupply;
        Artists[_UniqueArtistsInvoked] = _Params;
        _UniqueArtistsInvoked++;
        return _UniqueArtistsInvoked - 1;
    }

    /*-------------------------*/
    /*     ACCESS MODIFIERS    */
    /*-------------------------*/

    /**
     * @dev Access Modifier That Allows Only BrightListed BRT Minters
     **/
    modifier onlyMinter() 
    {
        require(Role[msg.sender] == _MINTER_ROLE, "LiveMint | onlyMinter | Caller Is Not Approved BRT Minter");
        _;
    }

    /**
     * @dev Access Modifier That Allows Only Authorized Contracts
     */
    modifier onlyAdmin()
    {
        require(Role[msg.sender] == _AUTHORIZED || msg.sender == _LAUNCHPAD || msg.sender == owner(), "LiveMint | onlyAdmin | Caller Is Not Approved Admin");
        _;
    }
}
interface IDelegationRegistry
{
    /**
     * @dev Checks If A Vault Has Delegated To The Delegate
     */
    function checkDelegateForAll(address delegate, address delegator) external view returns (bool);
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721AO } from "./ERC721AO.sol";
import { DefaultOperatorFilterer } from "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import { IOS } from "./IOS.sol";
import { MarketplaceEnabled } from "./MarketplaceEnabled.sol";
contract MPAM is Ownable, ERC721AO, DefaultOperatorFilterer, MarketplaceEnabled
{
    uint public _ArtBlocksProjectID = 69420;
    string public baseURI = "ipfs://QmeryLD1ew3BHGekrRzYs9oH5v13vp3aXFYjovRcVAf2VG/";
    address public _LIVE_MINT = 0x158E81d47C0199132a4D70940AEdBA5566551bd4;

    constructor() ERC721AO("Mint Pass AMBUSH | AMBUSH x Bright Moments | MPAM", "MPAM") { }

    /**
     * @dev Factory Mint
     */
    function _MintToFactory(uint ProjectID, address Recipient, uint Amount) override virtual external onlyMarketplace
    {
        require(totalSupply() + Amount <= 100, "MP: Max Supply Reached");
        _mint(Recipient, Amount); 
    }

    /**
     * @dev Changes The Marketplace Address
     */
    function __ChangeMarketplaceAddress(address NewAddress) override virtual external onlyOwner { _MARKETPLACE_ADDRESS = NewAddress; }

    /**
     * @dev Changes ArtBlocks ProjectID Returned From LiveMint
     */
    function __ChangeArtBlocksProjectID(uint NewArtistID) external onlyOwner { _ArtBlocksProjectID = NewArtistID; }

    /**
     * @dev Executes Arbitrary Transaction(s)
     */
    function __Execute(address[] memory Targets, uint[] memory Values, bytes[] memory Datas) external onlyOwner
    {
        for (uint x; x < Targets.length; x++) 
        {
            (bool success,) = Targets[x].call{value:(Values[x])}(Datas[x]);
            require(success, "i have failed u anakin");
        }
    }

    /**
     * @dev Instantiates New LiveMint Address
     */
    function ___NewLiveMintAddress(address NewAddress) external onlyOwner { _LIVE_MINT = NewAddress; }

    /**
     * @dev Changes The BaseURI For JSON Metadata 
     */
    function ___NewBaseURI(string calldata NewURI) external onlyOwner { baseURI = NewURI; }

    /**
     * @dev Burns Golden Token(s)
     */
    function ___OwnerBurn(uint[] calldata TokenIDs) external onlyOwner { for(uint x; x < TokenIDs.length; x++){ _burn(TokenIDs[x], false); } }

    /**
     * @dev Withdraws All Ether From The Contract
     */
    function ___WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Withdraws Ether From Contract To Address With An Amount
     */
    function ___WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /**
     * @dev Withdraws ERC20 Tokens
     **/
    function __WithdrawERC20(address TokenAddress) external onlyOwner 
    { 
        IERC20 erc20Token = IERC20(TokenAddress);
        uint balance = erc20Token.balanceOf(address(this));
        require(balance > 0, "0 ERC20 Balance At `TokenAddress`");
        erc20Token.transfer(msg.sender, balance);
    }

    /**
     * @dev Withdraws ERC721(s) Mistakenly Sent To Contract, From The Contract
     */
    function ___WithdrawERC721(address Contract, address Recipient, uint[] calldata TokenIDs) external onlyOwner 
    { 
        for(uint TokenID; TokenID < TokenIDs.length; TokenID++)
        {
            IERC721(Contract).transferFrom(address(this), Recipient, TokenIDs[TokenID]);
        }
    }
    
    /**
     * @dev Returns Base URI
     */
    function _baseURI() internal view virtual override returns (string memory) { return baseURI; }

    /*---------------------
     * OVERRIDE FUNCTIONS *
    ----------------------*/

    function setApprovalForAll(
        address operator, 
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) { super.setApprovalForAll(operator, approved); }

    function approve(
        address operator, 
        uint256 tokenId
    ) public override onlyAllowedOperatorApproval(operator) { super.approve(operator, tokenId); }

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override onlyAllowedOperator(from) { super.transferFrom(from, to, tokenId); }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override onlyAllowedOperator(from) { super.safeTransferFrom(from, to, tokenId); }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) public override onlyAllowedOperator(from) { super.safeTransferFrom(from, to, tokenId, data); }

    /*--------------------
     * LIVEMINT FUNCTION *
    ---------------------*/

    function _LiveMintArtist(uint ArtistID, uint[] calldata TicketIDs) external onlyOwner
    {
        for(uint x; x < TicketIDs.length; x++) { _burn(TicketIDs[x], false); }
    }

    /**
     * @dev LiveMint Redeems Golden Token If Not Already Burned & Sends Minted Work To Owner's Wallet
     */
    function _LiveMintBurn(uint TokenID) external returns (address _Recipient, uint _ArtistID)
    {
        require(msg.sender == _LIVE_MINT, "MP: Sender Is Not Live Mint");
        address Recipient = IERC721(address(this)).ownerOf(TokenID);
        require(Recipient != address(0), "MP: Invalid Recipient");
        _burn(TokenID, false);
        return (Recipient, _ArtBlocksProjectID);
    }
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IMinter } from "./IMinter.sol";
import { IMP } from "./IMP.sol";
import { DelegateCashEnabled } from "./DelegateCashEnabled.sol";
contract Marketplace is Ownable, ReentrancyGuard, DelegateCashEnabled
{
    struct PresaleSale 
    {
        address _Operator;
        address _NFT;
        uint _MaxForSale;
        uint _MaxPerPurchase;
        uint _PricePresale;
        uint _PricePublic;
        uint _TimestampEndFullSet;
        uint _TimestampEndCitizen;
        uint _TimestampSaleStart;
    }

    struct InternalPresaleSale
    {
        bool _Active;
        uint _AmountSold;
        uint _GlobalPurchasesFullSet;
        uint _GlobalPurchasesCitizen;
        uint _GlobalPurchasesPublic;
        uint _CurrentTokenIndex;
        uint _AmountSoldFullSet;
        uint _AmountSoldCitizen;
        uint _AmountSoldPublic;
    }

    struct InternalPresaleSaleRoots
    {
        bytes32 _RootEligibilityFullSet;
        bytes32 _RootEligibilityCitizen;
        bytes32 _RootAmountFullSet;
        bytes32 _RootAmountCitizen;
    }

    struct InternalWalletInfo    
    {
        uint _AmountPurchasedFullSetWindow;
        uint _AmountPurchasedCitizenWindow;
        uint _AmountPurchasedWallet;
    }

    struct WalletSaleInfo
    {
        uint _PricePresale;
        uint _PricePublic;
        uint _AmountSold;
        uint _MintPassesAvailable;
        uint _MintPassesRemaining;
        uint _TimestampEndFullSet;
        uint _TimestampEndCitizen;
        uint _TimestampSaleStart;
        uint _AmountPurchasableFullSet;
        uint _AmountPurchasableCitizen;
        uint _AmountPurchasedFullSetWindow;
        uint _AmountPurchasedCitizenWindow;
        uint _GlobalPurchasesFullSet;
        uint _GlobalPurchasesCitizen;
        uint _GlobalPurchasesPublic;
        uint _AmountPurchasedWallet;
        bool _EligibleFullSet;
        bool _EligibleCitizen;
        bool _ValidMaxAmountFullSet;
        bool _ValidMaxAmountCitizen;
    }

    struct Sale
    {
        uint _Price;
        uint _MintPassProjectID;
        uint _Type;
        uint _ABProjectID;
        uint _AmountForSale;
        address _NFT;
        bytes32 _Root;
    }

    struct SaleInfo
    {
        uint _PricePresale;
        uint _PricePublic;
        uint _AmountSold;
        uint _MintPassesAvailable;
        uint _MintPassesRemaining;
        uint _TimestampEndFullSet;
        uint _TimestampEndCitizen;
        uint _TimestampSaleStart;
        uint _GlobalPurchasesFullSet;
        uint _GlobalPurchasesCitizen;
        uint _GlobalPurchasesPublic;
    }

    /*------------------
     * STATE VARIABLES *
    -------------------*/

    uint public _TOTAL_UNIQUE_SALES; // Total Unique Presale Sales                
    address private constant _BRT_MULTISIG = 0x0BC56e3c1397e4570069e89C07936A5c6020e3BE; // `sales.brightmoments.eth`
    
    /*-----------
     * MAPPINGS *
    ------------*/

    mapping(uint=>Sale) public FixedPriceSales;
    mapping(uint=>uint) public AmountSold;
    mapping(uint=>uint[]) public DiscountAmounts;
    mapping(address=>bool) public Admin;  
    mapping(uint=>PresaleSale) public PresaleSales;                           
    mapping(uint=>InternalPresaleSale) public PresaleSalesInternal;            
    mapping(uint=>InternalPresaleSaleRoots) public InternalRoots;              
    mapping(uint=>mapping(address=>InternalWalletInfo)) public InternalSaleWalletInfo;

    event PurchasedPresale(uint SaleIndex, address Purchaser, uint DesiredAmount, uint MessageValue, bool PresaleEnded);    
    event SaleStarted(uint SaleIndex);
    event Refunded(address Refundee, uint Amount);
    event Purchased(address Purchaser, uint Amount);
    event Fullset();
    event Citizen();
    event Public();

    constructor() 
    { 
        Admin[msg.sender] = true; 
        Admin[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = true;
    }

    /*---------------------
     * EXTERNAL FUNCTIONS *
    ----------------------*/

    /**
     * @dev Purchases Golden Token
     */
    function PurchasePresale (
        uint SaleIndex,                // Index Of Sale
        uint DesiredAmount,            // Desired Purchase Amount
        uint MaxAmount,                // Maximum Purchase Allocation Per Wallet
        address Vault,                 // Delegate.Cash Delegation Registry
        bytes32[] calldata Proof,      // MerkleProof For Eligibility
        bytes32[] calldata ProofAmount // MerkleProof For MaxAmount
    ) external payable nonReentrant {
        require(tx.origin == msg.sender, "Marketplace: EOA Only");
        require(block.timestamp >= PresaleSales[SaleIndex]._TimestampSaleStart, "Marketplace: Sale Not Started");
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(DelegateCash.checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } }
        InternalPresaleSale memory _InternalPresaleSale = PresaleSalesInternal[SaleIndex];
        PresaleSale memory _PresaleSale = PresaleSales[SaleIndex];
        bool PresaleEnded;
        uint _Price;
        uint _MaxPerPurchase = _PresaleSale._MaxPerPurchase;
        if(_InternalPresaleSale._AmountSold + DesiredAmount > _PresaleSale._MaxForSale) 
        { 
            DesiredAmount = _PresaleSale._MaxForSale - _InternalPresaleSale._AmountSold; // Partial Fill
        } 
        if(block.timestamp <= _PresaleSale._TimestampEndCitizen) // Presale
        {
            if(block.timestamp <= _PresaleSale._TimestampEndFullSet) // Full Set Window
            { 
                require( // Eligible For Full Set Window
                    VerifyBrightList(Recipient, InternalRoots[SaleIndex]._RootEligibilityFullSet, Proof), 
                    "Full Set Window: Not Eligible For Full Set Presale Window Or Block Pending, Please Try Again In A Few Seconds..."
                ); 
                require(VerifyAmount(Recipient, MaxAmount, InternalRoots[SaleIndex]._RootAmountFullSet, ProofAmount), "Invalid Full Set Amount Proof");
                require(InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedWallet + DesiredAmount <= MaxAmount, "All Full Set Allocation Used");
                InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedFullSetWindow += DesiredAmount;
                PresaleSalesInternal[SaleIndex]._GlobalPurchasesFullSet += DesiredAmount;
                emit Fullset();
            }
            else // Citizen Window
            { 
                require( // Eligible For Citizen Window
                    VerifyBrightList(Recipient, InternalRoots[SaleIndex]._RootEligibilityCitizen, Proof), 
                    "Citizen Window: Not Eligible For Presale Window Or Block Pending, Please Try Again In A Few Seconds..."
                ); 
                require(VerifyAmount(Recipient, MaxAmount, InternalRoots[SaleIndex]._RootAmountCitizen, ProofAmount), "Invalid Citizen Amount Proof");
                require(InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedCitizenWindow + DesiredAmount <= MaxAmount, "All Citizen Allocation Used");
                InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedWallet += DesiredAmount;
                PresaleSalesInternal[SaleIndex]._GlobalPurchasesCitizen += DesiredAmount;
                emit Citizen();
            } 
            _Price = _PresaleSale._PricePresale * DesiredAmount;
        }
        else // Public Sale
        { 
            _Price = _PresaleSale._PricePublic * DesiredAmount;
            PresaleSalesInternal[SaleIndex]._GlobalPurchasesPublic += DesiredAmount;
            PresaleEnded = true; 
            emit Public();
        }
        require(DesiredAmount <= _MaxPerPurchase, "Invalid Desired Purchase Amount. Must Be <= Max Purchase Limit"); // Purchase Limiter
        require(_InternalPresaleSale._AmountSold + DesiredAmount <= _PresaleSale._MaxForSale, "Sale Ended"); // Sale End State
        require(DesiredAmount > 0 && _Price > 0, "Sale Ended"); // Sale End State
        require(msg.value >= _Price, "Invalid ETH Amount"); // Ensures ETH Amount Sent Is Correct
        if(msg.value > _Price) { __Refund(msg.sender, msg.value - _Price); } // Refunds The Difference
        IMinter(_PresaleSale._NFT)._MintToFactory(0, msg.sender, DesiredAmount);
        PresaleSalesInternal[SaleIndex]._AmountSold += DesiredAmount;
        PresaleSalesInternal[SaleIndex]._CurrentTokenIndex += DesiredAmount;
        InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedWallet += DesiredAmount;
        emit PurchasedPresale(SaleIndex, Recipient, DesiredAmount, msg.value, PresaleEnded);
    }

    /**
     * @dev Purchases An `Amount` Of NFTs From A `SaleIndex`
     */
    function PurchaseFixedPrice(uint SaleIndex, uint Amount, bytes32[] calldata Proof) external payable nonReentrant
    {
        (bool Brightlist, uint Priority) = VerifyBrightList(SaleIndex, msg.sender, FixedPriceSales[SaleIndex]._Root, Proof);
        if(Brightlist) 
        {
            require(msg.value == ((FixedPriceSales[SaleIndex]._Price * DiscountAmounts[SaleIndex][Priority]) / 100), "Marketplace: Incorrect ETH Amount Sent");
        }
        else { require(msg.value == FixedPriceSales[SaleIndex]._Price * Amount, "Marketplace: Incorrect ETH Amount Sent"); }
        require(AmountSold[SaleIndex] + Amount <= FixedPriceSales[SaleIndex]._AmountForSale, "Marketplace: Not Enough NFTs Left For Sale");
        AmountSold[SaleIndex] = AmountSold[SaleIndex] + Amount;
        if(FixedPriceSales[SaleIndex]._Type == 0) { IMinter(FixedPriceSales[SaleIndex]._NFT)._MintToFactory(FixedPriceSales[SaleIndex]._MintPassProjectID, msg.sender, Amount); }
        else 
        { 
            uint ProjectID = FixedPriceSales[SaleIndex]._ABProjectID;
            for(uint x; x < Amount; x++) { IMinter(FixedPriceSales[SaleIndex]._NFT).purchaseTo(msg.sender, ProjectID); }
        } 
        emit Purchased(msg.sender, Amount);
    }

    /*------------------
     * ADMIN FUNCTIONS *
    -------------------*/

    /**
     * @dev Instantiates A New Presale Sale
     */
    function __StartPresaleSale(
        PresaleSale memory _Sale
    ) external onlyAdmin { 
        PresaleSales[_TOTAL_UNIQUE_SALES] = _Sale; 
        PresaleSalesInternal[_TOTAL_UNIQUE_SALES]._Active = true;
        emit SaleStarted(_TOTAL_UNIQUE_SALES);
        _TOTAL_UNIQUE_SALES++;
    }

    /**
     * @dev Changes Presale Times
     */
    function __ChangePresaleTimes(
        uint SaleIndex,
        uint TimestampSaleStart,
        uint TimestampFullSetEnd,
        uint TimestampCitizenEnd
    ) external onlyAdmin
    {
        PresaleSales[SaleIndex]._TimestampSaleStart = TimestampSaleStart;
        PresaleSales[SaleIndex]._TimestampEndFullSet = TimestampFullSetEnd;
        PresaleSales[SaleIndex]._TimestampEndCitizen = TimestampCitizenEnd;
    }

    /**
     * @dev Changes Presale Sale Max For Sale
     */
    function __ChangePresaleSaleMaxForSale(uint SaleIndex, uint MaxForSale) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._MaxForSale = MaxForSale; 
    }

    /**
     * @dev Change Presale Sale Max Per Purchase
     */
    function __ChangePresaleSaleMaxPerPurchase(uint SaleIndex, uint MaxPerPurchase) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._MaxPerPurchase = MaxPerPurchase; 
    }

    /**
     * @dev Changes Presale Sale Mint Pass Price
     */
    function __ChangePresaleSalePresalePrice(uint SaleIndex, uint Price) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._PricePresale = Price; 
    }

    /**
     * @dev Changes Presale Sale Public Price
     */
    function __ChangePresaleSalePublicPrice(uint SaleIndex, uint Price) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._PricePublic = Price; 
    }

    /**
     * @dev Changes Timestamp End Full Set
     */
    function __ChangePresaleSaleEndFullSet(uint SaleIndex, uint Timestamp) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._TimestampEndFullSet = Timestamp; 
    }

    /**
     * @dev Changes Timestamp End Citizen
     */
    function __ChangePresaleSaleEndCitizen(uint SaleIndex, uint Timestamp) external onlyAdmin
    {
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._TimestampEndCitizen = Timestamp; 
    }

    /**
     * @dev Changes Timestamp Sale Start
     */
    function __ChangePresaleSaleStart(uint SaleIndex, uint Timestamp) external onlyAdmin
    {
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._TimestampSaleStart = Timestamp; 
    }

    /**
     * @dev Changes Presale Sale Full Set Root
     */
    function __ChangePresaleSaleRootFullSet(uint SaleIndex, bytes32 RootFullSet) external onlyAdmin 
    { 
        InternalRoots[SaleIndex]._RootEligibilityFullSet = RootFullSet; 
    }

    /**
     * @dev Changes Presale Sale Citizen Root
     */
    function __ChangePresaleSaleRootCitizen(uint SaleIndex, bytes32 RootCitizen) external onlyAdmin
    {
        InternalRoots[SaleIndex]._RootAmountCitizen = RootCitizen; 
    }

    /**
     * @dev Changes All Presale Roots
     */
    function __ChangePresaleAllRoots(
        uint SaleIndex,
        bytes32 RootEligibilityFullSet,
        bytes32 RootAmountsFullSet,
        bytes32 RootEligibilityCitizen,
        bytes32 RootAmountsCitizen
    ) external onlyAdmin { 
        InternalRoots[SaleIndex]._RootEligibilityFullSet = RootEligibilityFullSet;
        InternalRoots[SaleIndex]._RootEligibilityCitizen = RootEligibilityCitizen;
        InternalRoots[SaleIndex]._RootAmountFullSet = RootAmountsFullSet;
        InternalRoots[SaleIndex]._RootAmountCitizen = RootAmountsCitizen;
    }

    /*--------------*/
    /*  ONLY OWNER  */
    /*--------------*/

    /**
     * @dev Initializes A Sale Via A Struct
     */
    function __StartFixedPriceSale(uint SaleIndex, Sale memory _Sale) external onlyOwner { FixedPriceSales[SaleIndex] = _Sale; }

    /**
     * @dev Initializes A Sale Via Parameters
     */
    function __StartFixedPriceSale(
        uint SaleIndex, 
        uint Price, 
        uint MintPassProjectID, 
        uint Type, 
        uint ABProjectID, 
        uint AmountForSale, 
        address NFT, 
        bytes32 Root
    ) external onlyOwner { FixedPriceSales[SaleIndex] = Sale(Price, MintPassProjectID, Type, ABProjectID, AmountForSale, NFT, Root); }

    /**
     * @dev Changes The NFT Address Of A Sale
     */
    function __ChangeFixedPriceNFTAddress(uint SaleIndex, address NewAddress) external onlyOwner { FixedPriceSales[SaleIndex]._NFT = NewAddress; }

    /**
     * @dev Changes The Price Of A Sale
     */
    function __ChangeFixedPrice(uint SaleIndex, uint Price) external onlyOwner { FixedPriceSales[SaleIndex]._Price = Price; }

    /**
     * @dev Changes The MintPass ProjectID
     */
    function __ChangeFixedPriceMintPassProjectID(uint SaleIndex, uint MintPassProjectID) external onlyOwner 
    { 
        FixedPriceSales[SaleIndex]._MintPassProjectID = MintPassProjectID; 
    }

    /**
     * @dev Changes The ArtBlocks ProjectID
     */
    function __ChangeFixedPriceABProjectID(uint SaleIndex, uint ABProjectID) external onlyOwner { FixedPriceSales[SaleIndex]._ABProjectID = ABProjectID; }

    /**
     * @dev Changes The Amount Of NFTs For Sale
     */
    function __ChangeFixedPriceAmountForSale(uint SaleIndex, uint AmountForSale) external onlyOwner { FixedPriceSales[SaleIndex]._AmountForSale = AmountForSale; }

    /**
     * @dev Changes The Type Of A Sale
     */
    function __ChangeFixedPriceType(uint SaleIndex, uint Type) external onlyOwner { FixedPriceSales[SaleIndex]._Type = Type; }

    /**
     * @dev onlyOwner: Grants Admin Role
     */
    function ___AdminGrant(address _Admin) external onlyOwner { Admin[_Admin] = true; }

    /**
     * @dev onlyOwner: Removes Admin Role
     */
    function ___AdminRemove(address _Admin) external onlyOwner { Admin[_Admin] = false; }

    /**
     * @dev onlyOwner: Withdraws All Ether From The Contract
     */
    function ___WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev onlyOwner: Withdraws Ether From Contract To Address With An Amount
     */
    function ___WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /**
     * @dev Withdraws ETH To Multisig
     */
    function ___WithdrawETHToMultisig() external onlyOwner 
    {
        (bool success,) = _BRT_MULTISIG.call { value: address(this).balance }(""); 
        require(success, "Marketplace: ETH Withdraw Failed"); 
    }

    /**
     * @dev Withdraws ERC721s From Contract
     */
    function ___WithdrawERC721(address Contract, address Recipient, uint[] calldata TokenIDs) external onlyOwner 
    { 
        for(uint TokenID; TokenID < TokenIDs.length;)
        {
            IERC721(Contract).transferFrom(address(this), Recipient, TokenIDs[TokenID]);
            unchecked { TokenID++; }
        }
    }

    /*-----------------
     * VIEW FUNCTIONS *
    ------------------*/

    /**
     * @dev Verifies Brightlist For Presale
     */
    function VerifyBrightList(address _Wallet, bytes32 _Root, bytes32[] calldata _Proof) public pure returns(bool)
    {
        bytes32 _Leaf = keccak256(abi.encodePacked(_Wallet));
        return MerkleProof.verify(_Proof, _Root, _Leaf);
    }

    /**
     * @dev Verifies Brightlist For Presale Fixed Price Sale
     */
    function VerifyBrightList(uint SaleIndex, address _Wallet, bytes32 _Root, bytes32[] calldata _Proof) public view returns (bool, uint)
    {
        bytes32 _Leaf = keccak256(abi.encodePacked(_Wallet));
        for(uint x; x < DiscountAmounts[SaleIndex].length; x++) { if(MerkleProof.verify(_Proof, _Root, _Leaf)) { return (true, x); } }
        return (false, 69420);
    }

    /**
     * @dev Verifies Maximum Purchase Amount Being Passed Is Valid
     */
    function VerifyAmount(address _Wallet, uint _Amount, bytes32 _Root, bytes32[] calldata _Proof) public pure returns(bool)
    {
        bytes32 _Leaf = (keccak256(abi.encodePacked(_Wallet, _Amount)));
        return MerkleProof.verify(_Proof, _Root, _Leaf);
    }

    /**
     * @dev Refunds `Recipient` ETH Amount `Value`
     */
    function __Refund(address Recipient, uint Value) internal
    {
        (bool Confirmed,) = Recipient.call{value: Value}(""); 
        require(Confirmed, "DutchMarketplace: Refund failed");
        emit Refunded(Recipient, Value);
    }

    /**
     * @dev Returns Sale Information
     */
    function SaleInformation(uint SaleIndex) public view returns (SaleInfo memory) {
        PresaleSale memory _Sale = PresaleSales[SaleIndex];
        InternalPresaleSale memory _SaleInternal = PresaleSalesInternal[SaleIndex];
        uint AmountRemaining = _Sale._MaxForSale - PresaleSalesInternal[SaleIndex]._AmountSold;
        return SaleInfo(
            _Sale._PricePresale,
            _Sale._PricePublic,
            _SaleInternal._AmountSold,
            _Sale._MaxForSale,
            AmountRemaining,
            _Sale._TimestampEndFullSet,
            _Sale._TimestampEndCitizen,
            _Sale._TimestampSaleStart,
            _SaleInternal._GlobalPurchasesFullSet,
            _SaleInternal._GlobalPurchasesCitizen,
            _SaleInternal._GlobalPurchasesPublic
        );
    }

    /**
     * @dev Returns A Wallet's Sale Information
     */
    function WalletSaleInformation(
        uint SaleIndex,
        address Wallet,
        uint MaxAmountFullSet,
        uint MaxAmountCitizen,
        bytes32[] calldata FullsetProof, 
        bytes32[] calldata CitizenProof,
        bytes32[] calldata ProofAmountFullSet,
        bytes32[] calldata ProofAmountCitizen
    ) public view returns (WalletSaleInfo memory) {
        PresaleSale memory _Sale = PresaleSales[SaleIndex];
        InternalPresaleSale memory _SaleInternal = PresaleSalesInternal[SaleIndex];
        InternalWalletInfo memory _WalletInfo = InternalSaleWalletInfo[SaleIndex][Wallet];
        return WalletSaleInfo(
            _Sale._PricePresale,
            _Sale._PricePublic,
            _SaleInternal._AmountSold,
            _Sale._MaxForSale,
            _Sale._MaxForSale - _SaleInternal._AmountSold,
            _Sale._TimestampEndFullSet,
            _Sale._TimestampEndCitizen,
            _Sale._TimestampSaleStart,
            MaxAmountFullSet - _WalletInfo._AmountPurchasedFullSetWindow,
            MaxAmountCitizen - _WalletInfo._AmountPurchasedCitizenWindow,
            _WalletInfo._AmountPurchasedFullSetWindow,
            _WalletInfo._AmountPurchasedCitizenWindow,
            _SaleInternal._GlobalPurchasesFullSet,
            _SaleInternal._GlobalPurchasesCitizen,
            _SaleInternal._GlobalPurchasesPublic,
            _WalletInfo._AmountPurchasedWallet,
            VerifyBrightList(Wallet, InternalRoots[SaleIndex]._RootEligibilityFullSet, FullsetProof),
            VerifyBrightList(Wallet, InternalRoots[SaleIndex]._RootEligibilityCitizen, CitizenProof),
            VerifyAmount(Wallet, MaxAmountFullSet, InternalRoots[SaleIndex]._RootAmountFullSet, ProofAmountFullSet),
            VerifyAmount(Wallet, MaxAmountCitizen, InternalRoots[SaleIndex]._RootAmountCitizen, ProofAmountCitizen)
        );
    }

    /*-----------
     * MODIFIER *
    ------------*/

    modifier onlyAdmin
    {
        require(Admin[msg.sender]);
        _;
    }
}

interface IERC20 { function approve(address From, address To, uint Amount) external; }
interface IERC721 { function transferFrom(address From, address To, uint TokenID) external; }
//SPDX-License-Identifier: MIT
/**
 * @title MarketplaceEnabled
 * @dev @brougkr
 * note: This Contract Is Used To Enable DutchMarketplace To Purchase Tokens From Your Contract
 * note: This Contract Should Be Imported and Included In The `is` Portion Of The Contract Declaration, ex. `contract NFT is Ownable, MarketplaceEnabled`
 * note: You Can Copy Or Modify The Example Functions Below To Implement The Two Functions In Your Contract Required By MarketplaceEnabled
 */
pragma solidity 0.8.19;
abstract contract MarketplaceEnabled
{
    /**
     * @dev Marketplace Mint
     * note: Should Be Implemented With onlyMarketplace Access Modifier
     * note: Should Return The TokenID Being Transferred To The Recipient
     */
    function _MintToFactory(uint ProjectID, address Recipient, uint Amount) external virtual;
    // EXAMPLE:
    // function _MintToFactory(uint ProjectID, address Recipient, uint Amount) override virtual external onlyMarketplace
    // {
    //     require(totalSupply() + Amount <= 100, "MP: Max Supply Reached");
    //     _mint(Recipient, Amount); 
    // }

    /**
     * @dev ChangeMarketplaceAddress Changes The Marketplace Address | note: Should Be Implemented To Include onlyOwner Or Similar Access Modifier
     */
    function __ChangeMarketplaceAddress(address NewAddress) external virtual;
    // EXAMPLE: 
    // function __ChangeMarketplaceAddress(address NewAddress) override virtual external onlyOwner { _MARKETPLACE = NewAddress; }

    /**
     * @dev Marketplace Address
     */
    address public _MARKETPLACE_ADDRESS = 0x3725a379F90BeB320101453A0C75196C40749571; // GOERLI
    // address _MARKETPLACE_ADDRESS = 0x295f593B7A162B68b4353444cA622209492bCA2E; // MAINNET

    /**
     * @dev Access Modifier For Marketplace
     */
    modifier onlyMarketplace
    {
        require(msg.sender == _MARKETPLACE_ADDRESS, "onlyMarketplace: `msg.sender` Is Not The Marketplace Contract");
        _;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import { DefaultOperatorFilterer } from "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import { ERC721MPF } from "./ERC721MPF.sol";
import { ILaunchpad , ILaunchpadRegistry } from "./ILaunchpad.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LaunchpadEnabled } from "./LaunchpadEnabled.sol";
import { IOS } from "./IOS.sol";
contract MintPassFactory is Ownable, ERC721MPF, DefaultOperatorFilterer, LaunchpadEnabled, IOS
{
    struct MintPass
    {
        uint _MaxSupply;          // _MaxSupply
        uint _MintPacks;          // _MintPacks
        uint _ArtistIDs;          // _ArtistIDs
        uint _ArtBlocksProjectID; // _ArtBlocksProjectID note: For Cases Where Mint Pass ProjectID 1:1 With ProjectIDs
        uint _ReserveAmount;      // _Reserve
        string _MetadataURI;      // _MetadataURI
    }

    uint public _TotalUniqueProjects;  // Total Projects Invoked
    address public _Multisig; // test
    uint private constant _ONE_MILLY = 1000000;
    uint private constant _DEFAULT = type(uint).max; // max integer

    mapping(uint=>MintPass) public MintPasses;
    mapping(uint=>uint) public ArtistIDs;
    mapping(address=>bool) public Authorized;
    mapping(uint=>uint[]) public MintPackIndexes;
    
    event MintPassProjectCreated(uint MintPassProjectID);
    event AuthorizedContract(address ContractAddress);
    event DeauthorizedContract(address ContractAddress);

    /**
     * @dev Mint Pass Factory Constructor
     */
    constructor() ERC721MPF("Bright Moments Mint Pass | MPBRT", "MPBRT") 
    { 
        Authorized[msg.sender] = true; 
        _Multisig = msg.sender;
    }

    /**
     * @dev Returns All Mint Pack Indexes
     */
    function ReadMintPackIndexes(uint MintPassProjectID) public view returns (uint[] memory) { return MintPackIndexes[MintPassProjectID]; }

    /**
     * @dev Direct Mint Function
     */
    function _MintToFactory(uint MintPassProjectID, address Recipient, uint Amount) external onlyAuthorized
    {
        require(_Active[MintPassProjectID], "MintPassFactory: ProjectID: `MintPassProjectID` Is Not Active");
        _mint(MintPassProjectID, Recipient, Amount);
    }

    /**
     * @dev Direct Mint To Factory Pack
     */
    function _MintToFactoryPack(uint MintPassProjectID, address Recipient, uint Amount) external onlyAuthorized
    {
        require(_Active[MintPassProjectID], "MintPassFactory: ProjectID: `MintPassProjectID` Is Not Active");
        uint NumArtists = MintPasses[MintPassProjectID]._ArtistIDs;
        uint NumToMint = NumArtists * Amount;
        uint StartingTokenID = ReadProjectInvocations(MintPassProjectID);
        _mint(MintPassProjectID, Recipient, NumToMint);
        for(uint x; x < Amount; x++) { MintPackIndexes[MintPassProjectID].push(StartingTokenID + (NumArtists * x)); }
    }

    /**
     * @dev LiveMint Redeems Mint Pass If Not Already Burned & Sends Minted Work To Owner's Wallet
     */
    function _LiveMintBurn(uint TokenID) external onlyAuthorized returns (address _Recipient, uint _ArtistID)
    {
        address Recipient = IERC721(address(this)).ownerOf(TokenID);
        require(Recipient != address(0), "MPMX: Invalid Recipient");
        _burn(TokenID, false);
        uint MintPassProjectID = TokenID % _ONE_MILLY;
        if(MintPasses[MintPassProjectID]._ArtBlocksProjectID == _DEFAULT) { return (Recipient, ArtistIDs[TokenID]); }
        else { return (Recipient, MintPasses[MintPassProjectID]._ArtBlocksProjectID); }
    }

    /**
     * @dev Initializes A New Mint Pass
     */
    function __InitMintPass(MintPass memory _MintPass) external onlyAuthorized returns (uint MintPassProjectID)
    {   
        _Active[_TotalUniqueProjects] = true;
        require(_MintPass._ArtistIDs * _MintPass._MintPacks <= _MintPass._MaxSupply, "MintPassFactory: Invalid Mint Pass Parameters");
        _MaxSupply[_TotalUniqueProjects] = _MintPass._MaxSupply; // Internal Max Supply
        MintPasses[_TotalUniqueProjects] = _MintPass;            // Struct Assignment
        MintPasses[_TotalUniqueProjects]._MetadataURI = _MintPass._MetadataURI;
        if(_MintPass._ReserveAmount > 0)
        { 
            _mint(
                _TotalUniqueProjects,    // MintPassProjectID
                _Multisig,               // Multisig
                _MintPass._ReserveAmount // Reserve Amount
            );
        }
        emit MintPassProjectCreated(_TotalUniqueProjects);
        _TotalUniqueProjects++;
        return (_TotalUniqueProjects - 1);
    }

    /**
     * @dev Updates The BaseURI For A Project
     */
    function __NewBaseURI(uint MintPassProjectID, string memory NewURI) external onlyAuthorized 
    { 
        require(_Active[MintPassProjectID], "MintPassFactory: Mint Pass Is Not Active");
        MintPasses[MintPassProjectID]._MetadataURI = NewURI; 
    }

    /**
     * @dev Overrides The Operator Filter Active State
     */
    function __ChangeOperatorFilterState(bool State) external override onlyOwner { OPERATOR_FILTER_ENABLED = State; }

    /**
     * @dev Overrides The Launchpad Registry Address
     */
    function __NewLaunchpadAddress(address NewAddress) external onlyAuthorized { _LAUNCHPAD = NewAddress; }

    /**
     * @dev Authorizes A Contract To Mint
     */
    function ____AuthorizeContract(address NewAddress) external onlyOwner 
    { 
        Authorized[NewAddress] = true; 
        emit AuthorizedContract(NewAddress);
    }

    /**
     * @dev Deauthorizes A Contract From Minting
     */
    function ___DeauthorizeContract(address NewAddress) external onlyOwner 
    { 
        Authorized[NewAddress] = false; 
        emit DeauthorizedContract(NewAddress);
    }

    /**
     * @dev Overrides The Active State For A MintPassProjectID
     */
    function ____OverrideActiveState(uint MintPassProjectID, bool State) external onlyOwner { _Active[MintPassProjectID] = State; }

    /**
     * @dev Overrides The Max Supply For A MintPassProjectID
     */
    function ____OverrideMaxSupply(uint MintPassProjectID, uint NewMaxSupply) external onlyOwner 
    { 
        _MaxSupply[MintPassProjectID] = NewMaxSupply; 
        MintPasses[MintPassProjectID]._MaxSupply = NewMaxSupply;
    }

    /**
     * @dev Owner Burn Function
     */
    function ____OverrideBurn(uint[] calldata TokenIDs) external onlyOwner
    {
        for(uint x; x < TokenIDs.length; x++) { _burn(TokenIDs[x], false); }
    }

    /**
     * @dev Mints To Owner
     */
    function ___OverrideMint(uint MintPassProjectID, uint Amount) external onlyOwner
    {
        require(_Active[MintPassProjectID], "MintPassFactory: Mint Pass Is Not Active");
        _mint(MintPassProjectID, msg.sender, Amount);
    }

    /**
     * @dev Returns A MintPassProjectID From A TokenID
     */
    function ViewProjectID(uint TokenID) public pure returns (uint) { return (TokenID - (TokenID % 1000000)) / 1000000; }

    /**
     * @dev Returns Base URI Of Desired TokenID
     */
    function _baseURI(uint TokenID) internal view virtual override returns (string memory) 
    { 
        uint MintPassProjectID = ViewProjectID(TokenID);
        return MintPasses[MintPassProjectID]._MetadataURI;
        // return ILaunchpadRegistry(ILaunchpad(_LAUNCHPAD).ViewAddressLaunchpadRegistry()).ViewBaseURIMintPass(MintPassProjectID);
    }

    /*---------------------
     * OVERRIDE FUNCTIONS *
    ----------------------*/

    function setApprovalForAll(
        address operator, 
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) { super.setApprovalForAll(operator, approved); }

    function approve(
        address operator, 
        uint256 tokenId
    ) public override onlyAllowedOperatorApproval(operator) { super.approve(operator, tokenId); }

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override onlyAllowedOperator(from) { super.transferFrom(from, to, tokenId); }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override onlyAllowedOperator(from) { super.safeTransferFrom(from, to, tokenId); }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) public override onlyAllowedOperator(from) { super.safeTransferFrom(from, to, tokenId, data); }

    /**
     * @dev Access Modifier For External Smart Contracts
     * note: This Is A Custom Access Modifier That Is Used To Restrict Access To Only Authorized Contracts
     */
    modifier onlyAuthorized()
    {
        if(msg.sender != owner()) 
        { 
            require(Authorized[msg.sender], "MintPassFactory: Sender Is Not Authorized Contract"); 
        }
        _;
    }
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
contract RandomCollectorSelector is Ownable, VRFV2WrapperConsumerBase
{    
    struct RequestStatus 
    {
        uint paid;   // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint[] randomWords; // random results
    }

    struct RCSParams
    {
        string Name;
        string IPFSHash;
        uint NumWinners;
        uint SnapshotEntries;
    }

    mapping(uint => RCSParams) public RCSInfo;
    mapping(address => bool) public Admin;            // [Wallet] -> Is Admin
    mapping(uint => RequestStatus) public s_requests; // [RequestID] => `requestStatus`
    uint[] public _RandomResults;                                                 
    uint[] public requestIds;               // Array of request IDs
    uint32 public numWords = 1;             // Number of random words to request from Chainlink VRF
    uint16 public requestConfirmations = 1; // Number of confirmations to wait for before updating the request status
    uint public lastRequestId;              // Last request ID
    bool public _VRF;                       // VRF Status
    bool public _VRFResponseStatus;         // VRF Response Status
    uint public _CurrentRCSIndex;           // Current RCS Index

    event RCSComplete(string _Name, uint _CurrentRCSIndex, uint _NumWinners, uint _SnapshotEntries, string _IPFSHash);
    event RequestSent(uint requestId, uint32 numWords);
    event RequestFulfilled(uint requestId, uint[] randomWords, uint payment);
    event Winners(uint VRFRandomness, uint[] WinningIndexes);

    constructor() VRFV2WrapperConsumerBase(0x5947BB275c521040051D82396192181b413227A3, 0x721DFbc5Cfe53d32ab00A9bdFa605d3b8E1f3f42)
    {
        Admin[msg.sender] = true; // deployer.brightmoments.eth
        Admin[0xB96E81f80b3AEEf65CB6d0E280b15FD5DBE71937] = true; // brightmoments.eth
        Admin[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = true; // operator.brightmoments.eth
        Admin[0x18B7511938FBe2EE08ADf3d4A24edB00A5C9B783] = true; // phil.brightmoments.eth
        Admin[0x91594b5E5d74FCCB3f71674eE74C5F4D44f333D5] = true; // gitpancake.brightmoments.eth
        Admin[0x65d674F2220Fa844c1e390AAf6739eC07519146E] = true; // irina.brightmoments.eth
    } 

    /*-----------------
     * VIEW FUNCTIONS *
    ------------------*/

    /**
     * @dev Step 1: Request Random Number From Chainlink VRF
     */
    function VRFRandomSeed(uint32 CallbackGasLimit) external onlyAdmin returns (uint256 requestId)
    {
        require(!_VRF, "Please Run RCS After This Function");
        _VRF = true;
        requestId = requestRandomness(
            CallbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(CallbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    /**
     * @dev Step 2: Emits Chainlink VRF Random Winners
     */
    function RCS(
        string memory _Name,
        string memory _IPFSHash, 
        uint _NumWinners, 
        uint _SnapshotEntries
    ) external onlyAdmin {
        require(_VRFResponseStatus, "Must Wait Until VRF Random Seed Has Been Returned"); 
        RCSInfo[_CurrentRCSIndex] = RCSParams({
            Name: _Name,
            IPFSHash: _IPFSHash,
            NumWinners: _NumWinners,
            SnapshotEntries: _SnapshotEntries
        });
        generateWinners(_NumWinners, _CurrentRCSIndex, _SnapshotEntries);
        _CurrentRCSIndex++;
        _VRFResponseStatus = false;
        _VRF = false;
        emit RCSComplete(_Name, _CurrentRCSIndex, _NumWinners, _SnapshotEntries, _IPFSHash);
    }

    /*----------------
     * VRF FUNCTIONS *
    -----------------*/
    event Value(uint);
    /**
     * @dev Generates Winners From VRF Random Seed
     */
    function generateWinners(uint numWinners, uint drawId, uint snapshotEntries) private
    {
        uint[] memory WinningIndexes = new uint[](numWinners);
        for(uint x; x < numWinners; x++) 
        {
            WinningIndexes[x] = (uint(keccak256(abi.encode(_RandomResults[drawId], x))) % snapshotEntries) + 1;
        }
        emit Winners(_RandomResults[drawId], WinningIndexes);
    }

    /**
     * @dev Withdraws ERC20 From Contract
     */
    function __WithdrawERC20(address ERC20) external onlyOwner
    {
        IERC20 token = IERC20(ERC20);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    /**
     * @dev VRF Callback Function
     */
    function fulfillRandomWords(uint _requestId, uint[] memory _randomWords) internal override 
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        _VRFResponseStatus = true;
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        _RandomResults.push(_randomWords[0]);
        emit RequestFulfilled(_requestId, _randomWords, s_requests[_requestId].paid);
    }

    modifier onlyAdmin
    {
        require(Admin[msg.sender], "onlyAdmin: Message Sender Is Not BRT Admin");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {OperatorFilterer} from "./OperatorFilterer.sol";
import {CANONICAL_CORI_SUBSCRIPTION} from "./lib/Constants.sol";
/**
 * @title  DefaultOperatorFilterer
 * @notice Inherits from OperatorFilterer and automatically subscribes to the default OpenSea subscription.
 * @dev    Please note that if your token contract does not provide an owner with EIP-173, it must provide
 *         administration methods on the contract itself to interact with the registry otherwise the subscription
 *         will be locked to the options set during construction.
 */

abstract contract DefaultOperatorFilterer is OperatorFilterer {
    /// @dev The constructor that is called when the contract is being deployed.
    constructor() OperatorFilterer(CANONICAL_CORI_SUBSCRIPTION, true) {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IOperatorFilterRegistry {
    /**
     * @notice Returns true if operator is not filtered for a given token, either by address or codeHash. Also returns
     *         true if supplied registrant address is not registered.
     */
    function isOperatorAllowed(address registrant, address operator) external view returns (bool);

    /**
     * @notice Registers an address with the registry. May be called by address itself or by EIP-173 owner.
     */
    function register(address registrant) external;

    /**
     * @notice Registers an address with the registry and "subscribes" to another address's filtered operators and codeHashes.
     */
    function registerAndSubscribe(address registrant, address subscription) external;

    /**
     * @notice Registers an address with the registry and copies the filtered operators and codeHashes from another
     *         address without subscribing.
     */
    function registerAndCopyEntries(address registrant, address registrantToCopy) external;

    /**
     * @notice Unregisters an address with the registry and removes its subscription. May be called by address itself or by EIP-173 owner.
     *         Note that this does not remove any filtered addresses or codeHashes.
     *         Also note that any subscriptions to this registrant will still be active and follow the existing filtered addresses and codehashes.
     */
    function unregister(address addr) external;

    /**
     * @notice Update an operator address for a registered address - when filtered is true, the operator is filtered.
     */
    function updateOperator(address registrant, address operator, bool filtered) external;

    /**
     * @notice Update multiple operators for a registered address - when filtered is true, the operators will be filtered. Reverts on duplicates.
     */
    function updateOperators(address registrant, address[] calldata operators, bool filtered) external;

    /**
     * @notice Update a codeHash for a registered address - when filtered is true, the codeHash is filtered.
     */
    function updateCodeHash(address registrant, bytes32 codehash, bool filtered) external;

    /**
     * @notice Update multiple codeHashes for a registered address - when filtered is true, the codeHashes will be filtered. Reverts on duplicates.
     */
    function updateCodeHashes(address registrant, bytes32[] calldata codeHashes, bool filtered) external;

    /**
     * @notice Subscribe an address to another registrant's filtered operators and codeHashes. Will remove previous
     *         subscription if present.
     *         Note that accounts with subscriptions may go on to subscribe to other accounts - in this case,
     *         subscriptions will not be forwarded. Instead the former subscription's existing entries will still be
     *         used.
     */
    function subscribe(address registrant, address registrantToSubscribe) external;

    /**
     * @notice Unsubscribe an address from its current subscribed registrant, and optionally copy its filtered operators and codeHashes.
     */
    function unsubscribe(address registrant, bool copyExistingEntries) external;

    /**
     * @notice Get the subscription address of a given registrant, if any.
     */
    function subscriptionOf(address addr) external returns (address registrant);

    /**
     * @notice Get the set of addresses subscribed to a given registrant.
     *         Note that order is not guaranteed as updates are made.
     */
    function subscribers(address registrant) external returns (address[] memory);

    /**
     * @notice Get the subscriber at a given index in the set of addresses subscribed to a given registrant.
     *         Note that order is not guaranteed as updates are made.
     */
    function subscriberAt(address registrant, uint256 index) external returns (address);

    /**
     * @notice Copy filtered operators and codeHashes from a different registrantToCopy to addr.
     */
    function copyEntriesOf(address registrant, address registrantToCopy) external;

    /**
     * @notice Returns true if operator is filtered by a given address or its subscription.
     */
    function isOperatorFiltered(address registrant, address operator) external returns (bool);

    /**
     * @notice Returns true if the hash of an address's code is filtered by a given address or its subscription.
     */
    function isCodeHashOfFiltered(address registrant, address operatorWithCode) external returns (bool);

    /**
     * @notice Returns true if a codeHash is filtered by a given address or its subscription.
     */
    function isCodeHashFiltered(address registrant, bytes32 codeHash) external returns (bool);

    /**
     * @notice Returns a list of filtered operators for a given address or its subscription.
     */
    function filteredOperators(address addr) external returns (address[] memory);

    /**
     * @notice Returns the set of filtered codeHashes for a given address or its subscription.
     *         Note that order is not guaranteed as updates are made.
     */
    function filteredCodeHashes(address addr) external returns (bytes32[] memory);

    /**
     * @notice Returns the filtered operator at the given index of the set of filtered operators for a given address or
     *         its subscription.
     *         Note that order is not guaranteed as updates are made.
     */
    function filteredOperatorAt(address registrant, uint256 index) external returns (address);

    /**
     * @notice Returns the filtered codeHash at the given index of the list of filtered codeHashes for a given address or
     *         its subscription.
     *         Note that order is not guaranteed as updates are made.
     */
    function filteredCodeHashAt(address registrant, uint256 index) external returns (bytes32);

    /**
     * @notice Returns true if an address has registered
     */
    function isRegistered(address addr) external returns (bool);

    /**
     * @dev Convenience method to compute the code hash of an arbitrary contract
     */
    function codeHashOf(address addr) external returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOperatorFilterRegistry} from "./IOperatorFilterRegistry.sol";
import {CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS} from "./lib/Constants.sol";
/**
 * @title  OperatorFilterer
 * @notice Abstract contract whose constructor automatically registers and optionally subscribes to or copies another
 *         registrant's entries in the OperatorFilterRegistry.
 * @dev    This smart contract is meant to be inherited by token contracts so they can use the following:
 *         - `onlyAllowedOperator` modifier for `transferFrom` and `safeTransferFrom` methods.
 *         - `onlyAllowedOperatorApproval` modifier for `approve` and `setApprovalForAll` methods.
 *         Please note that if your token contract does not provide an owner with EIP-173, it must provide
 *         administration methods on the contract itself to interact with the registry otherwise the subscription
 *         will be locked to the options set during construction.
 */

abstract contract OperatorFilterer {
    /// @dev Emitted when an operator is not allowed.
    error OperatorNotAllowed(address operator);

    IOperatorFilterRegistry public constant OPERATOR_FILTER_REGISTRY =
        IOperatorFilterRegistry(CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS);

    /// @dev The constructor that is called when the contract is being deployed.
    constructor(address subscriptionOrRegistrantToCopy, bool subscribe) {
        // If an inheriting token contract is deployed to a network without the registry deployed, the modifier
        // will not revert, but the contract will need to be registered with the registry once it is deployed in
        // order for the modifier to filter addresses.
        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {
            if (subscribe) {
                OPERATOR_FILTER_REGISTRY.registerAndSubscribe(address(this), subscriptionOrRegistrantToCopy);
            } else {
                if (subscriptionOrRegistrantToCopy != address(0)) {
                    OPERATOR_FILTER_REGISTRY.registerAndCopyEntries(address(this), subscriptionOrRegistrantToCopy);
                } else {
                    OPERATOR_FILTER_REGISTRY.register(address(this));
                }
            }
        }
    }

    /**
     * @dev A helper function to check if an operator is allowed.
     */
    modifier onlyAllowedOperator(address from) virtual {
        // Allow spending tokens from addresses with balance
        // Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred
        // from an EOA.
        if (from != msg.sender) {
            _checkFilterOperator(msg.sender);
        }
        _;
    }

    /**
     * @dev A helper function to check if an operator approval is allowed.
     */
    modifier onlyAllowedOperatorApproval(address operator) virtual {
        _checkFilterOperator(operator);
        _;
    }

    /**
     * @dev A helper function to check if an operator is allowed.
     */
    function _checkFilterOperator(address operator) internal view virtual {
        // Check registry code length to facilitate testing in environments without a deployed registry.
        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {
            // under normal circumstances, this function will revert rather than return false, but inheriting contracts
            // may specify their own OperatorFilterRegistry implementations, which may behave differently
            if (!OPERATOR_FILTER_REGISTRY.isOperatorAllowed(address(this), operator)) {
                revert OperatorNotAllowed(operator);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;
address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;