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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.27;

import {IERC20} from
    "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title Wrapper
/// @author Morpho Association
/// @custom:security-contact security@morpho.org
/// @notice The Wrapper contract to migrate from legacy MORPHO tokens.
contract Wrapper {
    /* CONSTANTS */

    /// @notice The address of the legacy Morpho token.
    address public constant LEGACY_MORPHO = 0x9994E35Db50125E0DF82e4c2dde62496CE330999;

    /* IMMUTABLES */

    /// @notice The address of the new Morpho token.
    address public immutable NEW_MORPHO;

    /* ERRORS */

    /// @notice Reverts if the address is the zero address.
    error ZeroAddress();

    /// @notice Reverts if the address is the contract address.
    error SelfAddress();

    /* CONSTRUCTOR */

    /// @dev morphoToken address can be precomputed using create2.
    constructor(address morphoToken) {
        require(morphoToken != address(0), ZeroAddress());

        NEW_MORPHO = morphoToken;
    }

    /* EXTERNAL */

    /// @dev Compliant to `ERC20Wrapper` contract from OZ for convenience.
    function depositFor(address account, uint256 value) external returns (bool) {
        require(account != address(0), ZeroAddress());
        require(account != address(this), SelfAddress());

        IERC20(LEGACY_MORPHO).transferFrom(msg.sender, address(this), value);
        IERC20(NEW_MORPHO).transfer(account, value);
        return true;
    }

    /// @dev Compliant to `ERC20Wrapper` contract from OZ for convenience.
    function withdrawTo(address account, uint256 value) external returns (bool) {
        require(account != address(0), ZeroAddress());
        require(account != address(this), SelfAddress());

        IERC20(NEW_MORPHO).transferFrom(msg.sender, address(this), value);
        IERC20(LEGACY_MORPHO).transfer(account, value);
        return true;
    }

    /// @dev To ease wrapping via the bundler contract:
    /// https://github.com/morpho-org/morpho-blue-bundlers/blob/main/src/ERC20WrapperBundler.sol
    function underlying() external pure returns (address) {
        return LEGACY_MORPHO;
    }
}