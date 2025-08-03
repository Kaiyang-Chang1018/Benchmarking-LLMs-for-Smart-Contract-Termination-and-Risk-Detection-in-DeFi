// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


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

// File: contracts/ABDSBridge_Ethereum.sol


pragma solidity ^0.8.28;

/**
 * @title ABDSBridge_Ethereum
 * @notice This contract locks ABDS tokens on Ethereum so that the user can
 *         receive an equivalent amount of ABDS on BSC.
 *
 *         - Hard-coded addresses:
 *             ABDS Token: 0xB56AaAc80C931161548a49181c9E000a19489C44
 *             Owner:      0xd3b5DCa8bb515f2692b1398054172880d0C7d969
 *             Operator:   0x8c5215f795e18FbE4CFCe455d99F286a33968616
 *
 *         - Default bridging fee: 5 ABDS
 *         - The contract references OpenZeppelin's IERC20 and Ownable contracts
 */



contract ABDSBridge_Ethereum is Ownable {
    /// @dev The ABDS token on Ethereum (immutable).
    IERC20 public immutable abdsToken;

    /// @dev Total net ABDS locked in this contract. Does NOT include fee amounts.
    uint256 public totalLocked;

    /// @dev Default bridging fee is 5 ABDS (assuming 18 decimal token => 5e18).
    uint256 public bridgeFee = 5 * 1e18;

    /// @dev Mapping of trusted operators (the Python server).
    mapping(address => bool) private _trustedOperators;

    // ------------------------------------------------------------------------
    // EVENTS
    // ------------------------------------------------------------------------

    /**
     * @dev Emitted when a user locks ABDS tokens on Ethereum for bridging to BSC.
     * @param user The ETH address that locked tokens.
     * @param bscRecipient The BSC address to receive the tokens on BSC.
     * @param amountBridged The net amount after subtracting the fee.
     */
    event BridgingOut(
        address indexed user,
        address indexed bscRecipient,
        uint256 amountBridged
    );

    /**
     * @dev Emitted when tokens are unlocked back to a user on Ethereum
     *      after bridging from BSC to ETH.
     * @param recipient The ETH address receiving the unlocked tokens.
     * @param amount The number of tokens unlocked.
     */
    event Unlocked(address indexed recipient, uint256 amount);

    /// @dev Emitted when the bridging fee is updated.
    event BridgeFeeUpdated(uint256 newFee);

    /// @dev Emitted when an operator is added or removed.
    event OperatorUpdated(address indexed operator, bool isTrusted);

    // ------------------------------------------------------------------------
    // MODIFIERS
    // ------------------------------------------------------------------------

    modifier onlyTrustedOperator() {
        require(_trustedOperators[msg.sender], "Not a trusted operator");
        _;
    }

    // ------------------------------------------------------------------------
    // CONSTRUCTOR (No external params)
    // ------------------------------------------------------------------------

    /**
     * @notice Sets:
     *         - ABDS token address on Ethereum
     *         - Owner
     *         - A trusted operator
     */
    constructor()
        Ownable(0xd3b5DCa8bb515f2692b1398054172880d0C7d969)
    {
        // ABDS token on Ethereum
        abdsToken = IERC20(0xB56AaAc80C931161548a49181c9E000a19489C44);

        // Pre-authorize the Python operator
        _trustedOperators[0x8c5215f795e18FbE4CFCe455d99F286a33968616] = true;
        emit OperatorUpdated(0x8c5215f795e18FbE4CFCe455d99F286a33968616, true);
    }

    // ------------------------------------------------------------------------
    // BRIDGE OUT (ETH -> BSC)
    // ------------------------------------------------------------------------

    /**
     * @notice Locks `amount` of ABDS from msg.sender, subtracting a bridging fee.
     *         User must have called `abdsToken.approve(address(this), amount)` first.
     * @param amount The total ABDS the user wants to send.
     * @param bscRecipient The BSC address that will receive the bridged tokens.
     */
    function bridgeToBSC(uint256 amount, address bscRecipient) external {
        require(bscRecipient != address(0), "Invalid BSC recipient");
        require(amount > bridgeFee, "Amount must exceed bridging fee");

        // Pull tokens from the user
        bool success = abdsToken.transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");

        // Transfer the fee portion to owner
        bool feeSent = abdsToken.transfer(owner(), bridgeFee);
        require(feeSent, "Fee transfer failed");

        // Net bridging amount
        uint256 bridgingAmount = amount - bridgeFee;

        // Update locked total
        totalLocked += bridgingAmount;

        // Emit bridging event for the Python server
        emit BridgingOut(msg.sender, bscRecipient, bridgingAmount);
    }

    // ------------------------------------------------------------------------
    // BRIDGE IN (BSC -> ETH)
    // ------------------------------------------------------------------------

    /**
     * @notice Unlocks tokens previously locked here, sending them to `ethRecipient`.
     * @dev Only callable by the trusted Python operator after confirming user burned on BSC.
     * @param ethRecipient The Ethereum address that receives the unlocked tokens.
     * @param amount The net bridging amount to unlock.
     */
    function unlockTokens(address ethRecipient, uint256 amount)
        external
        onlyTrustedOperator
    {
        require(ethRecipient != address(0), "Invalid ETH recipient");
        require(amount > 0, "Amount must be > 0");
        require(totalLocked >= amount, "Not enough tokens locked");

        totalLocked -= amount;

        bool success = abdsToken.transfer(ethRecipient, amount);
        require(success, "transfer failed");

        emit Unlocked(ethRecipient, amount);
    }

    // ------------------------------------------------------------------------
    // FEE ADMIN
    // ------------------------------------------------------------------------

    /**
     * @notice Owner can update the bridging fee in ABDS tokens.
     *         If ABDS has 18 decimals, 5 ABDS = 5e18.
     */
    function setBridgeFee(uint256 newFee) external onlyOwner {
        bridgeFee = newFee;
        emit BridgeFeeUpdated(newFee);
    }

    // ------------------------------------------------------------------------
    // TRUSTED OPERATORS
    // ------------------------------------------------------------------------

    /**
     * @notice Owner can add a new Python operator or bridging server address.
     */
    function addTrustedOperator(address operator) external onlyOwner {
        require(operator != address(0), "Operator cannot be zero address");
        _trustedOperators[operator] = true;
        emit OperatorUpdated(operator, true);
    }

    /**
     * @notice Owner can remove an existing operator.
     */
    function removeTrustedOperator(address operator) external onlyOwner {
        _trustedOperators[operator] = false;
        emit OperatorUpdated(operator, false);
    }

    /**
     * @notice Check if an address is currently trusted.
     */
    function isTrustedOperator(address operator) external view returns (bool) {
        return _trustedOperators[operator];
    }

    // ------------------------------------------------------------------------
    // OPTIONAL EMERGENCY / ADMIN
    // ------------------------------------------------------------------------

    /**
     * @notice Owner can manually unlock tokens in an emergency scenario,
     *         if bridging fails or some off-chain logic is stuck.
     */
    function emergencyUnlock(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");
        require(totalLocked >= amount, "Insufficient locked tokens");

        totalLocked -= amount;
        bool success = abdsToken.transfer(recipient, amount);
        require(success, "transfer failed");
    }
}