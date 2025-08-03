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
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function mint(address user, uint256 amount) external returns(bool);
    function burn(address user, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenHelper is Ownable {
    IERC20 public immutable esLBR;
    IERC20 public immutable LBR;
    IERC20 public immutable oldLBR;
    uint256 public deadline;
   
    event BatchEsLBRForUsers(address indexed caller, string desc, uint256 total);
    event BatchLBRForUsers(address indexed caller, string desc, uint256 total);

    constructor(address _esLBR, address _LBR, address _oldLBR, uint256 _deadline) {
        esLBR = IERC20(_esLBR);
        LBR = IERC20(_LBR);
        oldLBR = IERC20(_oldLBR);
        deadline = _deadline;
    }

    function airdropEsLBR(address[] calldata to, uint256[] calldata value, string memory desc) external onlyOwner {
        require(block.timestamp <= deadline);
        uint256 total = 0;
        for(uint256 i = 0; i < to.length; i++){
            esLBR.mint(to[i], value[i]);
            total += value[i];
        }
        emit BatchEsLBRForUsers(msg.sender, desc, total);
    }

    function airdropLBR(address[] calldata to, uint256[] calldata value, string memory desc) external onlyOwner {
        require(block.timestamp <= deadline);
        uint256 total = 0;
        for(uint256 i = 0; i < to.length; i++){
            LBR.mint(to[i], value[i]);
            total += value[i];
        }
        emit BatchLBRForUsers(msg.sender, desc, total);
    }

    function migrate(uint256 amount) external {
        require(block.timestamp <= deadline);
        oldLBR.transferFrom(msg.sender, address(this), amount);
        LBR.mint(msg.sender, amount);
    }
}