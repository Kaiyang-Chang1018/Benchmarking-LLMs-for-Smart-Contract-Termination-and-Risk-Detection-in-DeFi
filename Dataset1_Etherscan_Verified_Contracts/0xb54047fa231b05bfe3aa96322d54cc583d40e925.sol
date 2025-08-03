// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {IStandardBridge} from "./interfaces/IStandardBridge.sol";

contract L1Bridge is Ownable {
    /// @notice bips
    uint256 public FEE;

    uint32 public RECEIVE_DEFAULT_GAS_LIMIT = 200_000;

    event EtherDeposit(address from, address to, uint256 amount);
    event TokenDeposit(address from, address to, address l1Token, address l2Token, uint256 amount);

    constructor(uint256 _fee) Ownable() {
        FEE = _fee;
    }

    function initiateEtherDeposit(address payable _l1StandardBridge, address _to) public payable {
        uint256 _fee = msg.value * FEE / 10_000;
        uint256 _amount = msg.value - _fee;
        IStandardBridge(_l1StandardBridge).bridgeETHTo{value: _amount}(_to, RECEIVE_DEFAULT_GAS_LIMIT, bytes(""));

        emit EtherDeposit(msg.sender, _to, _amount);
    }

    function initiateERC20Deposit(
        address payable _l1StandardBridge,
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _amount,
        bool _legacy
    ) public {
        _initiateERC20Deposit(_l1StandardBridge, _l1Token, _l2Token, _to, _amount, _legacy);
    }

    function initiateERC20DepositWithPermit(
        address payable _l1StandardBridge,
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        bool _legacy
    ) external {
        IERC20Permit(_l1Token).permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
        _initiateERC20Deposit(_l1StandardBridge, _l1Token, _l2Token, _to, _amount, _legacy);
    }

    function _initiateERC20Deposit(
        address payable _l1StandardBridge,
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _amount,
        bool _legacy
    ) internal {
        IERC20 erc20 = IERC20(_l1Token);
        require(erc20.transferFrom(msg.sender, address(this), _amount), "!transferFrom");

        uint256 _fee = _amount * FEE / 10_000;
        uint256 _amountSubFee = _amount - _fee;

        erc20.approve(_l1StandardBridge, _amountSubFee);
        if (_legacy) {
            IStandardBridge(_l1StandardBridge).depositERC20To(
                _l1Token, _l2Token, _to, _amountSubFee, RECEIVE_DEFAULT_GAS_LIMIT, bytes("")
            );
        } else {
            IStandardBridge(_l1StandardBridge).bridgeERC20To(
                _l1Token, _l2Token, _to, _amountSubFee, RECEIVE_DEFAULT_GAS_LIMIT, bytes("")
            );
        }
        erc20.approve(_l1StandardBridge, 0);

        emit TokenDeposit(msg.sender, _to, _l1Token, _l2Token, _amountSubFee);
    }

    function withdrawEtherFees() public onlyOwner {
        (bool sent, bytes memory data) = owner().call{value: payable(address(this)).balance}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawERC20Fees(address _token) public onlyOwner {
        IERC20 erc20 = IERC20(_token);
        bool sent = erc20.transfer(owner(), erc20.balanceOf(address(this)));
        require(sent, "Failed to send token");
    }

    function setFee(uint256 _fee) public onlyOwner {
        FEE = _fee;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IStandardBridge {
    // deposits
    // Legacy but DAI and some other bridges only support this
    function depositERC20To(
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _amount,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) external;

    // withdrawals
    // legacy but DAI and some other bridges only support this
    function withdrawTo(address _l2Token, address _to, uint256 _amount, uint32 _l1Gas, bytes calldata _data)
        external
        payable;

    // both
    function bridgeETHTo(address _to, uint32 _minGasLimit, bytes calldata _extraData) external payable;
    // disabled because we prefer
    function bridgeERC20To(
        address _localToken,
        address _remoteToken,
        address _to,
        uint256 _amount,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) external payable;
}