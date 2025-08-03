// SPDX-License-Identifier: GPL-3.0
// solhint-disable-next-line
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IMasterContract.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Bulls and Apes Project - Buy Special LootBoxes
/// @author BAP Dev Team
/// @notice Helper Contract to buy special LootBoxes
contract BoxBuyer is Ownable, ReentrancyGuard {
    /// @notice Address of the signer wallet
    address public secret;

    // @notice mapping for used signatures
    mapping(bytes => bool) public isSignatureUsed;

    /// @notice Event emitted when lootbox is bought
    event BoxBought(
        uint256 amount,
        uint256 boxType,
        address recipient,
        address operator
    );

    /// @notice Event emitted when METH bag is buyed
    event MethBagBought(uint256 amount, uint256 price, address to);

    /// @notice Deploys the contract
    /// @param _secret Address of the signer wallet
    constructor(address _secret) {
        secret = _secret;
    }

    /// @notice Helper function to buy a special lootbox
    /// @param amount Amount of boxes to buy
    /// @param boxType Type of the lootbox to buy
    /// @param price Price to be paid for the lootbox (in ETH)
    /// @param timeOut Timestamp for signature expiration
    /// @param recipient Address to send the lootbox to
    /// @param signature Signature to verify above parameters
    function buyLootbox(
        uint256 amount,
        uint256 boxType,
        uint256 price,
        uint256 timeOut,
        address recipient,
        bytes memory signature
    ) external payable {
        require(
            timeOut > block.timestamp,
            "buyLootbox: Seed is no longer valid"
        );
        require(price > 0, "buyLootbox: amount is not valid");
        require(msg.value >= price, "buyLootbox: not enough ETH to buy");
        // check signature
        require(
            !isSignatureUsed[signature],
            "buyLootbox: Signature is already used"
        );
        require(
            _verifyHashSignature(
                keccak256(
                    abi.encode(amount, boxType, price, timeOut, recipient)
                ),
                signature
            ),
            "buyLootbox: Signature is invalid"
        );

        isSignatureUsed[signature] = true;

        if (msg.value > price) {
            (bool success, ) = msg.sender.call{value: msg.value - price}("");
            require(success, "buyLootbox: Unable to send refund eth");
        }

        emit BoxBought(amount, boxType, recipient, msg.sender);
    }

    /// @notice Buy METH bags to be deposited to the bank
    /// @param amount Amount of METH to buy
    /// @param to Address to send the METH
    /// @param price Price to be paid for the METH (in ETH)
    /// @param timeOut Timestamp for signature expiration
    /// @param signature Signature to verify above parameters
    /// @dev Mints amount METH to selected address
    function buyMethBag(
        uint256 amount,
        address to,
        uint256 price,
        uint256 timeOut,
        bytes calldata signature
    ) external payable {
        require(
            timeOut > block.timestamp,
            "buyMethBag: Seed is no longer valid"
        );
        require(
            _verifyHashSignature(
                keccak256(abi.encode(amount, to, price, timeOut)),
                signature
            ),
            "buyMethBag: Signature is invalid"
        );
        require(price > 0, "buyMethBag: amount is not valid");
        require(msg.value >= price, "buyMethBag: not enough ETH to buy");

        if (msg.value > price) {
            (bool success, ) = msg.sender.call{value: msg.value - price}("");
            require(success, "buyMethBag: Unable to send refund eth");
        }

        emit MethBagBought(amount, price, to);
    }

    /// @notice Change the signer address
    /// @param _secret new signer for encrypted signatures
    /// @dev Can only be called by the contract owner
    function setSecret(address _secret) external onlyOwner {
        secret = _secret;
    }

    function withdrawETH(
        address _address,
        uint256 amount
    ) public nonReentrant onlyOwner {
        require(amount <= address(this).balance, "Insufficient funds");
        (bool success, ) = _address.call{value: amount}("");
        require(success, "Unable to send eth");
    }

    function _verifyHashSignature(
        bytes32 freshHash,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", freshHash)
        );

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return false;
        }
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        address signer = address(0);
        if (v == 27 || v == 28) {
            // solium-disable-next-line arg-overflow
            signer = ecrecover(hash, v, r, s);
        }
        return secret == signer;
    }
}
// SPDX-License-Identifier: GPL-3.0
// solhint-disable-next-line
pragma solidity 0.8.12;

interface IMasterContract {
    // METH functions

    function claim(address to, uint256 amount) external;

    function pay(uint256 payment, uint256 fee) external;

    // Teens functions

    function airdrop(address to, uint256 amount) external;

    function burnTeenBull(uint256 tokenId) external;

    // Utilities functions

    function burn(uint256 id, uint256 amount) external;

    function airdrop(
        address to,
        uint256 amount,
        uint256 id
    ) external;
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