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
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PresaleV2 is Ownable {

    struct UserInfo {
        uint256 tokensPurchased;
        uint256 purchasedAmountClaimed;
        uint256 tokensReferred;
        uint256 referredAmountClaimed;
    }

    mapping(address => UserInfo) public users;
    mapping(bytes => address) public referrers;

    uint256 public totalTokensSupplied;
    uint256 public totalTokensPurchased;
    uint256 public tokenRatio;

    uint256 public constant VESTING_PERIOD = 14 days;
    uint256 public constant CLIFF_DURATION = 12 hours;
    uint256 public constant INITIAL_UNLOCK_PERCENT = 75;

    uint256 public constant BONUS = 3; // 3% 
    uint256 private constant PERCENT = 100;

    uint256 private constant FALSE = 1;
    uint256 private constant TRUE = 2;

    uint256 public saleEnded = FALSE;
    uint256 public claimEnabled = FALSE;
    
    uint256 public claimTime;
    uint256 public launchTime;

    IERC20 public tokenAddress;

    error ExceedsSupply();
    error SaleNotEnded();
    error InvalidSaleState();
    error NotEnabled();
    error AlreadyLaunched();

    constructor(address _tokenAddress) Ownable(msg.sender) {
        tokenAddress = IERC20(_tokenAddress);
    }

    receive() external payable {}

    function launch(uint256 ratio, uint256 suppliedTokens) external onlyOwner {
        if (launchTime != 0) { 
            revert AlreadyLaunched();
        }
        launchTime = block.timestamp;
        tokenRatio = ratio;
        totalTokensSupplied = suppliedTokens;
        tokenAddress.transferFrom(msg.sender, address(this), suppliedTokens);
    }

    function endSale() external onlyOwner {
        saleEnded = TRUE;
    }

    function enableClaims() external onlyOwner {
        if (saleEnded != TRUE) {
            revert SaleNotEnded();
        }
        claimEnabled = TRUE;
        claimTime = block.timestamp;
        // Transfers extra tokens back to the owner
        tokenAddress.transfer(msg.sender, totalTokensSupplied - totalTokensPurchased);
    }

    function purchase(bytes calldata referral) external payable {
        if (launchTime == 0 || saleEnded == TRUE) { 
            revert InvalidSaleState();
        }

        uint256 tokenAmountPreBonus = msg.value * tokenRatio; // tokens based on ETH amount alone

        uint256 bonusAmount;
        address referrer;
        if (referral.length != 0) {
            // if the user supplied referral data check the referral address
            referrer = referrers[referral]; 
            if (referrer != address(0)) {
                // calculate the bonus if valid referral code
                bonusAmount = tokenAmountPreBonus * BONUS / PERCENT;
            }
        }
        
        if (totalTokensPurchased + tokenAmountPreBonus + (bonusAmount * 2) > totalTokensSupplied) {
            revert ExceedsSupply();
        }        

        totalTokensPurchased = totalTokensPurchased + tokenAmountPreBonus + (bonusAmount * 2);
        users[msg.sender].tokensPurchased = users[msg.sender].tokensPurchased + (tokenAmountPreBonus + bonusAmount);
        users[referrer].tokensReferred = users[referrer].tokensReferred + bonusAmount;
    }

    function claimTokensReferred() external {
        if (claimEnabled != TRUE) {
            revert NotEnabled();
        }
        // Claimable tokens vest over time 
        uint256 vested = vestedAmount(users[msg.sender].tokensReferred);
        // Calculate claimable, update claimed amount, send user their tokens
        uint256 claimable = vested - users[msg.sender].referredAmountClaimed;
        users[msg.sender].referredAmountClaimed = vested;
        tokenAddress.transfer(msg.sender, claimable);
    }

    // Allows the users to claim tokens once enabled
    function claim() external {
        if (claimEnabled != TRUE) {
            revert NotEnabled();
        }
        // Claimable tokens vest over time 
        uint256 vested = vestedAmount(users[msg.sender].tokensPurchased);
        // Calculate claimable, update claimed amount, send user their tokens
        uint256 claimable = vested - users[msg.sender].purchasedAmountClaimed;
        users[msg.sender].purchasedAmountClaimed = vested;
        tokenAddress.transfer(msg.sender, claimable);
    }

    function setReferrers(bytes[] calldata codes, address[] calldata addresses) external onlyOwner {
        for(uint256 i; i < codes.length; ) {
            referrers[codes[i]] = addresses[i];
            unchecked {
                ++i;
            }
        }
    }

    // Withdraws all ETH from the contract
    function withdrawETH() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}(""); 
        require(success);
    }
   
    // Withdraws all of a specified token to a contract - should only be used on the presale token in case of emergency
    function emergencyWithdrawTokens(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function tokensRemainingToPurchase() external view returns (uint256){
        return totalTokensSupplied - totalTokensPurchased;
    }

    // Calculates the amount of vested tokens from the time claiming was enabled
    function vestedAmount(uint256 totalPurchased) public view returns (uint256) {
        if (claimTime == 0) {
            return 0;
        }
        uint256 elapsedTime = block.timestamp - claimTime;
        uint256 initalUnlockAmount = (totalPurchased * INITIAL_UNLOCK_PERCENT) / PERCENT;
        if (elapsedTime < CLIFF_DURATION) {
            // Before 12 hours, only the initial 75% is available
            return initalUnlockAmount;
        } else if (elapsedTime >= CLIFF_DURATION + VESTING_PERIOD) {
            // After the vesting period, 100% is vested
            return totalPurchased;
        } else { // calculate vested amount 
            elapsedTime = block.timestamp - (claimTime + CLIFF_DURATION); // vesting starts from cliff duration
            uint256 nonInitialAmount = (totalPurchased * (PERCENT - INITIAL_UNLOCK_PERCENT)) / PERCENT; // amount that vests after initial unlock
            uint256 currVestedAmount = (nonInitialAmount * elapsedTime) / VESTING_PERIOD; // amount of non-initial that has vested
            return initalUnlockAmount + currVestedAmount; // initial unlock + vested amount 
        }
    }
}