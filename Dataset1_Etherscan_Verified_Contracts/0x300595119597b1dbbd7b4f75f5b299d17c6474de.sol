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

/// @title County Fair FLea Market
/// @notice burn and redeem contract for Negotiations With The Abyss
/// @author transientlabs.xyz

pragma solidity 0.8.17;

import {Ownable} from "Ownable.sol";

interface BurnContract {
    function burn(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external;
}

interface RedeemContract {
    function externalMint(address recipient, uint256 tokenId) external;
}

contract CountyFairFleaMarket is Ownable {

    // State Variables
    bool public redeemOpen;
    BurnContract public burnContract;
    RedeemContract public redeemContract;
    mapping(uint256 => uint256) private _pointsForPrize;

    // constructor
    constructor(address burnContractAddress, address redeemContractAddress) Ownable() {
        burnContract = BurnContract(burnContractAddress);
        redeemContract = RedeemContract(redeemContractAddress);
    }

    /// @notice function to set points for a prize
    /// @dev requires owner
    function setPointsPerPrize(uint256[] calldata prizeTokenIds, uint256[] calldata prizePoints) external onlyOwner {
        require(prizeTokenIds.length == prizePoints.length, "array length mismatch");

        for (uint256 i = 0; i < prizePoints.length; i++) {
            _pointsForPrize[prizeTokenIds[i]] = prizePoints[i];
        }
    }

    /// @notice function to open/close the redeem
    /// @dev requires owner
    function setRedeemStatus(bool status) external onlyOwner {
        redeemOpen = status;
    }

    /// @notice redeem function
    function redeem(uint256 prizeTokenId) external {
        require(redeemOpen, "redeem not open");
        uint256 numToBurn = _pointsForPrize[prizeTokenId];
        require(numToBurn > 0, "invalid prize token id");
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 1;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = numToBurn;
        burnContract.burn(msg.sender, tokenIds, amounts);
        redeemContract.externalMint(msg.sender, prizeTokenId);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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