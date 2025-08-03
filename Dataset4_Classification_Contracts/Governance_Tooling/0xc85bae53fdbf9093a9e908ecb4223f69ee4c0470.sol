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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
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
// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

import {IWETH} from './interfaces/IWETH.sol';
import {IWETHGateway} from './interfaces/IWETHGateway.sol';
import {IDragonDistributor} from './interfaces/IDragonDistributor.sol';

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';


contract WETHGateway is IWETHGateway, Ownable2Step {

    IWETH internal immutable WETH;
    mapping(address => uint256) public balanceOf;

    constructor(address weth) Ownable(msg.sender) {
        WETH = IWETH(weth);
    }

    function authorizeDistributor(address distributor) external onlyOwner {
        WETH.approve(distributor, type(uint256).max);
    }

    function mintB(address distributor, address receiver, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable override {
        WETH.deposit{value: msg.value}();
        IDragonDistributor(distributor).mintB(receiver, msg.value, deadline, v, r, s);
    }

    function publicMint(address distributor, address receiver, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable override {
        WETH.deposit{value: msg.value}();
        IDragonDistributor(distributor).publicMint(receiver, msg.value, deadline, v, r, s);
    }

    /**
    * @dev transfer ETH to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'ETH_TRANSFER_FAILED');
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function emergencyTokenTransfer(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due selfdestructs or transfer ether to pre-computated contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function emergencyEtherTransfer(address to, uint256 amount) external onlyOwner {
        _safeTransferETH(to, amount);
    }

    /**
    * @dev Get WETH address used by WETHGateway
    */
    function getWETHAddress() external view returns (address) {
        return address(WETH);
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(msg.sender == address(WETH), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert('Fallback not allowed');
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDragonDistributor {
    event Initialize(address indexed dragonOG, uint256 startTimeA, uint256 endTimeA, 
                     uint256 startTimeB, uint256 endTimeB, uint256 startTimePublic, uint256 endTimePublic);

    event UpdateBaseURI(string baseURI);

    event WhiteListAAdded(address indexed user, uint256 count);
    event WhiteListARemoved(address indexed user);

    event WhiteListBAdded(address indexed user, uint256 count);
    event WhiteListBRemoved(address indexed user);

    event MintA(address indexed user, uint256 indexed id);
    event MintB(address indexed user, uint256 indexed id);
    event PublicMint(address indexed user, uint256 indexed id);

    /**
     * @dev Mint a dragon for ``receiver``,
     * given ``owner()``'s signed approval.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner()`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``receiver``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function mintA(address receiver, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function mintB(address receiver, uint256 price, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function publicMint(address receiver, uint256 price, uint256 deadline, uint8 v, bytes32 r,  bytes32 s) external;

    function transferDragonOwner(address newOwner) external;
    function mintableDragons(address user) external view returns(uint256, uint256, uint256);
    function timeWindows() external view returns(uint256, uint256, uint256, uint256, uint256, uint256);

    error ZeroWETHAddress(address thrower);
    error NotInWhiteListA(address thrower, address user);
    error NotInWhiteListB(address thrower, address user);
    error AlreadyMinted(address thrower, address user, uint256 count);
    error AlreadyEnded(address thrower, uint256 endTime);
    error NotEnoughETH(address thrower, uint256 amount);
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.11;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function balanceOf(address user) external returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.11;

interface IWETHGateway {
    function mintB(address distributor, address receiver, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable;
    function publicMint(address distributor, address receiver, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable;
}