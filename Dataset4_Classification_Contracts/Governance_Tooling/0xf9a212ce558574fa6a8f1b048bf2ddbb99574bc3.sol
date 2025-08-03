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
pragma solidity ^0.8.19;

import "./ICrossmintable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

error BonusMinter__WrongEtherAmmount();
error BonusMinter__NotEnoughTokens();
error BonusMinter__NotEnoughEtherToFundBonusTokens();

/**
 * @title BonusMinter
 * @author DeployLabs.io
 *
 * @dev Contract for minting bonus tokens on Sol3Mates.
 */
contract BonusMinter is Ownable {
	ICrossmintable private i_crossmintable;

	uint16 private s_bonusTokensCount = 1;
	uint256 private s_tokenPrice = 0.03 ether;

	constructor(address crossmintableAddress) {
		i_crossmintable = ICrossmintable(crossmintableAddress);
	}

	receive() external payable {}

	/**
	 * @dev Mint tokens to the specified address imitating crossmint.io and adding bonus tokens.
	 * Bonus tokens are covered by the contract owner.
	 *
	 * @param mintTo The address to mint the token to.
	 * @param quantity The quantity of tokens to mint.
	 */
	function mint(address mintTo, uint16 quantity) external payable {
		if (msg.value != s_tokenPrice * quantity) revert BonusMinter__WrongEtherAmmount();
		if (quantity < 1) revert BonusMinter__NotEnoughTokens();

		uint16 resultingQuantity = quantity + s_bonusTokensCount;
		uint256 resultingPrice = s_tokenPrice * resultingQuantity;
		if (address(this).balance < resultingPrice)
			revert BonusMinter__NotEnoughEtherToFundBonusTokens();

		i_crossmintable.crossmintMint{ value: resultingPrice }(mintTo, resultingQuantity);
	}

	/**
	 * @dev Withdraw all money from the contract.
	 *
	 * @param to The address to withdraw the money to.
	 */
	function withdraw(address payable to) external onlyOwner {
		payable(to).transfer(address(this).balance);
	}

	/**
	 * @dev Set the quantity of bonus tokens to mint.
	 *
	 * @param bonusTokensCount The quantity of bonus tokens to mint.
	 */
	function setBonusTokensCount(uint16 bonusTokensCount) external onlyOwner {
		s_bonusTokensCount = bonusTokensCount;
	}

	/**
	 * @dev Set the price of a token.
	 *
	 * @param tokenPrice The price of a token, specified in wei.
	 */
	function setTokenPrice(uint256 tokenPrice) external onlyOwner {
		s_tokenPrice = tokenPrice;
	}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICrossmintable {
	function crossmintMint(address mintTo, uint256 quantity) external payable;
}