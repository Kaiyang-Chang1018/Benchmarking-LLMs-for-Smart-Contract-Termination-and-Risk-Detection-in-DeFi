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

// File: TIDYVault.sol


pragma solidity ^0.8.20;


/**
 * @notice Interface defining minimal ERC20 token functionality
 * @dev Enables interaction with standard ERC20 tokens
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function decimals() external view returns (uint8);
}

/**
 * @title TIDYVault
 * @notice A vault for securely managing token deposits with signature-based authentication
 * @dev Includes functionality for token deposits and withdrawals
 */
contract TidyVault is Ownable {
    // Mappings
    mapping(address => mapping(address => uint256)) public userDeposits; // user => token => amount

    // Mapping to track if a user has made any deposit
    mapping(address => bool) public hasDeposited;

    // Mapping to track the number of transfers made by a user
    mapping(address => uint256) public userTransferCount;

    // Mapping to track tokens a user has already deposited
    // Prevents duplicate deposits of the same token
    mapping(address => mapping(address => bool)) public depositedTokens;

    // used signatures to prevent replay attacks
    mapping(bytes32 => bool) public isValidSign;

    uint256 public totalTransfer; // Total number of transfers across all users
    uint256 public totalUsers; // Total number of unique users who have deposited

    uint256 public MIN_Limit = 100000; //Minimum deposit limit
    address public signController;

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    // Events
    event Deposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 transferCount,
        bytes32 hash
    );

    event WithdrawTokens(
        address indexed token,
        address indexed owner,
        uint256 amount
    );

    event SignControllerUpdated(
        address indexed oldController,
        address indexed newController
    );

    event MinLimitUpdated(uint256 oldLimit, uint256 newLimit);

    /**
     * @notice Contract constructor to initialize the owner and sign controller
     * @param _owner Address of the contract owner
     * @param _signController Address of the signature validator
     */
    constructor(address _owner, address _signController) Ownable(_owner) {
        require(_owner != address(0), "Invalid owner address");
        require(
            _signController != address(0),
            "Invalid sign controller address"
        );

        signController = _signController;
    }

    /**
     * @notice Allows users to deposit tokens into the vault
     * @param token Address of the token to deposit
     * @param amount Amount of tokens to deposit
     * @param sign Signature data for authorization
     * @dev Validates signature, ensures unique deposits, and updates user and contract state
     */
    function deposit(address token, uint256 amount, Sign memory sign) external {
        verifySign(msg.sender, token, amount, sign);
        uint8 decimals = IERC20(token).decimals();
        require(
            amount > MIN_Limit * (10 ** decimals),
            "Invalid deposit amount"
        );
        require(!depositedTokens[msg.sender][token], "Token already deposited");
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        if (!hasDeposited[msg.sender]) {
            totalUsers++;
            hasDeposited[msg.sender] = true;
        }

        userDeposits[msg.sender][token] += amount;
        userTransferCount[msg.sender]++;
        depositedTokens[msg.sender][token] = true;
        totalTransfer++;

        bytes32 hash = keccak256(abi.encodePacked(msg.sender, token, amount));
        emit Deposit(
            msg.sender,
            token,
            amount,
            userTransferCount[msg.sender],
            hash
        );
    }

    /**
     * @notice Internal function to validate a user's deposit signature
     * @param _user Address of the depositing user
     * @param tokenAddress Address of the token being deposited
     * @param amount Amount of tokens to deposit
     * @param sign Signature data for verification
     * @dev Prevents replay attacks by ensuring unique signatures and verifies signature authenticity
     */
    function verifySign(
        address _user,
        address tokenAddress,
        uint256 amount,
        Sign memory sign
    ) internal {
        bytes32 hash = keccak256(
            abi.encodePacked(_user, tokenAddress, amount, sign.nonce)
        );

        require(!isValidSign[hash], "Duplicate signature");
        isValidSign[hash] = true;
        require(
            signController ==
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    sign.v,
                    sign.r,
                    sign.s
                ),
            "Invalid signature"
        );
    }

    /**
     * @notice Allows the owner to withdraw tokens from the contract
     * @param _token Address of the token to withdraw
     * @param _tokenAmount Amount of tokens to withdraw
     * @dev Ensures the contract has sufficient balance before withdrawal
     */
    function withdrawTokens(
        address _token,
        uint256 _tokenAmount
    ) external onlyOwner {
        uint256 contractBalance = IERC20(_token).balanceOf(address(this));
        require(
            contractBalance >= _tokenAmount,
            "Insufficient contract balance"
        );

        require(
            IERC20(_token).transfer(owner(), _tokenAmount),
            "Token transfer failed"
        );

        emit WithdrawTokens(_token, owner(), _tokenAmount);
    }

    /**
     * @notice Retrieves the deposited amount for a user and token
     * @param user Address of the user
     * @param token Address of the token
     * @return Amount of tokens deposited by the user
     */
    function getUserDeposit(
        address user,
        address token
    ) external view returns (uint256) {
        return userDeposits[user][token];
    }

    /**
     * @notice Updates the address responsible for signature validation
     * @param _signController New address for signature validation
     * @dev Only the owner can update this address, and an event is emitted
     */
    function setSignController(address _signController) external onlyOwner {
        require(
            _signController != address(0),
            "Invalid sign controller address"
        );

        address oldController = signController;
        signController = _signController;
        emit SignControllerUpdated(oldController, _signController);
    }

    /**
     * @notice Updates the minimum deposit limit for tokens
     * @dev Only the contract owner can call this function to change the MIN_Limit value.
     *      This allows the owner to adjust the minimum deposit threshold as needed.
     * @param _minLimit The new minimum deposit limit (in base units of the token's decimals)
     */
    function setMinLimit(uint256 _minLimit) external onlyOwner {
        uint256 oldLimit = MIN_Limit;
        MIN_Limit = _minLimit;
        emit MinLimitUpdated(oldLimit, _minLimit);
    }
}