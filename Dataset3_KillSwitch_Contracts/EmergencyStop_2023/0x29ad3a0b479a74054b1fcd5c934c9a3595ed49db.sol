// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract GodsLegacyPrivateCollect is Ownable, ReentrancyGuard, Pausable {

    uint256 public totalContributions;
    uint256 public totalReservedTokens;
    uint256 public minimumReservationAmountUsd;

    event ContributionReceived(
        address indexed contributor, 
        uint256 ethAmount, 
        uint256 usdAmount,
        uint256 reservedTokens, 
        uint256 timestamp
    );
    event MinimumReservationAmountUpdated(uint256 newMinimumAmountUsd);

    constructor() Ownable(msg.sender) {
        minimumReservationAmountUsd = 0;
    }

    /**
     * @dev Allows a user to reserve tokens by providing ETH and the corresponding USD amount.
     * @param _usdAmount The USD equivalent of the ETH sent, calculated in the frontend (with 6 decimals).
     * Emits a ContributionReceived event.
     */
    function reserveTokens(uint256 _usdAmount) external payable nonReentrant whenNotPaused {
        require(_usdAmount >= minimumReservationAmountUsd, "USD amount below minimum reservation amount");
        require(msg.value > 0, "ETH amount must be greater than 0");

        uint256 reservedTokens = _usdAmount * 10;

        totalContributions += msg.value;
        totalReservedTokens += reservedTokens;

        emit ContributionReceived(msg.sender, msg.value, _usdAmount, reservedTokens, block.timestamp);
    }

    /**
     * @dev Allows the owner to update the minimum reservation amount in USD.
     * @param _newMinimumAmountUsd New minimum reservation amount in USD (with 6 decimals).
     * Emits a MinimumReservationAmountUpdated event.
     */
    function updateMinimumReservationAmount(uint256 _newMinimumAmountUsd) external onlyOwner {
        minimumReservationAmountUsd = _newMinimumAmountUsd;
        emit MinimumReservationAmountUpdated(_newMinimumAmountUsd);
    }

    /**
     * @dev Allows the owner to withdraw a specified amount of ETH from the contract.
     * @param _to Address to which ETH should be withdrawn.
     * @param _amount Amount of ETH to withdraw.
     */
    function withdrawETH(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid address");
        require(_amount > 0 && _amount <= address(this).balance, "Invalid amount");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "ETH transfer failed");
    }

    /**
     * @dev Allows the owner to withdraw all ETH from the contract.
     * Transfers the entire balance of ETH held by the contract to the owner's address.
     */
    function withdrawAllETH() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No ETH to withdraw");
        (bool success, ) = payable(owner()).call{value: contractBalance}("");
        require(success, "ETH transfer failed");
    }

    /**
    * @notice Get total ETH contributions stored in the contract.
    */
    function getTotalContributions() public view returns (uint256) {
        return totalContributions;
    }

    /**
    * @notice Get total reserved tokens stored in the contract.
    */
    function getTotalReservedTokens() public view returns (uint256) {
        return totalReservedTokens;
    }

    function getBalance() public view returns (uint256) {
        return  address(this).balance;
    }

    /**
    * @notice Pauses all token reservations and certain contract functions.
    */
    function pause() external onlyOwner {
        _pause();
    }

    /**
    * @notice Unpauses the contract, allowing token reservations and certain functions to resume.
    */
    function unpause() external onlyOwner {
        _unpause();
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}