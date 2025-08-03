// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

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
    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

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

// Define the contract named "SonarBotSubscription" which inherits the "Ownable" and "ReentrancyGuard" contracts.
contract SonarBotSubscription is Ownable, ReentrancyGuard {

    // Event that is emitted whenever a new subscriber pays for a subscription.
    event NewSubscriber(address indexed subscriber, uint256 amountPaid);
    
    // Event that is emitted whenever the contract owner withdraws funds from the contract.
    event Withdrawal(address indexed owner, uint256 amount);

    // A mapping to store the amount of ETH each subscriber has paid. 
    // The address is the subscriber's address and the uint256 is the amount of ETH they've paid.
    mapping(address => uint256) private _subscriberBalances;

    // Function for users to subscribe to the service. They must send ETH in the transaction.
    function subscribe() external payable nonReentrant {
        // Ensure that the user sends more than 0 ETH when trying to subscribe.
        require(msg.value > 0, "Payment amount must be greater than zero");
        
        // Increase the subscriber's balance with the sent ETH amount.
        _subscriberBalances[msg.sender] += msg.value;
        
        // Emit a NewSubscriber event to log the subscription.
        emit NewSubscriber(msg.sender, msg.value);
    }

    // Function for the owner of the contract to withdraw all the funds.
    function withdrawFunds() external onlyOwner nonReentrant {
        // Calculate the total balance of the contract.
        uint256 amountToWithdraw = address(this).balance;
        
        // Ensure there is more than 0 ETH in the contract to withdraw.
        require(amountToWithdraw > 0, "No funds available to withdraw");
        
        // Try to transfer the total balance of the contract to the owner.
        // The "call" method is a low-level function to transfer ETH.
        (bool success, ) = payable(owner()).call{value: amountToWithdraw}("");
        
        // If the transfer fails, revert the transaction.
        require(success, "Withdrawal failed");
        
        // Emit a Withdrawal event to log the withdrawal action.
        emit Withdrawal(owner(), amountToWithdraw);
    }

    // Function to check if a specific address is a subscriber.
    // An address is considered a subscriber if they have a balance greater than 0 in the contract.
    function isSubscriber(address account) public view returns (bool) {
        return _subscriberBalances[account] > 0;
    }

    // Function to check the balance of a specific subscriber.
    function subscriberBalance(address account) public view returns (uint256) {
        return _subscriberBalances[account];
    }
}