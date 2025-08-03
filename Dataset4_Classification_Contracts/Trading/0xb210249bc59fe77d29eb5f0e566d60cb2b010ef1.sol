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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @notice implements calculation of address for contracts deployed through CREATE.
/// Accepts contract deployed from which address & nonce
library AddressCalcs {

    /// @notice                         Computes the address of a contract based
    /// @param deployedFrom_            Address from which the contract was deployed
    /// @param nonce_                   Nonce at which the contract was deployed
    /// @return contract_               Address of deployed contract
    function addressCalc(address deployedFrom_, uint nonce_) internal pure returns (address contract_) {
        // @dev based on https://ethereum.stackexchange.com/a/61413

        // nonce of smart contract always starts with 1. so, with nonce 0 there won't be any deployment
        // hence, nonce of vault deployment starts with 1.
        bytes memory data;
        if (nonce_ == 0x00) {
            return address(0);
        } else if (nonce_ <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployedFrom_, uint8(nonce_));
        } else if (nonce_ <= 0xff) {
            data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), deployedFrom_, bytes1(0x81), uint8(nonce_));
        } else if (nonce_ <= 0xffff) {
            data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), deployedFrom_, bytes1(0x82), uint16(nonce_));
        } else if (nonce_ <= 0xffffff) {
            data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), deployedFrom_, bytes1(0x83), uint24(nonce_));
        } else {
            data = abi.encodePacked(bytes1(0xda), bytes1(0x94), deployedFrom_, bytes1(0x84), uint32(nonce_));
        }

        return address(uint160(uint256(keccak256(data))));
    }

}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @title library that represents a number in BigNumber(coefficient and exponent) format to store in smaller bits.
/// @notice the number is divided into two parts: a coefficient and an exponent. This comes at a cost of losing some precision
/// at the end of the number because the exponent simply fills it with zeroes. This precision is oftentimes negligible and can
/// result in significant gas cost reduction due to storage space reduction.
/// Also note, a valid big number is as follows: if the exponent is > 0, then coefficient last bits should be occupied to have max precision.
/// @dev roundUp is more like a increase 1, which happens everytime for the same number.
/// roundDown simply sets trailing digits after coefficientSize to zero (floor), only once for the same number.
library BigMathMinified {
    /// @dev constants to use for `roundUp` input param to increase readability
    bool internal constant ROUND_DOWN = false;
    bool internal constant ROUND_UP = true;

    /// @dev converts `normal` number to BigNumber with `exponent` and `coefficient` (or precision).
    /// e.g.:
    /// 5035703444687813576399599 (normal) = (coefficient[32bits], exponent[8bits])[40bits]
    /// 5035703444687813576399599 (decimal) => 10000101010010110100000011111011110010100110100000000011100101001101001101011101111 (binary)
    ///                                     => 10000101010010110100000011111011000000000000000000000000000000000000000000000000000
    ///                                                                        ^-------------------- 51(exponent) -------------- ^
    /// coefficient = 1000,0101,0100,1011,0100,0000,1111,1011               (2236301563)
    /// exponent =                                            0011,0011     (51)
    /// bigNumber =   1000,0101,0100,1011,0100,0000,1111,1011,0011,0011     (572493200179)
    ///
    /// @param normal number which needs to be converted into Big Number
    /// @param coefficientSize at max how many bits of precision there should be (64 = uint64 (64 bits precision))
    /// @param exponentSize at max how many bits of exponent there should be (8 = uint8 (8 bits exponent))
    /// @param roundUp signals if result should be rounded down or up
    /// @return bigNumber converted bigNumber (coefficient << exponent)
    function toBigNumber(
        uint256 normal,
        uint256 coefficientSize,
        uint256 exponentSize,
        bool roundUp
    ) internal pure returns (uint256 bigNumber) {
        assembly {
            let lastBit_
            let number_ := normal
            if gt(number_, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                number_ := shr(0x80, number_)
                lastBit_ := 0x80
            }
            if gt(number_, 0xFFFFFFFFFFFFFFFF) {
                number_ := shr(0x40, number_)
                lastBit_ := add(lastBit_, 0x40)
            }
            if gt(number_, 0xFFFFFFFF) {
                number_ := shr(0x20, number_)
                lastBit_ := add(lastBit_, 0x20)
            }
            if gt(number_, 0xFFFF) {
                number_ := shr(0x10, number_)
                lastBit_ := add(lastBit_, 0x10)
            }
            if gt(number_, 0xFF) {
                number_ := shr(0x8, number_)
                lastBit_ := add(lastBit_, 0x8)
            }
            if gt(number_, 0xF) {
                number_ := shr(0x4, number_)
                lastBit_ := add(lastBit_, 0x4)
            }
            if gt(number_, 0x3) {
                number_ := shr(0x2, number_)
                lastBit_ := add(lastBit_, 0x2)
            }
            if gt(number_, 0x1) {
                lastBit_ := add(lastBit_, 1)
            }
            if gt(number_, 0) {
                lastBit_ := add(lastBit_, 1)
            }
            if lt(lastBit_, coefficientSize) {
                // for throw exception
                lastBit_ := coefficientSize
            }
            let exponent := sub(lastBit_, coefficientSize)
            let coefficient := shr(exponent, normal)
            if and(roundUp, gt(exponent, 0)) {
                // rounding up is only needed if exponent is > 0, as otherwise the coefficient fully holds the original number
                coefficient := add(coefficient, 1)
                if eq(shl(coefficientSize, 1), coefficient) {
                    // case were coefficient was e.g. 111, with adding 1 it became 1000 (in binary) and coefficientSize 3 bits
                    // final coefficient would exceed it's size. -> reduce coefficent to 100 and increase exponent by 1.
                    coefficient := shl(sub(coefficientSize, 1), 1)
                    exponent := add(exponent, 1)
                }
            }
            if iszero(lt(exponent, shl(exponentSize, 1))) {
                // if exponent is >= exponentSize, the normal number is too big to fit within
                // BigNumber with too small sizes for coefficient and exponent
                revert(0, 0)
            }
            bigNumber := shl(exponentSize, coefficient)
            bigNumber := add(bigNumber, exponent)
        }
    }

    /// @dev get `normal` number from `bigNumber`, `exponentSize` and `exponentMask`
    function fromBigNumber(
        uint256 bigNumber,
        uint256 exponentSize,
        uint256 exponentMask
    ) internal pure returns (uint256 normal) {
        assembly {
            let coefficient := shr(exponentSize, bigNumber)
            let exponent := and(bigNumber, exponentMask)
            normal := shl(exponent, coefficient)
        }
    }

    /// @dev gets the most significant bit `lastBit` of a `normal` number (length of given number of binary format).
    /// e.g.
    /// 5035703444687813576399599 = 10000101010010110100000011111011110010100110100000000011100101001101001101011101111
    /// lastBit =                   ^---------------------------------   83   ----------------------------------------^
    function mostSignificantBit(uint256 normal) internal pure returns (uint lastBit) {
        assembly {
            let number_ := normal
            if gt(normal, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                number_ := shr(0x80, number_)
                lastBit := 0x80
            }
            if gt(number_, 0xFFFFFFFFFFFFFFFF) {
                number_ := shr(0x40, number_)
                lastBit := add(lastBit, 0x40)
            }
            if gt(number_, 0xFFFFFFFF) {
                number_ := shr(0x20, number_)
                lastBit := add(lastBit, 0x20)
            }
            if gt(number_, 0xFFFF) {
                number_ := shr(0x10, number_)
                lastBit := add(lastBit, 0x10)
            }
            if gt(number_, 0xFF) {
                number_ := shr(0x8, number_)
                lastBit := add(lastBit, 0x8)
            }
            if gt(number_, 0xF) {
                number_ := shr(0x4, number_)
                lastBit := add(lastBit, 0x4)
            }
            if gt(number_, 0x3) {
                number_ := shr(0x2, number_)
                lastBit := add(lastBit, 0x2)
            }
            if gt(number_, 0x1) {
                lastBit := add(lastBit, 1)
            }
            if gt(number_, 0) {
                lastBit := add(lastBit, 1)
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { BigMathMinified } from "./bigMathMinified.sol";
import { DexSlotsLink } from "./dexSlotsLink.sol";

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// @DEV ATTENTION: ON ANY CHANGES HERE, MAKE SURE THAT LOGIC IN VAULTS WILL STILL BE VALID.
// SOME CODE THERE ASSUMES DEXCALCS == LIQUIDITYCALCS.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

/// @notice implements calculation methods used for Fluid Dex such as updated withdrawal / borrow limits.
library DexCalcs {
    // constants used for BigMath conversion from and to storage
    uint256 internal constant DEFAULT_EXPONENT_SIZE = 8;
    uint256 internal constant DEFAULT_EXPONENT_MASK = 0xFF;

    uint256 internal constant FOUR_DECIMALS = 1e4;
    uint256 internal constant X14 = 0x3fff;
    uint256 internal constant X18 = 0x3ffff;
    uint256 internal constant X24 = 0xffffff;
    uint256 internal constant X33 = 0x1ffffffff;
    uint256 internal constant X64 = 0xffffffffffffffff;

    ///////////////////////////////////////////////////////////////////////////
    //////////                      CALC LIMITS                       /////////
    ///////////////////////////////////////////////////////////////////////////

    /// @dev calculates withdrawal limit before an operate execution:
    /// amount of user supply that must stay supplied (not amount that can be withdrawn).
    /// i.e. if user has supplied 100m and can withdraw 5M, this method returns the 95M, not the withdrawable amount 5M
    /// @param userSupplyData_ user supply data packed uint256 from storage
    /// @param userSupply_ current user supply amount already extracted from `userSupplyData_` and converted from BigMath
    /// @return currentWithdrawalLimit_ current withdrawal limit updated for expansion since last interaction.
    ///         returned value is in raw for with interest mode, normal amount for interest free mode!
    function calcWithdrawalLimitBeforeOperate(
        uint256 userSupplyData_,
        uint256 userSupply_
    ) internal view returns (uint256 currentWithdrawalLimit_) {
        // @dev must support handling the case where timestamp is 0 (config is set but no interactions yet).
        // first tx where timestamp is 0 will enter `if (lastWithdrawalLimit_ == 0)` because lastWithdrawalLimit_ is not set yet.
        // returning max withdrawal allowed, which is not exactly right but doesn't matter because the first interaction must be
        // a deposit anyway. Important is that it would not revert.

        // Note the first time a deposit brings the user supply amount to above the base withdrawal limit, the active limit
        // is the fully expanded limit immediately.

        // extract last set withdrawal limit
        uint256 lastWithdrawalLimit_ = (userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT) &
            X64;
        lastWithdrawalLimit_ =
            (lastWithdrawalLimit_ >> DEFAULT_EXPONENT_SIZE) <<
            (lastWithdrawalLimit_ & DEFAULT_EXPONENT_MASK);
        if (lastWithdrawalLimit_ == 0) {
            // withdrawal limit is not activated. Max withdrawal allowed
            return 0;
        }

        uint256 maxWithdrawableLimit_;
        uint256 temp_;
        unchecked {
            // extract max withdrawable percent of user supply and
            // calculate maximum withdrawable amount expandPercentage of user supply at full expansion duration elapsed
            // e.g.: if 10% expandPercentage, meaning 10% is withdrawable after full expandDuration has elapsed.

            // userSupply_ needs to be atleast 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            maxWithdrawableLimit_ =
                (((userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_EXPAND_PERCENT) & X14) * userSupply_) /
                FOUR_DECIMALS;

            // time elapsed since last withdrawal limit was set (in seconds)
            // @dev last process timestamp is guaranteed to exist for withdrawal, as a supply must have happened before.
            // last timestamp can not be > current timestamp
            temp_ = block.timestamp - ((userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP) & X33);
        }
        // calculate withdrawable amount of expandPercent that is elapsed of expandDuration.
        // e.g. if 60% of expandDuration has elapsed, then user should be able to withdraw 6% of user supply, down to 94%.
        // Note: no explicit check for this needed, it is covered by setting minWithdrawalLimit_ if needed.
        temp_ =
            (maxWithdrawableLimit_ * temp_) /
            // extract expand duration: After this, decrement won't happen (user can withdraw 100% of withdraw limit)
            ((userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_EXPAND_DURATION) & X24); // expand duration can never be 0
        // calculate expanded withdrawal limit: last withdrawal limit - withdrawable amount.
        // Note: withdrawable amount here can grow bigger than userSupply if timeElapsed is a lot bigger than expandDuration,
        // which would cause the subtraction `lastWithdrawalLimit_ - withdrawableAmount_` to revert. In that case, set 0
        // which will cause minimum (fully expanded) withdrawal limit to be set in lines below.
        unchecked {
            // underflow explicitly checked & handled
            currentWithdrawalLimit_ = lastWithdrawalLimit_ > temp_ ? lastWithdrawalLimit_ - temp_ : 0;
            // calculate minimum withdrawal limit: minimum amount of user supply that must stay supplied at full expansion.
            // subtraction can not underflow as maxWithdrawableLimit_ is a percentage amount (<=100%) of userSupply_
            temp_ = userSupply_ - maxWithdrawableLimit_;
        }
        // if withdrawal limit is decreased below minimum then set minimum
        // (e.g. when more than expandDuration time has elapsed)
        if (temp_ > currentWithdrawalLimit_) {
            currentWithdrawalLimit_ = temp_;
        }
    }

    /// @dev calculates withdrawal limit after an operate execution:
    /// amount of user supply that must stay supplied (not amount that can be withdrawn).
    /// i.e. if user has supplied 100m and can withdraw 5M, this method returns the 95M, not the withdrawable amount 5M
    /// @param userSupplyData_ user supply data packed uint256 from storage
    /// @param userSupply_ current user supply amount already extracted from `userSupplyData_` and added / subtracted with the executed operate amount
    /// @param newWithdrawalLimit_ current withdrawal limit updated for expansion since last interaction, result from `calcWithdrawalLimitBeforeOperate`
    /// @return withdrawalLimit_ updated withdrawal limit that should be written to storage. returned value is in
    ///                          raw for with interest mode, normal amount for interest free mode!
    function calcWithdrawalLimitAfterOperate(
        uint256 userSupplyData_,
        uint256 userSupply_,
        uint256 newWithdrawalLimit_
    ) internal pure returns (uint256) {
        // temp_ => base withdrawal limit. below this, maximum withdrawals are allowed
        uint256 temp_ = (userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        // if user supply is below base limit then max withdrawals are allowed
        if (userSupply_ < temp_) {
            return 0;
        }
        // temp_ => withdrawal limit expandPercent (is in 1e2 decimals)
        temp_ = (userSupplyData_ >> DexSlotsLink.BITS_USER_SUPPLY_EXPAND_PERCENT) & X14;
        unchecked {
            // temp_ => minimum withdrawal limit: userSupply - max withdrawable limit (userSupply * expandPercent))
            // userSupply_ needs to be atleast 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            // subtraction can not underflow as maxWithdrawableLimit_ is a percentage amount (<=100%) of userSupply_
            temp_ = userSupply_ - ((userSupply_ * temp_) / FOUR_DECIMALS);
        }
        // if new (before operation) withdrawal limit is less than minimum limit then set minimum limit.
        // e.g. can happen on new deposits. withdrawal limit is instantly fully expanded in a scenario where
        // increased deposit amount outpaces withrawals.
        if (temp_ > newWithdrawalLimit_) {
            return temp_;
        }
        return newWithdrawalLimit_;
    }

    /// @dev calculates borrow limit before an operate execution:
    /// total amount user borrow can reach (not borrowable amount in current operation).
    /// i.e. if user has borrowed 50M and can still borrow 5M, this method returns the total 55M, not the borrowable amount 5M
    /// @param userBorrowData_ user borrow data packed uint256 from storage
    /// @param userBorrow_ current user borrow amount already extracted from `userBorrowData_`
    /// @return currentBorrowLimit_ current borrow limit updated for expansion since last interaction. returned value is in
    ///                             raw for with interest mode, normal amount for interest free mode!
    function calcBorrowLimitBeforeOperate(
        uint256 userBorrowData_,
        uint256 userBorrow_
    ) internal view returns (uint256 currentBorrowLimit_) {
        // @dev must support handling the case where timestamp is 0 (config is set but no interactions yet) -> base limit.
        // first tx where timestamp is 0 will enter `if (maxExpandedBorrowLimit_ < baseBorrowLimit_)` because `userBorrow_` and thus
        // `maxExpansionLimit_` and thus `maxExpandedBorrowLimit_` is 0 and `baseBorrowLimit_` can not be 0.

        // temp_ = extract borrow expand percent (is in 1e2 decimals)
        uint256 temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_EXPAND_PERCENT) & X14;

        uint256 maxExpansionLimit_;
        uint256 maxExpandedBorrowLimit_;
        unchecked {
            // calculate max expansion limit: Max amount limit can expand to since last interaction
            // userBorrow_ needs to be atleast 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            maxExpansionLimit_ = ((userBorrow_ * temp_) / FOUR_DECIMALS);

            // calculate max borrow limit: Max point limit can increase to since last interaction
            maxExpandedBorrowLimit_ = userBorrow_ + maxExpansionLimit_;
        }

        // currentBorrowLimit_ = extract base borrow limit
        currentBorrowLimit_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_BASE_BORROW_LIMIT) & X18;
        currentBorrowLimit_ =
            (currentBorrowLimit_ >> DEFAULT_EXPONENT_SIZE) <<
            (currentBorrowLimit_ & DEFAULT_EXPONENT_MASK);

        if (maxExpandedBorrowLimit_ < currentBorrowLimit_) {
            return currentBorrowLimit_;
        }
        // time elapsed since last borrow limit was set (in seconds)
        unchecked {
            // temp_ = timeElapsed_ (last timestamp can not be > current timestamp)
            temp_ = block.timestamp - ((userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP) & X33); // extract last update timestamp
        }

        // currentBorrowLimit_ = expandedBorrowableAmount + extract last set borrow limit
        currentBorrowLimit_ =
            // calculate borrow limit expansion since last interaction for `expandPercent` that is elapsed of `expandDuration`.
            // divisor is extract expand duration (after this, full expansion to expandPercentage happened).
            ((maxExpansionLimit_ * temp_) /
                ((userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_EXPAND_DURATION) & X24)) + // expand duration can never be 0
            //  extract last set borrow limit
            BigMathMinified.fromBigNumber(
                (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT) & X64,
                DEFAULT_EXPONENT_SIZE,
                DEFAULT_EXPONENT_MASK
            );

        // if timeElapsed is bigger than expandDuration, new borrow limit would be > max expansion,
        // so set to `maxExpandedBorrowLimit_` in that case.
        // also covers the case where last process timestamp = 0 (timeElapsed would simply be very big)
        if (currentBorrowLimit_ > maxExpandedBorrowLimit_) {
            currentBorrowLimit_ = maxExpandedBorrowLimit_;
        }
        // temp_ = extract hard max borrow limit. Above this user can never borrow (not expandable above)
        temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_MAX_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        if (currentBorrowLimit_ > temp_) {
            currentBorrowLimit_ = temp_;
        }
    }

    /// @dev calculates borrow limit after an operate execution:
    /// total amount user borrow can reach (not borrowable amount in current operation).
    /// i.e. if user has borrowed 50M and can still borrow 5M, this method returns the total 55M, not the borrowable amount 5M
    /// @param userBorrowData_ user borrow data packed uint256 from storage
    /// @param userBorrow_ current user borrow amount already extracted from `userBorrowData_` and added / subtracted with the executed operate amount
    /// @param newBorrowLimit_ current borrow limit updated for expansion since last interaction, result from `calcBorrowLimitBeforeOperate`
    /// @return borrowLimit_ updated borrow limit that should be written to storage.
    ///                      returned value is in raw for with interest mode, normal amount for interest free mode!
    function calcBorrowLimitAfterOperate(
        uint256 userBorrowData_,
        uint256 userBorrow_,
        uint256 newBorrowLimit_
    ) internal pure returns (uint256 borrowLimit_) {
        // temp_ = extract borrow expand percent
        uint256 temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_EXPAND_PERCENT) & X14; // (is in 1e2 decimals)

        unchecked {
            // borrowLimit_ = calculate maximum borrow limit at full expansion.
            // userBorrow_ needs to be at least 1e73 to overflow max limit of ~1e77 in uint256 (no token in existence where this is possible).
            borrowLimit_ = userBorrow_ + ((userBorrow_ * temp_) / FOUR_DECIMALS);
        }

        // temp_ = extract base borrow limit
        temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_BASE_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        if (borrowLimit_ < temp_) {
            // below base limit, borrow limit is always base limit
            return temp_;
        }
        // temp_ = extract hard max borrow limit. Above this user can never borrow (not expandable above)
        temp_ = (userBorrowData_ >> DexSlotsLink.BITS_USER_BORROW_MAX_BORROW_LIMIT) & X18;
        temp_ = (temp_ >> DEFAULT_EXPONENT_SIZE) << (temp_ & DEFAULT_EXPONENT_MASK);

        // make sure fully expanded borrow limit is not above hard max borrow limit
        if (borrowLimit_ > temp_) {
            borrowLimit_ = temp_;
        }
        // if new borrow limit (from before operate) is > max borrow limit, set max borrow limit.
        // (e.g. on a repay shrinking instantly to fully expanded borrow limit from new borrow amount. shrinking is instant)
        if (newBorrowLimit_ > borrowLimit_) {
            return borrowLimit_;
        }
        return newBorrowLimit_;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @notice library that helps in reading / working with storage slot data of Fluid Dex.
/// @dev as all data for Fluid Dex is internal, any data must be fetched directly through manual
/// slot reading through this library or, if gas usage is less important, through the FluidDexResolver.
library DexSlotsLink {
    /// @dev storage slot for variables at Dex
    uint256 internal constant DEX_VARIABLES_SLOT = 0;
    /// @dev storage slot for variables2 at Dex
    uint256 internal constant DEX_VARIABLES2_SLOT = 1;
    /// @dev storage slot for total supply shares at Dex
    uint256 internal constant DEX_TOTAL_SUPPLY_SHARES_SLOT = 2;
    /// @dev storage slot for user supply mapping at Dex
    uint256 internal constant DEX_USER_SUPPLY_MAPPING_SLOT = 3;
    /// @dev storage slot for total borrow shares at Dex
    uint256 internal constant DEX_TOTAL_BORROW_SHARES_SLOT = 4;
    /// @dev storage slot for user borrow mapping at Dex
    uint256 internal constant DEX_USER_BORROW_MAPPING_SLOT = 5;
    /// @dev storage slot for oracle mapping at Dex
    uint256 internal constant DEX_ORACLE_MAPPING_SLOT = 6;
    /// @dev storage slot for range and threshold shifts at Dex
    uint256 internal constant DEX_RANGE_THRESHOLD_SHIFTS_SLOT = 7;
    /// @dev storage slot for center price shift at Dex
    uint256 internal constant DEX_CENTER_PRICE_SHIFT_SLOT = 8;

    // --------------------------------
    // @dev stacked uint256 storage slots bits position data for each:

    // UserSupplyData
    uint256 internal constant BITS_USER_SUPPLY_ALLOWED = 0;
    uint256 internal constant BITS_USER_SUPPLY_AMOUNT = 1;
    uint256 internal constant BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT = 65;
    uint256 internal constant BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT = 200;

    // UserBorrowData
    uint256 internal constant BITS_USER_BORROW_ALLOWED = 0;
    uint256 internal constant BITS_USER_BORROW_AMOUNT = 1;
    uint256 internal constant BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT = 65;
    uint256 internal constant BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_BORROW_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_BORROW_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_BORROW_BASE_BORROW_LIMIT = 200;
    uint256 internal constant BITS_USER_BORROW_MAX_BORROW_LIMIT = 218;

    // --------------------------------

    /// @notice Calculating the slot ID for Dex contract for single mapping at `slot_` for `key_`
    function calculateMappingStorageSlot(uint256 slot_, address key_) internal pure returns (bytes32) {
        return keccak256(abi.encode(key_, slot_));
    }

    /// @notice Calculating the slot ID for Dex contract for double mapping at `slot_` for `key1_` and `key2_`
    function calculateDoubleMappingStorageSlot(
        uint256 slot_,
        address key1_,
        address key2_
    ) internal pure returns (bytes32) {
        bytes32 intermediateSlot_ = keccak256(abi.encode(key1_, slot_));
        return keccak256(abi.encode(key2_, intermediateSlot_));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library LibsErrorTypes {
    /***********************************|
    |         LiquidityCalcs            | 
    |__________________________________*/

    /// @notice thrown when supply or borrow exchange price is zero at calc token data (token not configured yet)
    uint256 internal constant LiquidityCalcs__ExchangePriceZero = 70001;

    /// @notice thrown when rate data is set to a version that is not implemented
    uint256 internal constant LiquidityCalcs__UnsupportedRateVersion = 70002;

    /// @notice thrown when the calculated borrow rate turns negative. This should never happen.
    uint256 internal constant LiquidityCalcs__BorrowRateNegative = 70003;

    /***********************************|
    |           SafeTransfer            | 
    |__________________________________*/

    /// @notice thrown when safe transfer from for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFromFailed = 71001;

    /// @notice thrown when safe transfer for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFailed = 71002;

    /***********************************|
    |           SafeApprove             | 
    |__________________________________*/

    /// @notice thrown when safe approve from for an ERC20 fails
    uint256 internal constant SafeApprove__ApproveFailed = 81001;
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.21;

import { LibsErrorTypes as ErrorTypes } from "./errorTypes.sol";

/// @notice provides minimalistic methods for safe transfers, e.g. ERC20 safeTransferFrom
library SafeTransfer {
    uint256 internal constant MAX_NATIVE_TRANSFER_GAS = 20000; // pass max. 20k gas for native transfers

    error FluidSafeTransferError(uint256 errorId_);

    /// @dev Transfer `amount_` of `token_` from `from_` to `to_`, spending the approval given by `from_` to the
    /// calling contract. If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L31-L63
    function safeTransferFrom(address token_, address from_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from_" argument.
            mstore(add(freeMemoryPointer, 36), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 68), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFromFailed);
        }
    }

    /// @dev Transfer `amount_` of `token_` to `to_`.
    /// If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L65-L95
    function safeTransfer(address token_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 36), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }

    /// @dev Transfer `amount_` of ` native token to `to_`.
    /// Minimally modified from Solmate SafeTransferLib (Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L15-L25
    function safeTransferNative(address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not. Pass limited gas
            success_ := call(MAX_NATIVE_TRANSFER_GAS, to_, amount_, 0, 0, 0, 0)
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @notice implements a method to read uint256 data from storage at a bytes32 storage slot key.
contract StorageRead {
    function readFromStorage(bytes32 slot_) public view returns (uint256 result_) {
        assembly {
            result_ := sload(slot_) // read value from the storage slot
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { Structs } from "./poolT1/coreModule/structs.sol";

abstract contract Error {
    error FluidDexError(uint256 errorId_);

    error FluidDexFactoryError(uint256 errorId);

    /// @notice used to simulate swap to find the output amount
    error FluidDexSwapResult(uint256 amountOut);

    error FluidDexPerfectLiquidityOutput(uint256 token0Amt, uint token1Amt);

    error FluidDexSingleTokenOutput(uint256 tokenAmt);

    error FluidDexLiquidityOutput(uint256 shares_);

    error FluidDexPricesAndExchangeRates(Structs.PricesAndExchangePrice pex_);

    error FluidSmartLendingError(uint256 errorId_);

    error FluidSmartLendingFactoryError(uint256 errorId_);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |             DexT1                 | 
    |__________________________________*/

    /// @notice thrown at reentrancy
    uint256 internal constant DexT1__AlreadyEntered = 51001;

    uint256 internal constant DexT1__NotAnAuth = 51002;

    uint256 internal constant DexT1__SmartColNotEnabled = 51003;

    uint256 internal constant DexT1__SmartDebtNotEnabled = 51004;

    uint256 internal constant DexT1__PoolNotInitialized = 51005;

    uint256 internal constant DexT1__TokenReservesTooLow = 51006;

    uint256 internal constant DexT1__EthAndAmountInMisMatch = 51007;

    uint256 internal constant DexT1__EthSentForNonNativeSwap = 51008;

    uint256 internal constant DexT1__NoSwapRoute = 51009;

    uint256 internal constant DexT1__NotEnoughAmountOut = 51010;

    uint256 internal constant DexT1__LiquidityLayerTokenUtilizationCapReached = 51011;

    uint256 internal constant DexT1__HookReturnedFalse = 51012;

    // Either user's config are not set or user is paused
    uint256 internal constant DexT1__UserSupplyInNotOn = 51013;

    // Either user's config are not set or user is paused
    uint256 internal constant DexT1__UserDebtInNotOn = 51014;

    // Thrown when contract asks for more token0 or token1 than what user's wants to give on deposit
    uint256 internal constant DexT1__AboveDepositMax = 51015;

    uint256 internal constant DexT1__MsgValueLowOnDepositOrPayback = 51016;

    uint256 internal constant DexT1__WithdrawLimitReached = 51017;

    // Thrown when contract gives less token0 or token1 than what user's wants on withdraw
    uint256 internal constant DexT1__BelowWithdrawMin = 51018;

    uint256 internal constant DexT1__DebtLimitReached = 51019;

    // Thrown when contract gives less token0 or token1 than what user's wants on borrow
    uint256 internal constant DexT1__BelowBorrowMin = 51020;

    // Thrown when contract asks for more token0 or token1 than what user's wants on payback
    uint256 internal constant DexT1__AbovePaybackMax = 51021;

    uint256 internal constant DexT1__InvalidDepositAmts = 51022;

    uint256 internal constant DexT1__DepositAmtsZero = 51023;

    uint256 internal constant DexT1__SharesMintedLess = 51024;

    uint256 internal constant DexT1__WithdrawalNotEnough = 51025;

    uint256 internal constant DexT1__InvalidWithdrawAmts = 51026;

    uint256 internal constant DexT1__WithdrawAmtsZero = 51027;

    uint256 internal constant DexT1__WithdrawExcessSharesBurn = 51028;

    uint256 internal constant DexT1__InvalidBorrowAmts = 51029;

    uint256 internal constant DexT1__BorrowAmtsZero = 51030;

    uint256 internal constant DexT1__BorrowExcessSharesMinted = 51031;

    uint256 internal constant DexT1__PaybackAmtTooHigh = 51032;

    uint256 internal constant DexT1__InvalidPaybackAmts = 51033;

    uint256 internal constant DexT1__PaybackAmtsZero = 51034;

    uint256 internal constant DexT1__PaybackSharedBurnedLess = 51035;

    uint256 internal constant DexT1__NothingToArbitrage = 51036;

    uint256 internal constant DexT1__MsgSenderNotLiquidity = 51037;

    // On liquidity callback reentrancy bit should be on
    uint256 internal constant DexT1__ReentrancyBitShouldBeOn = 51038;

    // Thrown is reentrancy is already on and someone tries to fetch oracle price. Should not be possible to this
    uint256 internal constant DexT1__OraclePriceFetchAlreadyEntered = 51039;

    // Thrown when swap changes the current price by more than 5%
    uint256 internal constant DexT1__OracleUpdateHugeSwapDiff = 51040;

    uint256 internal constant DexT1__Token0ShouldBeSmallerThanToken1 = 51041;

    uint256 internal constant DexT1__OracleMappingOverflow = 51042;

    /// @notice thrown if governance has paused the swapping & arbitrage so only perfect functions are usable
    uint256 internal constant DexT1__SwapAndArbitragePaused = 51043;

    uint256 internal constant DexT1__ExceedsAmountInMax = 51044;

    /// @notice thrown if amount in is too high or too low
    uint256 internal constant DexT1__SwapInLimitingAmounts = 51045;

    /// @notice thrown if amount out is too high or too low
    uint256 internal constant DexT1__SwapOutLimitingAmounts = 51046;

    uint256 internal constant DexT1__MintAmtOverflow = 51047;

    uint256 internal constant DexT1__BurnAmtOverflow = 51048;

    uint256 internal constant DexT1__LimitingAmountsSwapAndNonPerfectActions = 51049;

    uint256 internal constant DexT1__InsufficientOracleData = 51050;

    uint256 internal constant DexT1__SharesAmountInsufficient = 51051;

    uint256 internal constant DexT1__CenterPriceOutOfRange = 51052;

    uint256 internal constant DexT1__DebtReservesTooLow = 51053;

    uint256 internal constant DexT1__SwapAndDepositTooLowOrTooHigh = 51054;

    uint256 internal constant DexT1__WithdrawAndSwapTooLowOrTooHigh = 51055;

    uint256 internal constant DexT1__BorrowAndSwapTooLowOrTooHigh = 51056;

    uint256 internal constant DexT1__SwapAndPaybackTooLowOrTooHigh = 51057;

    uint256 internal constant DexT1__InvalidImplementation = 51058;

    uint256 internal constant DexT1__OnlyDelegateCallAllowed = 51059;

    uint256 internal constant DexT1__IncorrectDataLength = 51060;

    uint256 internal constant DexT1__AmountToSendLessThanAmount = 51061;

    uint256 internal constant DexT1__InvalidCollateralReserves = 51062;

    uint256 internal constant DexT1__InvalidDebtReserves = 51063;

    uint256 internal constant DexT1__SupplySharesOverflow = 51064;

    uint256 internal constant DexT1__BorrowSharesOverflow = 51065;

    uint256 internal constant DexT1__OracleNotActive = 51066;

    /***********************************|
    |            DEX Admin              | 
    |__________________________________*/

    /// @notice thrown when pool is not initialized
    uint256 internal constant DexT1Admin__PoolNotInitialized = 52001;

    uint256 internal constant DexT1Admin__SmartColIsAlreadyOn = 52002;

    uint256 internal constant DexT1Admin__SmartDebtIsAlreadyOn = 52003;

    /// @notice thrown when any of the configs value overflow the maximum limit
    uint256 internal constant DexT1Admin__ConfigOverflow = 52004;

    uint256 internal constant DexT1Admin__AddressNotAContract = 52005;

    uint256 internal constant DexT1Admin__InvalidParams = 52006;

    uint256 internal constant DexT1Admin__UserNotDefined = 52007;

    uint256 internal constant DexT1Admin__OnlyDelegateCallAllowed = 52008;

    uint256 internal constant DexT1Admin__UnexpectedPoolState = 52009;

    /// @notice thrown when trying to pause or unpause but user is already in the target pause state
    uint256 internal constant DexT1Admin__InvalidPauseToggle = 52009;

    /***********************************|
    |            DEX Factory            | 
    |__________________________________*/

    uint256 internal constant DexFactory__InvalidOperation = 53001;
    uint256 internal constant DexFactory__Unauthorized = 53002;
    uint256 internal constant DexFactory__SameTokenNotAllowed = 53003;
    uint256 internal constant DexFactory__TokenConfigNotProper = 53004;
    uint256 internal constant DexFactory__InvalidParams = 53005;
    uint256 internal constant DexFactory__OnlyDelegateCallAllowed = 53006;
    uint256 internal constant DexFactory__InvalidDexAddress = 53007;

    /***********************************|
    |            Smart Lending          | 
    |__________________________________*/

    uint256 internal constant SmartLending__ZeroAddress = 54001;
    uint256 internal constant SmartLending__Unauthorized = 54002;
    uint256 internal constant SmartLending__InvalidMsgValue = 54003;
    uint256 internal constant SmartLending__OutOfRange = 54004;
    uint256 internal constant SmartLending__InvalidRebalancer = 54005;
    uint256 internal constant SmartLending__Reentrancy = 54006;
    uint256 internal constant SmartLending__InvalidAmounts = 54007;

    /***********************************|
    |        Smart Lending Factory       | 
    |__________________________________*/

    uint256 internal constant SmartLendingFactory__ZeroAddress = 55001;
    uint256 internal constant SmartLendingFactory__Unauthorized = 55002;
    uint256 internal constant SmartLendingFactory__AlreadyDeployed = 55003;
    uint256 internal constant SmartLendingFactory__InvalidParams = 55004;
    uint256 internal constant SmartLendingFactory__InvalidOperation = 55005;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { Owned } from "solmate/src/auth/Owned.sol";
import { ErrorTypes } from "../errorTypes.sol";
import { Error } from "../error.sol";
import { AddressCalcs } from "../../../libraries/addressCalcs.sol";
import { StorageRead } from "../../../libraries/storageRead.sol";

abstract contract DexFactoryVariables is Owned, StorageRead, Error {
    /*//////////////////////////////////////////////////////////////
                          STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/

    // ------------ storage variables from inherited contracts (Owned) come before vars here --------

    // ----------------------- slot 0 ---------------------------
    // address public owner; // from Owned

    // 12 bytes empty

    // ----------------------- slot 1  ---------------------------
    /// @dev deployer can deploy new Dex Pool contract
    /// owner can add/remove deployer.
    /// Owner is deployer by default.
    mapping(address => bool) internal _deployers;

    // ----------------------- slot 2  ---------------------------
    /// @dev global auths can update any dex pool config.
    /// owner can add/remove global auths.
    /// Owner is global auth by default.
    mapping(address => bool) internal _globalAuths;

    // ----------------------- slot 3  ---------------------------
    /// @dev dex auths can update specific dex config.
    /// owner can add/remove dex auths.
    /// Owner is dex auth by default.
    /// dex => auth => add/remove
    mapping(address => mapping(address => bool)) internal _dexAuths;

    // ----------------------- slot 4 ---------------------------
    /// @dev total no of dexes deployed by the factory
    /// only addresses that have deployer role or owner can deploy new dex pool.
    uint256 internal _totalDexes;

    // ----------------------- slot 5 ---------------------------
    /// @dev dex deployment logics for deploying dex pool
    /// These logic contracts hold the deployment logics of specific dexes and are called via .delegatecall inside deployDex().
    /// only addresses that have owner can add/remove new dex deployment logic.
    mapping(address => bool) internal _dexDeploymentLogics;

    /*//////////////////////////////////////////////////////////////
                          CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address owner_) Owned(owner_) {}
}

abstract contract DexFactoryEvents {
    /// @dev Emitted when a new dex is deployed.
    /// @param dex The address of the newly deployed dex.
    /// @param dexId The id of the newly deployed dex.
    event LogDexDeployed(address indexed dex, uint256 indexed dexId);

    /// @dev Emitted when the deployer is modified by owner.
    /// @param deployer Address whose deployer status is updated.
    /// @param allowed Indicates whether the address is authorized as a deployer or not.
    event LogSetDeployer(address indexed deployer, bool indexed allowed);

    /// @dev Emitted when the globalAuth is modified by owner.
    /// @param globalAuth Address whose globalAuth status is updated.
    /// @param allowed Indicates whether the address is authorized as a deployer or not.
    event LogSetGlobalAuth(address indexed globalAuth, bool indexed allowed);

    /// @dev Emitted when the dexAuth is modified by owner.
    /// @param dexAuth Address whose dexAuth status is updated.
    /// @param allowed Indicates whether the address is authorized as a deployer or not.
    /// @param dex Address of the specific dex related to the authorization change.
    event LogSetDexAuth(address indexed dexAuth, bool indexed allowed, address indexed dex);

    /// @dev Emitted when the dex deployment logic is modified by owner.
    /// @param dexDeploymentLogic The address of the dex deployment logic contract.
    /// @param allowed  Indicates whether the address is authorized as a deployer or not.
    event LogSetDexDeploymentLogic(address indexed dexDeploymentLogic, bool indexed allowed);
}

abstract contract DexFactoryCore is DexFactoryVariables, DexFactoryEvents {
    constructor(address owner_) validAddress(owner_) DexFactoryVariables(owner_) {}

    /// @dev validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidDexFactoryError(ErrorTypes.DexFactory__InvalidParams);
        }
        _;
    }
}

/// @dev Implements Dex Factory auth-only callable methods. Owner / auths can set various config values and
/// can define the allow-listed deployers.
abstract contract DexFactoryAuth is DexFactoryCore {
    /// @notice                         Sets an address (`deployer_`) as allowed deployer or not.
    ///                                 This function can only be called by the owner.
    /// @param deployer_                The address to be set as deployer.
    /// @param allowed_                 A boolean indicating whether the specified address is allowed to deploy dexes.
    function setDeployer(address deployer_, bool allowed_) external onlyOwner validAddress(deployer_) {
        _deployers[deployer_] = allowed_;

        emit LogSetDeployer(deployer_, allowed_);
    }

    /// @notice                         Sets an address (`globalAuth_`) as a global authorization or not.
    ///                                 This function can only be called by the owner.
    /// @param globalAuth_              The address to be set as global authorization.
    /// @param allowed_                 A boolean indicating whether the specified address is allowed to update any dex config.
    function setGlobalAuth(address globalAuth_, bool allowed_) external onlyOwner validAddress(globalAuth_) {
        _globalAuths[globalAuth_] = allowed_;

        emit LogSetGlobalAuth(globalAuth_, allowed_);
    }

    /// @notice                         Sets an address (`dexAuth_`) as allowed dex authorization or not for a specific dex (`dex_`).
    ///                                 This function can only be called by the owner.
    /// @param dex_                     The address of the dex for which the authorization is being set.
    /// @param dexAuth_                 The address to be set as dex authorization.
    /// @param allowed_                 A boolean indicating whether the specified address is allowed to update the specific dex config.
    function setDexAuth(address dex_, address dexAuth_, bool allowed_) external onlyOwner validAddress(dexAuth_) {
        _dexAuths[dex_][dexAuth_] = allowed_;

        emit LogSetDexAuth(dexAuth_, allowed_, dex_);
    }

    /// @notice                         Sets an address as allowed dex deployment logic (`deploymentLogic_`) contract or not.
    ///                                 This function can only be called by the owner.
    /// @param deploymentLogic_         The address of the dex deployment logic contract to be set.
    /// @param allowed_                 A boolean indicating whether the specified address is allowed to deploy new type of dex.
    function setDexDeploymentLogic(
        address deploymentLogic_,
        bool allowed_
    ) public onlyOwner validAddress(deploymentLogic_) {
        _dexDeploymentLogics[deploymentLogic_] = allowed_;

        emit LogSetDexDeploymentLogic(deploymentLogic_, allowed_);
    }

    /// @notice                         Spell allows owner aka governance to do any arbitrary call on factory
    /// @param target_                  Address to which the call needs to be delegated
    /// @param data_                    Data to execute at the delegated address
    function spell(address target_, bytes memory data_) external onlyOwner returns (bytes memory response_) {
        assembly {
            let succeeded := delegatecall(gas(), target_, add(data_, 0x20), mload(data_), 0, 0)
            let size := returndatasize()

            response_ := mload(0x40)
            mstore(0x40, add(response_, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response_, size)
            returndatacopy(add(response_, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    /// @notice                         Checks if the provided address (`deployer_`) is authorized as a deployer.
    /// @param deployer_                The address to be checked for deployer authorization.
    /// @return                         Returns `true` if the address is a deployer, otherwise `false`.
    function isDeployer(address deployer_) public view returns (bool) {
        return _deployers[deployer_] || owner == deployer_;
    }

    /// @notice                         Checks if the provided address (`globalAuth_`) has global dex authorization privileges.
    /// @param globalAuth_              The address to be checked for global authorization privileges.
    /// @return                         Returns `true` if the given address has global authorization privileges, otherwise `false`.
    function isGlobalAuth(address globalAuth_) public view returns (bool) {
        return _globalAuths[globalAuth_] || owner == globalAuth_;
    }

    /// @notice                         Checks if the provided address (`dexAuth_`) has dex authorization privileges for the specified dex (`dex_`).
    /// @param dex_                     The address of the dex to check.
    /// @param dexAuth_                 The address to be checked for dex authorization privileges.
    /// @return                         Returns `true` if the given address has dex authorization privileges for the specified dex, otherwise `false`.
    function isDexAuth(address dex_, address dexAuth_) public view returns (bool) {
        return _dexAuths[dex_][dexAuth_] || owner == dexAuth_;
    }

    /// @notice                         Checks if the provided (`dexDeploymentLogic_`) address has authorization for dex deployment.
    /// @param dexDeploymentLogic_      The address of the dex deploy logic to check for authorization privileges.
    /// @return                         Returns `true` if the given address has authorization privileges for dex deployment, otherwise `false`.
    function isDexDeploymentLogic(address dexDeploymentLogic_) public view returns (bool) {
        return _dexDeploymentLogics[dexDeploymentLogic_];
    }
}

/// @dev implements DexFactory deploy dex related methods.
abstract contract DexFactoryDeployment is DexFactoryCore, DexFactoryAuth {
    /// @dev                            Deploys a contract using the CREATE opcode with the provided bytecode (`bytecode_`).
    ///                                 This is an internal function, meant to be used within the contract to facilitate the deployment of other contracts.
    /// @param bytecode_                The bytecode of the contract to be deployed.
    /// @return address_                Returns the address of the deployed contract.
    function _deploy(bytes memory bytecode_) internal returns (address address_) {
        if (bytecode_.length == 0) {
            revert FluidDexError(ErrorTypes.DexFactory__InvalidOperation);
        }
        /// @solidity memory-safe-assembly
        assembly {
            address_ := create(0, add(bytecode_, 0x20), mload(bytecode_))
        }
        if (address_ == address(0)) {
            revert FluidDexError(ErrorTypes.DexFactory__InvalidOperation);
        }
    }

    /// @notice                       Deploys a new dex using the specified deployment logic `dexDeploymentLogic_` and data `dexDeploymentData_`.
    ///                               Only accounts with deployer access or the owner can deploy a new dex.
    /// @param dexDeploymentLogic_    The address of the dex deployment logic contract.
    /// @param dexDeploymentData_     The data to be used for dex deployment.
    /// @return dex_                  Returns the address of the newly deployed dex.
    function deployDex(address dexDeploymentLogic_, bytes calldata dexDeploymentData_) external returns (address dex_) {
        // Revert if msg.sender doesn't have deployer access or is an owner.
        if (!isDeployer(msg.sender)) revert FluidDexError(ErrorTypes.DexFactory__Unauthorized);
        // Revert if dexDeploymentLogic_ is not whitelisted.
        if (!isDexDeploymentLogic(dexDeploymentLogic_)) revert FluidDexError(ErrorTypes.DexFactory__Unauthorized);

        // Dex ID for the new dex and also acts as `nonce` for CREATE
        uint256 dexId_ = ++_totalDexes;

        // compute dex address for dex id.
        dex_ = getDexAddress(dexId_);

        // deploy the dex using dex deployment logic by making .delegatecall
        (bool success_, bytes memory data_) = dexDeploymentLogic_.delegatecall(dexDeploymentData_);

        if (!(success_ && dex_ == _deploy(abi.decode(data_, (bytes))) && isDex(dex_))) {
            revert FluidDexError(ErrorTypes.DexFactory__InvalidDexAddress);
        }

        emit LogDexDeployed(dex_, dexId_);
    }

    /// @notice                       Computes the address of a dex based on its given ID (`dexId_`).
    /// @param dexId_                 The ID of the dex.
    /// @return dex_                  Returns the computed address of the dex.
    function getDexAddress(uint256 dexId_) public view returns (address dex_) {
        return AddressCalcs.addressCalc(address(this), dexId_);
    }

    /// @notice                         Checks if a given address (`dex_`) corresponds to a valid dex.
    /// @param dex_                     The dex address to check.
    /// @return                         Returns `true` if the given address corresponds to a valid dex, otherwise `false`.
    function isDex(address dex_) public view returns (bool) {
        if (dex_.code.length == 0) {
            return false;
        } else {
            // DEX_ID() function signature is 0xf4b9a3fb
            (bool success_, bytes memory data_) = dex_.staticcall(hex"f4b9a3fb");
            return success_ && dex_ == getDexAddress(abi.decode(data_, (uint256)));
        }
    }

    /// @notice                   Returns the total number of dexes deployed by the factory.
    /// @return                   Returns the total number of dexes.
    function totalDexes() external view returns (uint256) {
        return _totalDexes;
    }
}

/// @title Fluid DexFactory
/// @notice creates Fluid dex protocol dexes, which are interacting with Fluid Liquidity to deposit / borrow funds.
/// Dexes are created at a deterministic address, given an incrementing `dexId` (see `getDexAddress()`).
/// Dexes can only be deployed by allow-listed deployer addresses.
/// @dev Note the deployed dexes start out with no config at Liquidity contract.
/// This must be done by Liquidity auths in a separate step, otherwise no deposits will be possible.
/// This contract is not upgradeable. It supports adding new dex deployment logic contracts for new, future dexes.
contract FluidDexFactory is DexFactoryCore, DexFactoryAuth, DexFactoryDeployment {
    constructor(address owner_) DexFactoryCore(owner_) {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IFluidDexT1 {
    error FluidDexError(uint256 errorId);

    /// @notice used to simulate swap to find the output amount
    error FluidDexSwapResult(uint256 amountOut);

    error FluidDexPerfectLiquidityOutput(uint256 token0Amt, uint token1Amt);

    error FluidDexSingleTokenOutput(uint256 tokenAmt);

    error FluidDexLiquidityOutput(uint256 shares);

    error FluidDexPricesAndExchangeRates(PricesAndExchangePrice pex_);

    /// @notice returns the dex id
    function DEX_ID() external view returns (uint256);

    /// @notice reads uint256 data `result_` from storage at a bytes32 storage `slot_` key.
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);

    struct Implementations {
        address shift;
        address admin;
        address colOperations;
        address debtOperations;
        address perfectOperationsAndOracle;
    }

    struct ConstantViews {
        uint256 dexId;
        address liquidity;
        address factory;
        Implementations implementations;
        address deployerContract;
        address token0;
        address token1;
        bytes32 supplyToken0Slot;
        bytes32 borrowToken0Slot;
        bytes32 supplyToken1Slot;
        bytes32 borrowToken1Slot;
        bytes32 exchangePriceToken0Slot;
        bytes32 exchangePriceToken1Slot;
        uint256 oracleMapping;
    }

    struct ConstantViews2 {
        uint token0NumeratorPrecision;
        uint token0DenominatorPrecision;
        uint token1NumeratorPrecision;
        uint token1DenominatorPrecision;
    }

    struct PricesAndExchangePrice {
        uint lastStoredPrice; // last stored price in 1e27 decimals
        uint centerPrice; // last stored price in 1e27 decimals
        uint upperRange; // price at upper range in 1e27 decimals
        uint lowerRange; // price at lower range in 1e27 decimals
        uint geometricMean; // geometric mean of upper range & lower range in 1e27 decimals
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct CollateralReserves {
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct DebtReserves {
        uint token0Debt;
        uint token1Debt;
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    function getCollateralReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0SupplyExchangePrice_,
        uint token1SupplyExchangePrice_
    ) external view returns (CollateralReserves memory c_);

    function getDebtReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0BorrowExchangePrice_,
        uint token1BorrowExchangePrice_
    ) external view returns (DebtReserves memory d_);

    // reverts with FluidDexPricesAndExchangeRates(pex_);
    function getPricesAndExchangePrices() external;

    function constantsView() external view returns (ConstantViews memory constantsView_);

    function constantsView2() external view returns (ConstantViews2 memory constantsView2_);

    struct Oracle {
        uint twap1by0; // TWAP price
        uint lowestPrice1by0; // lowest price point
        uint highestPrice1by0; // highest price point
        uint twap0by1; // TWAP price
        uint lowestPrice0by1; // lowest price point
        uint highestPrice0by1; // highest price point
    }

    /// @dev This function allows users to swap a specific amount of input tokens for output tokens
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountIn_ The exact amount of input tokens to swap
    /// @param amountOutMin_ The minimum amount of output tokens the user is willing to accept
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountOut_
    /// @return amountOut_ The amount of output tokens received from the swap
    function swapIn(
        bool swap0to1_,
        uint256 amountIn_,
        uint256 amountOutMin_,
        address to_
    ) external payable returns (uint256 amountOut_);

    /// @dev Swap tokens with perfect amount out
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountOut_ The exact amount of tokens to receive after swap
    /// @param amountInMax_ Maximum amount of tokens to swap in
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountIn_
    /// @return amountIn_ The amount of input tokens used for the swap
    function swapOut(
        bool swap0to1_,
        uint256 amountOut_,
        uint256 amountInMax_,
        address to_
    ) external payable returns (uint256 amountIn_);

    /// @dev Deposit tokens in equal proportion to the current pool ratio
    /// @param shares_ The number of shares to mint
    /// @param maxToken0Deposit_ Maximum amount of token0 to deposit
    /// @param maxToken1Deposit_ Maximum amount of token1 to deposit
    /// @param estimate_ If true, function will revert with estimated deposit amounts without executing the deposit
    /// @return token0Amt_ Amount of token0 deposited
    /// @return token1Amt_ Amount of token1 deposited
    function depositPerfect(
        uint shares_,
        uint maxToken0Deposit_,
        uint maxToken1Deposit_,
        bool estimate_
    ) external payable returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to withdraw a perfect amount of collateral liquidity
    /// @param shares_ The number of shares to withdraw
    /// @param minToken0Withdraw_ The minimum amount of token0 the user is willing to accept
    /// @param minToken1Withdraw_ The minimum amount of token1 the user is willing to accept
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ The amount of token0 withdrawn
    /// @return token1Amt_ The amount of token1 withdrawn
    function withdrawPerfect(
        uint shares_,
        uint minToken0Withdraw_,
        uint minToken1Withdraw_,
        address to_
    ) external returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to borrow tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to borrow
    /// @param minToken0Borrow_ Minimum amount of token0 to borrow
    /// @param minToken1Borrow_ Minimum amount of token1 to borrow
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ Amount of token0 borrowed
    /// @return token1Amt_ Amount of token1 borrowed
    function borrowPerfect(
        uint shares_,
        uint minToken0Borrow_,
        uint minToken1Borrow_,
        address to_
    ) external returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to pay back borrowed tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to pay back
    /// @param maxToken0Payback_ Maximum amount of token0 to pay back
    /// @param maxToken1Payback_ Maximum amount of token1 to pay back
    /// @param estimate_ If true, function will revert with estimated payback amounts without executing the payback
    /// @return token0Amt_ Amount of token0 paid back
    /// @return token1Amt_ Amount of token1 paid back
    function paybackPerfect(
        uint shares_,
        uint maxToken0Payback_,
        uint maxToken1Payback_,
        bool estimate_
    ) external payable returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to deposit tokens in any proportion into the col pool
    /// @param token0Amt_ The amount of token0 to deposit
    /// @param token1Amt_ The amount of token1 to deposit
    /// @param minSharesAmt_ The minimum amount of shares the user expects to receive
    /// @param estimate_ If true, function will revert with estimated shares without executing the deposit
    /// @return shares_ The amount of shares minted for the deposit
    function deposit(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) external payable returns (uint shares_);

    /// @dev This function allows users to withdraw tokens in any proportion from the col pool
    /// @param token0Amt_ The amount of token0 to withdraw
    /// @param token1Amt_ The amount of token1 to withdraw
    /// @param maxSharesAmt_ The maximum number of shares the user is willing to burn
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The number of shares burned for the withdrawal
    function withdraw(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) external returns (uint shares_);

    /// @dev This function allows users to borrow tokens in any proportion from the debt pool
    /// @param token0Amt_ The amount of token0 to borrow
    /// @param token1Amt_ The amount of token1 to borrow
    /// @param maxSharesAmt_ The maximum amount of shares the user is willing to receive
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The amount of borrow shares minted to represent the borrowed amount
    function borrow(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) external returns (uint shares_);

    /// @dev This function allows users to payback tokens in any proportion to the debt pool
    /// @param token0Amt_ The amount of token0 to payback
    /// @param token1Amt_ The amount of token1 to payback
    /// @param minSharesAmt_ The minimum amount of shares the user expects to burn
    /// @param estimate_ If true, function will revert with estimated shares without executing the payback
    /// @return shares_ The amount of borrow shares burned for the payback
    function payback(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) external payable returns (uint shares_);

    /// @dev This function allows users to withdraw their collateral with perfect shares in one token
    /// @param shares_ The number of shares to burn for withdrawal
    /// @param minToken0_ The minimum amount of token0 the user expects to receive (set to 0 if withdrawing in token1)
    /// @param minToken1_ The minimum amount of token1 the user expects to receive (set to 0 if withdrawing in token0)
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with withdrawAmt_
    /// @return withdrawAmt_ The amount of tokens withdrawn in the chosen token
    function withdrawPerfectInOneToken(
        uint shares_,
        uint minToken0_,
        uint minToken1_,
        address to_
    ) external returns (
        uint withdrawAmt_
    );

    /// @dev This function allows users to payback their debt with perfect shares in one token
    /// @param shares_ The number of shares to burn for payback
    /// @param maxToken0_ The maximum amount of token0 the user is willing to pay (set to 0 if paying back in token1)
    /// @param maxToken1_ The maximum amount of token1 the user is willing to pay (set to 0 if paying back in token0)
    /// @param estimate_ If true, the function will revert with the estimated payback amount without executing the payback
    /// @return paybackAmt_ The amount of tokens paid back in the chosen token
    function paybackPerfectInOneToken(
        uint shares_,
        uint maxToken0_,
        uint maxToken1_,
        bool estimate_
    ) external payable returns (
        uint paybackAmt_
    );

    /// @dev the oracle assumes last set price of pool till the next swap happens.
    /// There's a possibility that during that time some interest is generated hence the last stored price is not the 100% correct price for the whole duration
    /// but the difference due to interest will be super low so this difference is ignored
    /// For example 2 swaps happened 10min (600 seconds) apart and 1 token has 10% higher interest than other.
    /// then that token will accrue about 10% * 600 / secondsInAYear = ~0.0002%
    /// @param secondsAgos_ array of seconds ago for which TWAP is needed. If user sends [10, 30, 60] then twaps_ will return [10-0, 30-10, 60-30]
    /// @return twaps_ twap price, lowest price (aka minima) & highest price (aka maxima) between secondsAgo checkpoints
    /// @return currentPrice_ price of pool after the most recent swap
    function oraclePrice(
        uint[] memory secondsAgos_
    ) external view returns (
        Oracle[] memory twaps_,
        uint currentPrice_
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Structs {
    struct PricesAndExchangePrice {
        uint lastStoredPrice; // last stored price in 1e27 decimals
        uint centerPrice; // last stored price in 1e27 decimals
        uint upperRange; // price at upper range in 1e27 decimals
        uint lowerRange; // price at lower range in 1e27 decimals
        uint geometricMean; // geometric mean of upper range & lower range in 1e27 decimals
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct ExchangePrices {
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct CollateralReserves {
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct CollateralReservesSwap {
        uint tokenInRealReserves;
        uint tokenOutRealReserves;
        uint tokenInImaginaryReserves;
        uint tokenOutImaginaryReserves;
    }

    struct DebtReserves {
        uint token0Debt;
        uint token1Debt;
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct DebtReservesSwap {
        uint tokenInDebt;
        uint tokenOutDebt;
        uint tokenInRealReserves;
        uint tokenOutRealReserves;
        uint tokenInImaginaryReserves;
        uint tokenOutImaginaryReserves;
    }

    struct SwapInMemory {
        address tokenIn;
        address tokenOut;
        uint256 amtInAdjusted;
        address withdrawTo;
        address borrowTo;
        uint price; // price of pool after swap
        uint fee; // fee of pool
        uint revenueCut; // revenue cut of pool
        bool swap0to1;
        int swapRoutingAmt;
        bytes data; // just added to avoid stack-too-deep error
    }

    struct SwapOutMemory {
        address tokenIn;
        address tokenOut;
        uint256 amtOutAdjusted;
        address withdrawTo;
        address borrowTo;
        uint price; // price of pool after swap
        uint fee;
        uint revenueCut; // revenue cut of pool
        bool swap0to1;
        int swapRoutingAmt;
        bytes data; // just added to avoid stack-too-deep error
        uint msgValue;
    }

    struct DepositColMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0ReservesInitial;
        uint256 token1ReservesInitial;
    }

    struct WithdrawColMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0ReservesInitial;
        uint256 token1ReservesInitial;
        address to;
    }

    struct BorrowDebtMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0DebtInitial;
        uint256 token1DebtInitial;
        address to;
    }

    struct PaybackDebtMemory {
        uint256 token0AmtAdjusted;
        uint256 token1AmtAdjusted;
        uint256 token0DebtInitial;
        uint256 token1DebtInitial;
    }

    struct OraclePriceMemory {
        uint lowestPrice1by0;
        uint highestPrice1by0;
        uint oracleSlot;
        uint oracleMap;
        uint oracle;
    }

    struct Oracle {
        uint twap1by0; // TWAP price
        uint lowestPrice1by0; // lowest price point
        uint highestPrice1by0; // highest price point
        uint twap0by1; // TWAP price
        uint lowestPrice0by1; // lowest price point
        uint highestPrice0by1; // highest price point
    }

    struct Implementations {
        address shift;
        address admin;
        address colOperations;
        address debtOperations;
        address perfectOperationsAndSwapOut;
    }

    struct ConstantViews {
        uint256 dexId;
        address liquidity;
        address factory;
        Implementations implementations;
        address deployerContract;
        address token0;
        address token1;
        bytes32 supplyToken0Slot;
        bytes32 borrowToken0Slot;
        bytes32 supplyToken1Slot;
        bytes32 borrowToken1Slot;
        bytes32 exchangePriceToken0Slot;
        bytes32 exchangePriceToken1Slot;
        uint256 oracleMapping;
    }

    struct ConstantViews2 {
        uint token0NumeratorPrecision;
        uint token0DenominatorPrecision;
        uint token1NumeratorPrecision;
        uint token1DenominatorPrecision;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { Owned } from "solmate/src/auth/Owned.sol";
import { SSTORE2 } from "solmate/src/utils/SSTORE2.sol";
import { CREATE3 } from "solmate/src/utils/CREATE3.sol";
import { ErrorTypes } from "../../errorTypes.sol";
import { Error } from "../../error.sol";

abstract contract Constants {
    address public immutable DEX_FACTORY;
    address public immutable LIQUIDITY;
}

abstract contract Variables is Owned {
    // ------------ storage variables from inherited contracts (Owned) come before vars here --------

    // ----------------------- slot 0 ---------------------------
    // address public owner;

    // 12 bytes empty

    // ----------------------- slot 1  ---------------------------
    /// @dev smart lending auths can update specific configs.
    /// owner can add/remove auths.
    /// Owner is auth by default.
    mapping(address => mapping(address => uint256)) internal _smartLendingAuths;

    // ----------------------- slot 2 ---------------------------
    /// @dev deployers can deploy new smartLendings.
    /// owner can add/remove deployers.
    /// Owner is deployer by default.
    mapping(address => uint256) internal _deployers;

    // ----------------------- slot 3 ---------------------------
    /// @notice list of all created tokens.
    /// @dev Solidity creates an automatic getter only to fetch at a certain position, so explicitly define a getter that returns all.
    address[] public createdTokens;

    // ----------------------- slot 4 ---------------------------

    /// @dev smart lending creation code, accessed via SSTORE2.
    address internal _smartLendingCreationCodePointer;

    /*//////////////////////////////////////////////////////////////
                          CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address owner_) Owned(owner_) {}
}

abstract contract Events {
    /// @dev Emitted when a new smart lending is deployed
    /// @param dexId The ID of the deployed DEX
    /// @param smartLending The address of the deployed smart lending
    event LogSmartLendingDeployed(uint256 dexId, address smartLending);

    /// @dev Emitted when a SmartLending auth is updated
    /// @param smartLending address of SmartLending
    /// @param auth address of auth whose status is being updated
    /// @param allowed updated status of auth
    event LogAuthUpdated(address smartLending, address auth, bool allowed);

    /// @dev Emitted when a deployer is modified by owner
    /// @param deployer address of deployer
    /// @param allowed updated status of deployer
    event LogDeployerUpdated(address deployer, bool allowed);

    /// @dev Emitted when the smart lending creation code is modified by owner
    /// @param creationCodePointer address of the creation code pointer
    event LogSetCreationCode(address creationCodePointer);
}

contract FluidSmartLendingFactory is Constants, Variables, Events, Error {
    /// @dev Validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidSmartLendingFactoryError(ErrorTypes.SmartLendingFactory__ZeroAddress);
        }
        _;
    }

    constructor(
        address dexFactory_,
        address liquidity_,
        address owner_
    ) validAddress(dexFactory_) validAddress(liquidity_) validAddress(owner_) Variables(owner_) {
        LIQUIDITY = liquidity_;
        DEX_FACTORY = dexFactory_;
    }

    /// @dev Validates that msg.sender is deployer or owner
    modifier onlyDeployers() {
        if (!isDeployer(msg.sender)) {
            revert FluidSmartLendingFactoryError(ErrorTypes.SmartLendingFactory__Unauthorized);
        }
        _;
    }

    /// @notice List of all created tokens
    function allTokens() public view returns (address[] memory) {
        return createdTokens;
    }

    /// @notice Reads if a certain `auth_` address is an allowed auth for `smartLending_` or not. Owner is auth by default.
    function isSmartLendingAuth(address smartLending_, address auth_) public view returns (bool) {
        return auth_ == owner || _smartLendingAuths[smartLending_][auth_] == 1;
    }

    /// @notice Reads if a certain `deployer_` address is an allowed deployer or not. Owner is deployer by default.
    function isDeployer(address deployer_) public view returns (bool) {
        return deployer_ == owner || _deployers[deployer_] == 1;
    }

    /// @dev Retrieves the creation code for the SmartLending contract
    function smartLendingCreationCode() public view returns (bytes memory) {
        return SSTORE2.read(_smartLendingCreationCodePointer);
    }

    /// @notice Sets an address as allowed deployer or not. Only callable by owner.
    /// @param deployer_ Address to set deployer value for
    /// @param allowed_ Bool flag for whether address is allowed as deployer or not
    function updateDeployer(address deployer_, bool allowed_) external onlyOwner validAddress(deployer_) {
        _deployers[deployer_] = allowed_ ? 1 : 0;

        emit LogDeployerUpdated(deployer_, allowed_);
    }

    /// @notice Updates the authorization status of an address for a SmartLending contract. Only callable by owner.
    /// @param smartLending_ The address of the SmartLending contract
    /// @param auth_ The address to be updated
    /// @param allowed_ The new authorization status
    function updateSmartLendingAuth(
        address smartLending_,
        address auth_,
        bool allowed_
    ) external validAddress(smartLending_) validAddress(auth_) onlyOwner {
        _smartLendingAuths[smartLending_][auth_] = allowed_ ? 1 : 0;

        emit LogAuthUpdated(smartLending_, auth_, allowed_);
    }

    /// @notice Sets the `creationCode_` bytecode for new SmartLending contracts. Only callable by owner.
    /// @param creationCode_ New SmartLending contract creation code.
    function setSmartLendingCreationCode(bytes calldata creationCode_) external onlyOwner {
        if (creationCode_.length == 0) {
            revert FluidSmartLendingFactoryError(ErrorTypes.SmartLendingFactory__InvalidParams);
        }

        // write creation code to SSTORE2 pointer and set in mapping
        address creationCodePointer_ = SSTORE2.write(creationCode_);
        _smartLendingCreationCodePointer = creationCodePointer_;

        emit LogSetCreationCode(creationCodePointer_);
    }

    /// @notice Spell allows owner aka governance to do any arbitrary call on factory
    /// @param target_ Address to which the call needs to be delegated
    /// @param data_ Data to execute at the delegated address
    function spell(address target_, bytes memory data_) external onlyOwner returns (bytes memory response_) {
        assembly {
            let succeeded := delegatecall(gas(), target_, add(data_, 0x20), mload(data_), 0, 0)
            let size := returndatasize()

            response_ := mload(0x40)
            mstore(0x40, add(response_, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response_, size)
            returndatacopy(add(response_, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    /// @notice Deploys a new SmartLending contract. Only callable by deployers.
    /// @param dexId_ The ID of the DEX for which the smart lending wrapper is being deployed
    /// @return smartLending_ The newly deployed SmartLending contract
    function deploy(uint256 dexId_) public onlyDeployers returns (address smartLending_) {
        if (getSmartLendingAddress(dexId_).code.length != 0) {
            revert FluidSmartLendingFactoryError(ErrorTypes.SmartLendingFactory__AlreadyDeployed);
        }

        // Use CREATE3 for deterministic deployments. Unfortunately it has 55k gas overhead
        smartLending_ = CREATE3.deploy(
            _getSalt(dexId_),
            abi.encodePacked(
                SSTORE2.read(_smartLendingCreationCodePointer), // creation code
                abi.encode(dexId_, LIQUIDITY, DEX_FACTORY, address(this)) // constructor params
            ),
            0
        );

        createdTokens.push(smartLending_); // Add the created token to the allTokens array

        emit LogSmartLendingDeployed(dexId_, smartLending_);
    }

    /// @notice Computes the address of a SmartLending contract based on a given dexId.
    /// @param dexId_ The ID of the DEX for which the SmartLending contract address is being computed.
    /// @return The computed address of the SmartLending contract.
    function getSmartLendingAddress(uint256 dexId_) public view returns (address) {
        return CREATE3.getDeployed(_getSalt(dexId_));
    }

    /// @notice Returns the total number of SmartLending contracts deployed by the factory.
    /// @return The total number of SmartLending contracts deployed.
    function totalSmartLendings() external view returns (uint256) {
        return createdTokens.length;
    }

    /// @notice                         Checks if a given address (`smartLending_`) corresponds to a valid smart lending.
    /// @param smartLending_            The smart lending address to check.
    /// @return                         Returns `true` if the given address corresponds to a valid smart lending, otherwise `false`.
    function isSmartLending(address smartLending_) public view returns (bool) {
        if (smartLending_.code.length == 0) {
            return false;
        } else {
            // DEX() function signature is 0x80935aa9
            (bool success_, bytes memory data_) = smartLending_.staticcall(hex"80935aa9");
            address dex_ = abi.decode(data_, (address));
            // DEX_ID() function signature is 0xf4b9a3fb
            (success_, data_) = dex_.staticcall(hex"f4b9a3fb");
            return success_ && smartLending_ == getSmartLendingAddress(abi.decode(data_, (uint256)));
        }
    }

    /// @dev unique deployment salt for the smart lending
    function _getSalt(uint256 dexId_) internal pure returns (bytes32) {
        return keccak256(abi.encode(dexId_));
    }

    /// @dev Deploys a contract using the CREATE opcode with the provided bytecode (`bytecode_`).
    /// This is an internal function, meant to be used within the contract to facilitate the deployment of other contracts.
    /// @param bytecode_ The bytecode of the contract to be deployed.
    /// @return address_ Returns the address of the deployed contract.
    function _deploy(bytes memory bytecode_) internal returns (address address_) {
        if (bytecode_.length == 0) {
            revert FluidDexError(ErrorTypes.SmartLendingFactory__InvalidOperation);
        }
        /// @solidity memory-safe-assembly
        assembly {
            address_ := create(0, add(bytecode_, 0x20), mload(bytecode_))
        }
        if (address_ == address(0)) {
            revert FluidDexError(ErrorTypes.SmartLendingFactory__InvalidOperation);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IFluidDexT1 } from "../interfaces/iDexT1.sol";
import { FluidDexFactory } from "../factory/main.sol";
import { FluidSmartLendingFactory } from "./factory/main.sol";
import { SafeTransfer } from "../../../libraries/safeTransfer.sol";
import { ErrorTypes } from "../errorTypes.sol";
import { Error } from "../error.sol";
import { DexSlotsLink } from "../../../libraries/dexSlotsLink.sol";
import { DexCalcs } from "../../../libraries/dexCalcs.sol";

abstract contract Constants {
    /// @dev Ignoring leap years
    uint256 internal constant SECONDS_PER_YEAR = 365 days;

    address internal constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address internal constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    FluidDexFactory public immutable DEX_FACTORY;

    FluidSmartLendingFactory public immutable SMART_LENDING_FACTORY;

    IFluidDexT1 public immutable DEX;

    address public immutable LIQUIDITY;

    address public immutable TOKEN0;

    address public immutable TOKEN1;

    bool public immutable IS_NATIVE_PAIR;
}

abstract contract Variables is ERC20, Constants {
    // ------------ storage variables from inherited contracts come before vars here --------
    // _________ ERC20 _______________
    // ----------------------- slot 0 ---------------------------
    // mapping(address => uint256) private _balances;

    // ----------------------- slot 1 ---------------------------
    // mapping(address => mapping(address => uint256)) private _allowances;

    // ----------------------- slot 2 ---------------------------
    // uint256 private _totalSupply;

    // ----------------------- slot 3 ---------------------------
    // string private _name;
    // ----------------------- slot 4 ---------------------------
    // string private _symbol;

    // ------------ storage variables ------------------------------------------------------

    // ----------------------- slot 5 ---------------------------
    uint40 public lastTimestamp;
    /// If positive then rewards, if negative then fee.
    /// 1e6 = 100%, 1e4 = 1%, minimum 0.0001% fee or reward.
    int32 public feeOrReward;
    // Starting from 1e18
    // If fees then reduce exchange price
    // If reward then increase exchange price
    uint184 public exchangePrice;

    // ----------------------- slot 6 ---------------------------
    address public rebalancer;

    // ----------------------- slot 7 ---------------------------
    address public dexFromAddress;

    /// @dev status for reentrancy guard
    uint8 internal _status;
}

abstract contract Events {
    /// @dev Emitted when the share to tokens ratio is rebalanced
    /// @param shares_ The number of shares rebalanced
    /// @param token0Amt_ The amount of token0 rebalanced
    /// @param token1Amt_ The amount of token1 rebalanced
    /// @param isWithdraw_ Whether the rebalance is a withdrawal or deposit
    event LogRebalance(uint256 shares_, uint256 token0Amt_, uint256 token1Amt_, bool isWithdraw_);

    /// @dev Emitted when the rebalancer is set
    /// @param rebalancer The new rebalancer
    event LogRebalancerSet(address rebalancer);

    /// @dev Emitted when the fee or reward is set
    /// @param feeOrReward The new fee or reward
    event LogFeeOrRewardSet(int256 feeOrReward);
}

/// @dev ReentrancyGuard based on OpenZeppelin implementation.
/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/security/ReentrancyGuard.sol
abstract contract ReentrancyGuard is Variables, Error {
    uint8 internal constant REENTRANCY_NOT_ENTERED = 1;
    uint8 internal constant REENTRANCY_ENTERED = 2;

    constructor() {
        _status = REENTRANCY_NOT_ENTERED;
    }

    /// @dev Prevents a contract from calling itself, directly or indirectly.
    /// See OpenZeppelin implementation for more info
    modifier nonReentrant() {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status != REENTRANCY_NOT_ENTERED) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__Reentrancy);
        }

        // Any calls to nonReentrant after this point will fail
        _status = REENTRANCY_ENTERED;

        _;

        // storing original value triggers a refund (see https://eips.ethereum.org/EIPS/eip-2200)
        _status = REENTRANCY_NOT_ENTERED;
    }
}

contract FluidSmartLending is ERC20, Variables, Error, ReentrancyGuard, Events {
    /// @dev prefix for token name. constructor appends dex id, e.g. "Fluid Smart Lending 12"
    string private constant TOKEN_NAME_PREFIX = "Fluid Smart Lending ";
    /// @dev prefix for token symbol. constructor appends dex id, e.g. "fSL12"
    string private constant TOKEN_SYMBOL_PREFIX = "fSL";

    /// @dev Validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__ZeroAddress);
        }
        _;
    }

    constructor(
        uint256 dexId_,
        address liquidity_,
        address dexFactory_,
        address smartLendingFactory_
    )
        ERC20(
            string(abi.encodePacked(TOKEN_NAME_PREFIX, _toString(dexId_))),
            string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _toString(dexId_)))
        )
        validAddress(liquidity_)
        validAddress(dexFactory_)
        validAddress(smartLendingFactory_)
    {
        LIQUIDITY = liquidity_;
        DEX_FACTORY = FluidDexFactory(dexFactory_);
        SMART_LENDING_FACTORY = FluidSmartLendingFactory(smartLendingFactory_);
        DEX = IFluidDexT1(DEX_FACTORY.getDexAddress(dexId_));
        IFluidDexT1.ConstantViews memory constants_ = DEX.constantsView();
        TOKEN0 = constants_.token0;
        TOKEN1 = constants_.token1;
        IS_NATIVE_PAIR = (TOKEN0 == ETH_ADDRESS) || (TOKEN1 == ETH_ADDRESS);

        exchangePrice = uint184(1e18);
        feeOrReward = int32(0);
        lastTimestamp = uint40(block.timestamp);

        dexFromAddress = DEAD_ADDRESS;
    }

    modifier setDexFrom() {
        dexFromAddress = msg.sender;
        _;
        dexFromAddress = DEAD_ADDRESS;
    }

    modifier onlyAuth() {
        if (!SMART_LENDING_FACTORY.isSmartLendingAuth(address(this), msg.sender)) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__Unauthorized);
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != SMART_LENDING_FACTORY.owner()) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__Unauthorized);
        }
        _;
    }

    modifier _updateExchangePrice() {
        bool rewardsOrFeeActive_;
        (exchangePrice, rewardsOrFeeActive_) = getUpdateExchangePrice();
        if (rewardsOrFeeActive_) {
            lastTimestamp = uint40(block.timestamp); // only write to storage if fee or reward is active.
        }
        _;
    }

    /// @notice gets updated exchange price
    function getUpdateExchangePrice() public view returns (uint184 exchangePrice_, bool rewardsOrFeeActive_) {
        int256 feeOrReward_ = feeOrReward;
        exchangePrice_ = exchangePrice;
        if (feeOrReward_ > 0) {
            exchangePrice_ =
                exchangePrice_ +
                uint184(
                    (exchangePrice_ * uint256(feeOrReward_) * (block.timestamp - uint256(lastTimestamp))) /
                        (1e6 * SECONDS_PER_YEAR)
                );
            rewardsOrFeeActive_ = true;
        } else if (feeOrReward_ < 0) {
            exchangePrice_ =
                exchangePrice_ -
                uint184(
                    (exchangePrice_ * uint256(-feeOrReward_) * (block.timestamp - uint256(lastTimestamp))) /
                        (1e6 * SECONDS_PER_YEAR)
                );
            rewardsOrFeeActive_ = true;
        }
    }

    /// @notice triggers updateExchangePrice
    function updateExchangePrice() public _updateExchangePrice {}

    /// @dev Set the fee or reward. Only callable by auths.
    /// @param feeOrReward_ The new fee or reward (1e6 = 100%, 1e4 = 1%, minimum 0.0001% fee or reward). 0 means no fee or reward
    function setFeeOrReward(int256 feeOrReward_) external onlyAuth _updateExchangePrice {
        if (feeOrReward_ > 1e6 || feeOrReward_ < -1e6) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__OutOfRange);
        }
        lastTimestamp = uint40(block.timestamp); // current fee or reward setting is applied until exactly now even if previously 0
        feeOrReward = int32(feeOrReward_);

        emit LogFeeOrRewardSet(feeOrReward_);
    }

    /// @dev Set the rebalancer. Only callable by auths.
    /// @param rebalancer_ The new rebalancer
    function setRebalancer(address rebalancer_) external onlyAuth validAddress(rebalancer_) {
        rebalancer = rebalancer_;

        emit LogRebalancerSet(rebalancer_);
    }

    /// @notice                         Spell allows auths (governance) to do any arbitrary call
    /// @param target_                  Address to which the call needs to be delegated
    /// @param data_                    Data to execute at the delegated address
    function spell(address target_, bytes memory data_) external onlyOwner returns (bytes memory response_) {
        assembly {
            let succeeded := delegatecall(gas(), target_, add(data_, 0x20), mload(data_), 0, 0)
            let size := returndatasize()

            response_ := mload(0x40)
            mstore(0x40, add(response_, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response_, size)
            returndatacopy(add(response_, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    /// @dev Deposit tokens in equal proportion to the current pool ratio
    /// @param shares_ The number of shares to mint
    /// @param maxToken0Deposit_ Maximum amount of token0 to deposit
    /// @param maxToken1Deposit_ Maximum amount of token1 to deposit
    /// @param to_ Recipient of minted tokens. If to_ == address(0) then out tokens will be sent to msg.sender.
    /// @return amount_ Amount of tokens minted
    /// @return token0Amt_ Amount of token0 deposited
    /// @return token1Amt_ Amount of token1 deposited
    function depositPerfect(
        uint256 shares_,
        uint256 maxToken0Deposit_,
        uint256 maxToken1Deposit_,
        address to_
    )
        external
        payable
        setDexFrom
        _updateExchangePrice
        nonReentrant
        returns (uint256 amount_, uint256 token0Amt_, uint256 token1Amt_)
    {
        if (!IS_NATIVE_PAIR) {
            if (msg.value > 0) {
                revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidMsgValue);
            }

            (token0Amt_, token1Amt_) = DEX.depositPerfect(
                shares_ + 1, // + 1 rounding up but only minting shares
                maxToken0Deposit_,
                maxToken1Deposit_,
                false
            );
        } else {
            uint256 value_ = TOKEN0 == ETH_ADDRESS ? maxToken0Deposit_ : maxToken1Deposit_;
            if (value_ > msg.value) {
                revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidMsgValue);
            }

            uint256 initialEthAmount_ = address(this).balance - msg.value;

            (token0Amt_, token1Amt_) = DEX.depositPerfect{ value: value_ }(
                shares_ + 1, // + 1 rounding up but only minting shares
                maxToken0Deposit_,
                maxToken1Deposit_,
                false
            );

            uint finalEth_ = payable(address(this)).balance;
            if (finalEth_ > initialEthAmount_) {
                unchecked {
                    SafeTransfer.safeTransferNative(msg.sender, finalEth_ - initialEthAmount_); // sending back excess ETH
                }
            }
        }

        to_ = to_ == address(0) ? msg.sender : to_;

        amount_ = (shares_ * 1e18) / exchangePrice;

        _mint(to_, amount_);
    }

    /// @dev This function allows users to deposit tokens in any proportion into the col pool
    /// @param token0Amt_ The amount of token0 to deposit
    /// @param token1Amt_ The amount of token1 to deposit
    /// @param minSharesAmt_ The minimum amount of shares the user expects to receive
    /// @param to_ Recipient of minted tokens. If to_ == address(0) then out tokens will be sent to msg.sender.
    /// @return amount_ The amount of tokens minted for the deposit
    /// @return shares_ The number of dex pool shares deposited
    function deposit(
        uint256 token0Amt_,
        uint256 token1Amt_,
        uint256 minSharesAmt_,
        address to_
    ) external payable setDexFrom _updateExchangePrice nonReentrant returns (uint256 amount_, uint256 shares_) {
        uint256 value_ = !IS_NATIVE_PAIR
            ? 0
            : (TOKEN0 == ETH_ADDRESS)
                ? token0Amt_
                : token1Amt_;

        if (value_ != msg.value) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidMsgValue);
        }

        to_ = to_ == address(0) ? msg.sender : to_;

        shares_ = DEX.deposit{ value: value_ }(token0Amt_, token1Amt_, minSharesAmt_, false);

        amount_ = (shares_ * 1e18) / exchangePrice - 1;

        _mint(to_, amount_);
    }

    /// @dev This function allows users to withdraw a perfect amount of collateral liquidity
    /// @param shares_ The number of shares to withdraw. set to type(uint).max to withdraw maximum balance.
    /// @param minToken0Withdraw_ The minimum amount of token0 the user is willing to accept
    /// @param minToken1Withdraw_ The minimum amount of token1 the user is willing to accept
    /// @param to_ Recipient of withdrawn tokens. If to_ == address(0) then out tokens will be sent to msg.sender.
    /// @return amount_ amount_ of shares actually burnt
    /// @return token0Amt_ The amount of token0 withdrawn
    /// @return token1Amt_ The amount of token1 withdrawn
    function withdrawPerfect(
        uint256 shares_,
        uint256 minToken0Withdraw_,
        uint256 minToken1Withdraw_,
        address to_
    ) external _updateExchangePrice nonReentrant returns (uint256 amount_, uint256 token0Amt_, uint256 token1Amt_) {
        if (shares_ == type(uint).max) {
            amount_ = balanceOf(msg.sender);
            shares_ = (amount_ * exchangePrice) / 1e18 - 1;
        } else {
            amount_ = (shares_ * 1e18) / exchangePrice + 1;
        }

        _burn(msg.sender, amount_);

        to_ = to_ == address(0) ? msg.sender : to_;

        if (minToken0Withdraw_ > 0 && minToken1Withdraw_ > 0) {
            (token0Amt_, token1Amt_) = DEX.withdrawPerfect(shares_, minToken0Withdraw_, minToken1Withdraw_, to_);
        } else if (minToken0Withdraw_ > 0 && minToken1Withdraw_ == 0) {
            // withdraw only in token0, token1Amt_ remains 0
            (token0Amt_) = DEX.withdrawPerfectInOneToken(shares_, minToken0Withdraw_, minToken1Withdraw_, to_);
        } else if (minToken0Withdraw_ == 0 && minToken1Withdraw_ > 0) {
            // withdraw only in token1, token0Amt_ remains 0
            (token1Amt_) = DEX.withdrawPerfectInOneToken(token0Amt_, minToken0Withdraw_, minToken1Withdraw_, to_);
        } else {
            // meaning user sent both amounts as == 0
            revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidAmounts);
        }
    }

    /// @dev This function allows users to withdraw tokens in any proportion from the col pool
    /// @param token0Amt_ The amount of token0 to withdraw
    /// @param token1Amt_ The amount of token1 to withdraw
    /// @param maxSharesAmt_ The maximum number of shares the user is willing to burn
    /// @param to_ Recipient of withdrawn tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return amount_ The number of tokens burned for the withdrawal
    /// @return shares_ The number of dex pool shares withdrawn
    function withdraw(
        uint256 token0Amt_,
        uint256 token1Amt_,
        uint256 maxSharesAmt_,
        address to_
    ) external _updateExchangePrice nonReentrant returns (uint256 amount_, uint256 shares_) {
        to_ = to_ == address(0) ? msg.sender : to_;

        shares_ = DEX.withdraw(token0Amt_, token1Amt_, maxSharesAmt_, to_);

        amount_ = (shares_ * 1e18) / exchangePrice + 1;

        _burn(msg.sender, amount_);
    }

    /// @dev Rebalances the share to tokens ratio to balance out rewards and fees
    function rebalance(
        uint256 minOrMaxToken0_,
        uint256 minOrMaxToken1_
    )
        public
        payable
        _updateExchangePrice
        nonReentrant
        returns (uint256 shares_, uint256 token0Amt_, uint256 token1Amt_, bool isWithdraw_)
    {
        if (rebalancer != msg.sender) revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidRebalancer);

        int256 rebalanceDiff_ = rebalanceDiff();

        if (rebalanceDiff_ > 0) {
            // fees (withdraw)
            isWithdraw_ = true;
            if (msg.value > 0) {
                revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidMsgValue);
            }
            shares_ = uint256(rebalanceDiff_);
            (token0Amt_, token1Amt_) = DEX.withdrawPerfect(shares_, minOrMaxToken0_, minOrMaxToken1_, msg.sender);
        } else if (rebalanceDiff_ < 0) {
            // rewards (deposit)
            isWithdraw_ = false;

            uint256 initialEthAmount_ = address(this).balance - msg.value;

            uint256 value_ = !IS_NATIVE_PAIR
                ? 0
                : (TOKEN0 == ETH_ADDRESS)
                    ? minOrMaxToken0_
                    : minOrMaxToken1_;

            if (value_ > msg.value) {
                revert FluidSmartLendingError(ErrorTypes.SmartLending__InvalidMsgValue);
            }

            shares_ = uint256(-rebalanceDiff_);

            dexFromAddress = msg.sender;
            (token0Amt_, token1Amt_) = DEX.depositPerfect{ value: value_ }(
                shares_,
                minOrMaxToken0_,
                minOrMaxToken1_,
                false
            );
            dexFromAddress = DEAD_ADDRESS;

            uint finalEth_ = payable(address(this)).balance;
            if (finalEth_ > initialEthAmount_) {
                unchecked {
                    SafeTransfer.safeTransferNative(msg.sender, finalEth_ - initialEthAmount_); // sending back excess ETH
                }
            }
        }

        emit LogRebalance(shares_, token0Amt_, token1Amt_, isWithdraw_);
    }

    /// @dev Returns the difference between the total smart lending shares on the DEX and the total smart lending shares calculated.
    /// A positive value indicates fees to collect, while a negative value indicates rewards to be rebalanced.
    function rebalanceDiff() public view returns (int256) {
        uint256 totalSmartLendingSharesOnDex_ = DEX.readFromStorage(
            DexSlotsLink.calculateMappingStorageSlot(DexSlotsLink.DEX_USER_SUPPLY_MAPPING_SLOT, address(this))
        );
        totalSmartLendingSharesOnDex_ =
            (totalSmartLendingSharesOnDex_ >> DexSlotsLink.BITS_USER_SUPPLY_AMOUNT) &
            DexCalcs.X64;
        totalSmartLendingSharesOnDex_ =
            (totalSmartLendingSharesOnDex_ >> DexCalcs.DEFAULT_EXPONENT_SIZE) <<
            (totalSmartLendingSharesOnDex_ & DexCalcs.DEFAULT_EXPONENT_MASK);

        uint256 totalSmartLendingShares_ = (totalSupply() * exchangePrice) / 1e18;

        return int256(totalSmartLendingSharesOnDex_) - int256(totalSmartLendingShares_);
    }

    /// @notice   dex liquidity callback
    /// @param    token_ The token being transferred
    /// @param    amount_ The amount being transferred
    function dexCallback(address token_, uint256 amount_) external {
        if (msg.sender != address(DEX)) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__Unauthorized);
        }
        SafeTransfer.safeTransferFrom(token_, dexFromAddress, LIQUIDITY, amount_);
    }

    /// @dev for excess eth being sent back from dex to here
    receive() external payable {
        if (msg.sender != address(DEX)) {
            revert FluidSmartLendingError(ErrorTypes.SmartLending__Unauthorized);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     * taken from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol
     */
    function _log10(uint256 value) internal pure returns (uint256) {
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
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     * taken from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol
     */
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    function _toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = _log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Library for converting between addresses and bytes32 values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Bytes32AddressLib.sol)
library Bytes32AddressLib {
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {
        return bytes32(bytes20(addressValue));
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {Bytes32AddressLib} from "./Bytes32AddressLib.sol";

/// @notice Deploy to deterministic addresses without an initcode factor.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/CREATE3.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/create3/blob/master/contracts/Create3.sol)
library CREATE3 {
    using Bytes32AddressLib for bytes32;

    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //
    // 0x37       |  0x37                 | CALLDATACOPY     |                        //
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //
    // 0xf0       |  0xf0                 | CREATE           | newContract            //
    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //
    // 0x52       |  0x52                 | MSTORE           |                        //
    // 0x60       |  0x6008               | PUSH1 08         | 8                      //
    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //
    // 0xf3       |  0xf3                 | RETURN           |                        //
    //--------------------------------------------------------------------------------//
    bytes internal constant PROXY_BYTECODE = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

    bytes32 internal constant PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);

    function deploy(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address deployed) {
        bytes memory proxyChildBytecode = PROXY_BYTECODE;

        address proxy;
        /// @solidity memory-safe-assembly
        assembly {
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            // We start 32 bytes into the code to avoid copying the byte length.
            proxy := create2(0, add(proxyChildBytecode, 32), mload(proxyChildBytecode), salt)
        }
        require(proxy != address(0), "DEPLOYMENT_FAILED");

        deployed = getDeployed(salt);
        (bool success, ) = proxy.call{value: value}(creationCode);
        require(success && deployed.code.length != 0, "INITIALIZATION_FAILED");
    }

    function getDeployed(bytes32 salt) internal view returns (address) {
        address proxy = keccak256(
            abi.encodePacked(
                // Prefix:
                bytes1(0xFF),
                // Creator:
                address(this),
                // Salt:
                salt,
                // Bytecode hash:
                PROXY_BYTECODE_HASH
            )
        ).fromLast20Bytes();

        return
            keccak256(
                abi.encodePacked(
                    // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)
                    // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)
                    hex"d6_94",
                    proxy,
                    hex"01" // Nonce of the proxy contract (1)
                )
            ).fromLast20Bytes();
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1; // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.

    /*//////////////////////////////////////////////////////////////
                               WRITE LOGIC
    //////////////////////////////////////////////////////////////*/

    function write(bytes memory data) internal returns (address pointer) {
        // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        bytes memory creationCode = abi.encodePacked(
            //---------------------------------------------------------------------------------------------------------------//
            // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
            //---------------------------------------------------------------------------------------------------------------//
            // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
            // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
            // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
            // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
            // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
            // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
            // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
            // 0xf3    |  0xf3               | RETURN       |                                                                //
            //---------------------------------------------------------------------------------------------------------------//
            hex"60_0B_59_81_38_03_80_92_59_39_F3", // Returns all code in the contract except for the first 11 (0B in hex) bytes.
            runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
        );

        /// @solidity memory-safe-assembly
        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), "DEPLOYMENT_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                               READ LOGIC
    //////////////////////////////////////////////////////////////*/

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory) {
        start += DATA_OFFSET;

        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        require(pointer.code.length >= end, "OUT_OF_BOUNDS");

        return readBytecode(pointer, start, end - start);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}