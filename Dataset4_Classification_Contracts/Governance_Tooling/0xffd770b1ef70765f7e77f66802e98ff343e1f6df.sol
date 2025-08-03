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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

abstract contract FairConvertBase is Ownable {
    address public tokenA;
    address public tokenB;

    bool public isActive = true;
    uint public multiplier = 1000;

    event Swap(address indexed sender, uint256 amount);

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function _swap(uint256 amount) internal {
        require(isActive, "Contract is not active");

        // Directly burn token A by transferring from the sender to address(0)
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amount), "Receiving token A failed");

        uint256 newAmount = amount * multiplier / 1000;

        // Transfer token B from this contract to the sender
        require(IERC20(tokenB).transfer(msg.sender, newAmount), "Transfer of token B failed");

        emit Swap(msg.sender, amount);
    }

    function setMultiplier(uint _multiplier) public onlyOwner {
        multiplier = _multiplier;
    }

    function setActive(bool _isActive) public onlyOwner {
        isActive = _isActive;
    }

    function emergencyWithdraw(address token, uint256 amount) public onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./FairConvertBase.sol";

contract PermissionedFairConvert is FairConvertBase {
    address public signer;

    mapping (address => bool) public swapDone;

    constructor(address _signer, address _tokenA, address _tokenB) FairConvertBase(_tokenA, _tokenB) {
        signer = _signer;
    }

    function swap(uint256 amount, bytes memory signature) public {
        require(verify(msg.sender, amount, signature), "Invalid signature");
        require(!swapDone[msg.sender], "Already converted");
        _swap(amount);
        swapDone[msg.sender] = true;
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65, "Invalid signature length.");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function verify(address user, uint256 amount, bytes memory signature)
        public
        view
        returns (bool)
    {
        bytes32 messageHash = keccak256(abi.encodePacked(amount, user));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(ethSignedMessageHash, v, r, s) == signer;
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }
}