// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: Fundraising Final.sol


pragma solidity ^0.8.0;



contract NagymarosFundraising is Ownable {
    IERC20 private Stablecoin;
    IERC20 private ProjectToken;

    uint256 public fundraisingGoal;
    uint256 public ticketSize;
    uint256 public StablecoinToProjectTokenRatio;
    uint256 public deadline;
    uint256 public totalContributed;

    uint256 private constant FEE_PERCENTAGE = 250;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public tokens;
    address[] private contributors;

    address public feeReceiver;
    uint256 public totalStablecoinFees;
    uint256 public totalProjectTokenFees;

    address public projectWallet;

    bool public finalized = false;
    bool public fundraisingCanceled = false;

    constructor(address _Stablecoin, address _ProjectToken, address _owner) Ownable(_owner) {
        Stablecoin = IERC20(_Stablecoin);
        ProjectToken = IERC20(_ProjectToken);
    }

    function setFundraisingDetails(
        uint256 _goal, 
        uint256 _ticketSize, 
        uint256 _StablecoinToProjectTokenRatio, 
        uint256 _deadline, 
        address _feeReceiver
    ) external onlyOwner {
        require(_goal % _ticketSize == 0, "Goal must be a multiple of ticket size");

        fundraisingGoal = _goal;
        ticketSize = _ticketSize;
        StablecoinToProjectTokenRatio = _StablecoinToProjectTokenRatio;
        deadline = _deadline;
        feeReceiver = _feeReceiver;

        totalContributed = 0;
        delete contributors;

        uint256 requiredProjectTokenAmount = (fundraisingGoal * StablecoinToProjectTokenRatio) / 1e18;
        require(ProjectToken.transferFrom(msg.sender, address(this), requiredProjectTokenAmount), "ProjectToken transfer failed");
    }

    function setProjectWallet(address _projectWallet) external onlyOwner {
        require(_projectWallet != address(0), "Invalid address");
        projectWallet = _projectWallet;
    }

    function contribute(uint256 amount) external {
        require(block.timestamp < deadline, "The fundraising period has ended");
        require(amount % ticketSize == 0, "Amount must be a multiple of the ticket size");
        require(totalContributed + amount <= fundraisingGoal, "Contribution exceeds the goal");

        Stablecoin.transferFrom(msg.sender, address(this), amount);
        contributions[msg.sender] += amount;
        totalContributed += amount;

        if (!isContributor(msg.sender)) {
            contributors.push(msg.sender);
        }
    }

    function finalizeFundraising() external onlyOwner {
        require(block.timestamp >= deadline || totalContributed == fundraisingGoal, "Fundraising not yet ended or goal not met");
        require(totalContributed >= fundraisingGoal, "Fundraising goal not met");
        require(!finalized, "Fundraising already finalized");
        require(projectWallet != address(0), "Project wallet not set");

        finalized = true;

        uint256 totalStablecoinFee = (totalContributed * FEE_PERCENTAGE) / 10000;
        Stablecoin.transfer(feeReceiver, totalStablecoinFee);
        totalStablecoinFees += totalStablecoinFee;

        uint256 totalProjectTokenAmount = ((totalContributed * StablecoinToProjectTokenRatio) / 1e18);
        uint256 totalProjectTokenFee = (totalProjectTokenAmount * FEE_PERCENTAGE) / 10000;
        ProjectToken.transfer(feeReceiver, totalProjectTokenFee);
        totalProjectTokenFees += totalProjectTokenFee;

        uint256 remainingStablecoin = totalContributed - totalStablecoinFee;
        Stablecoin.transfer(projectWallet, remainingStablecoin);

        uint256 netProjectTokenAmount = totalProjectTokenAmount - totalProjectTokenFee;
        for (uint i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 contributortoken = (contributions[contributor] * netProjectTokenAmount) / totalContributed;
            tokens[contributor] = contributortoken;
        }
    }

    function claimtokens() public {
        require(finalized, "Fundraising not yet finalized");
        require(tokens[msg.sender] > 0, "No tokens available or already claimed");

        uint256 token = tokens[msg.sender];
        tokens[msg.sender] = 0;
        ProjectToken.transfer(msg.sender, token);
    }

    function cancelFundraising() external onlyOwner {
        require(!finalized, "Fundraising already finalized");
        finalized = true;
        fundraisingCanceled = true;
        for (uint i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            Stablecoin.transfer(contributor, contributions[contributor]);
            contributions[contributor] = 0; // Reset contributions
        }
    }

    function isContributor(address addr) private view returns (bool) {
        for (uint i = 0; i < contributors.length; i++) {
            if (contributors[i] == addr) {
                return true;
            }
        }
        return false;
    }
}