// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface   IERC20 {
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
/**
 * @title ERC20Relayer
 * @author contact@erc-hub.com
 * @notice ERC741 token standard, ERC20 & ERC721 synthetic token standard.
 * Because it follows the logical rules of how it inherently works, it can take advantage of existing indexers.
 * email: contact@erc-hub.com
 * website: https://erc-hub.com
 * github: https://github.com/erc-hub/ERC741
 * twitter: https://twitter.com/ERC_Hub
 * telegram: https://t.me/ERC_Hub
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ISemiFungibleERC741.sol";

contract ERC20Relayer is IERC20, IERC20Metadata, Context {
    ISemiFungibleERC741 public erc741;

    modifier onlyNFT() {
        require(
            _msgSender() == address(erc741),
            "onlyNFT can call this function"
        );
        _;
    }

    constructor() {
        erc741 = ISemiFungibleERC741(_msgSender());
    }

    function name() external view override returns (string memory) {
        return erc741.name();
    }

    function symbol() external view override returns (string memory) {
        return erc741.symbol();
    }

    function decimals() external view override returns (uint8) {
        return erc741._decimals();
    }

    function totalSupply() external view override returns (uint256) {
        return erc741._erc20Supply();
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return erc741.balanceOfERC20(account);
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        bool status = erc741.transferERC20(_msgSender(), to, amount);
        emit Transfer(_msgSender(), to, amount);
        return status;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return erc741.allowance(owner, spender);
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        bool status = erc741.approveERC20(_msgSender(), spender, amount);
        emit Approval(_msgSender(), spender, amount);
        return status;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        bool status = erc741.transferFromERC20(_msgSender(), from, to, amount);
        emit Transfer(from, to, amount);
        return status;
    }

    function emitTransfer(
        address from,
        address to,
        uint256 amount
    ) external onlyNFT {
        emit Transfer(from, to, amount);
    }
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

interface ISemiFungibleERC741 {
    function allowance(address, address) external view returns (uint256);

    function approve(
        address spender,
        uint256 amountOrId
    ) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function balanceOfERC20(address) external view returns (uint256);

    function baseTokenURI() external view returns (string memory);

    function _decimals() external view returns (uint8);

    function erc721totalSupply() external view returns (uint256);

    function getApproved(uint256) external view returns (address);

    function getBurnedToken() external view returns (uint256[] memory);

    function isApprovedForAll(address, address) external view returns (bool);

    function maxMintedId() external view returns (uint256);

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function ownerOf(uint256 id) external view returns (address owner);

    function renounceOwnership() external;

    function safeTransferFrom(address from, address to, uint256 id) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setTokenURI(string memory _tokenURI) external;

    function setWhitelist(address target, bool state) external;

    function symbol() external view returns (string memory);

    function tokenIdPool(uint256) external view returns (uint256);

    function tokenURI(uint256 id) external returns (string memory);

    function _erc20Supply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amountOrId
    ) external;

    function transferOwnership(address newOwner) external;

    function whitelist(address) external view returns (bool);

    function transferERC20(
        address sender,
        address to,
        uint256 amount
    ) external returns (bool);

    function transferFromERC20(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approveERC20(
        address sender,
        address spender,
        uint256 amountOrId
    ) external returns (bool);
}