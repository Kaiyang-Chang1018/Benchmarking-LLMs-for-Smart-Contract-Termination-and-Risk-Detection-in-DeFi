// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
//
//          .@@@                                                                  
//               ,@@@@@@@&,                  #@@%                                  
//                    @@@@@@@@@@@@@@.          @@@@@@@@@                           
//                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      
//                            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   
//                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.                 
//                                    @@@@@@@    &@@@@@@@@@@@@@@@@@                
//                                        @@@/        &@@@@@@@@@@@@@,              
//                                            @            @@@@@@@@@@@             
//                                                             /@@@@@@@#           
//                                                                  @@@@@          
//                                                                      *@&   
//         RTFKT Studios (https://twitter.com/RTFKT)

/**
    RTFKT Legal Overview [https://rtfkt.com/legaloverview]
    1. RTFKT Platform Terms of Services [Document #1, https://rtfkt.com/tos]
    2. End Use License Terms
    A. Digital Collectible Terms (RTFKT-Owned Content) [Document #2-A, https://rtfkt.com/legal-2A]
    B. Digital Collectible Terms (Third Party Content) [Document #2-B, https://rtfkt.com/legal-2B]
    C. Digital Collectible Limited Commercial Use License Terms (RTFKT-Owned Content) [Document #2-C, https://rtfkt.com/legal-2C]
    D. Digital Collectible Terms [Document #2-D, https://rtfkt.com/legal-2D]
    
    3. Policies or other documentation
    A. RTFKT Privacy Policy [Document #3-A, https://rtfkt.com/privacy]
    B. NFT Issuance and Marketing Policy [Document #3-B, https://rtfkt.com/legal-3B]
    C. Transfer Fees [Document #3C, https://rtfkt.com/legal-3C]
    C. 1. Commercialization Registration [https://rtfkt.typeform.com/to/u671kiRl]
    
    4. General notices
    A. Murakami Short Verbiage – User Experience Notice [Document #X-1, https://rtfkt.com/legal-X1]
**/

pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.4.1/access/Ownable.sol";

interface ERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function burn(address account, uint256 id, uint256 value) external;
}

contract RTFKTxMurakamiGagosianShirtForging is Ownable {
    address public shirtAddress;
    uint256 public price;

    uint256 public constant SHIRT_TOKEN_ID = 1;
    uint256 public constant MINTS_PER_TOKEN = 2;

    bool public forgeOpen;

    error ForgeNotActive();
    error InvalidAmount();
    error InvalidPayment();

    event newForge(uint256[1] tokenIds, uint256[1] amounts, address owner);

    constructor (address shirtAddress_) {
        shirtAddress = shirtAddress_;
    }

    function forgeToken(uint256 amount) public payable {
        if (!forgeOpen) revert ForgeNotActive();

        ERC1155 preForgeContract = ERC1155(shirtAddress);
        uint256 tokensOwned = preForgeContract.balanceOf(msg.sender, SHIRT_TOKEN_ID);
        uint256 maxForgeable = tokensOwned * MINTS_PER_TOKEN;

        if (amount < 1 || amount > maxForgeable) revert InvalidAmount();
        if (amount * price != msg.value) revert InvalidPayment();

        uint256 tokensUsed = _getTokensUsed(amount);

        preForgeContract.burn(msg.sender, SHIRT_TOKEN_ID, tokensUsed);

        emit newForge([uint256(1)], [amount], msg.sender);
    }

    function _getTokensUsed(uint256 amount) internal pure returns (uint256) {
        return amount / MINTS_PER_TOKEN + (amount % MINTS_PER_TOKEN == 0 ? 0 : 1);
    }

    /////////////////////////////
    // CONTRACT MANAGEMENT 
    /////////////////////////////

    function toggleForgeActive() public onlyOwner {
        forgeOpen = !forgeOpen;
    }

    function setPrice(uint256 price_) public onlyOwner {
        price = price_;
    }

    function withdrawFunds() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
}