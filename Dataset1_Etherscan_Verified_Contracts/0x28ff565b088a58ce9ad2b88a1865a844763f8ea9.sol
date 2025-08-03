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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/interfaces/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;


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

// File: tokensale.sol


pragma solidity >=0.8.25;




interface ERC20 {
    function transferFrom(address from, address to, uint value) external;
}

contract CXCTokenSale is Ownable {
    address public paymentToken;
    address public tokenBeingSold;
    uint256 public currentStage;
    address public admin;
    uint256 public totalStages;
    uint256 public totalTokensSoldTillNow;
    address public receiver;

    struct StageStruct {
        uint256 maxTokensForStage;
        uint256 totalTokensSold;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(uint256 => StageStruct) public stageInfo;

    event BuyTokens(address receiver,uint256 amount);
    event withdrawTokens(address tokenAddress,uint256 amount);


    modifier onlyAdmin(){
        require(msg.sender==admin,"Only Admin Can Call This Function");
        _;
    }
    
    constructor(
        address _paymentToken,
        address _tokenBeingSold,
        address _admin,
        address _receiver
    ) public Ownable(msg.sender){
        paymentToken = _paymentToken;
        tokenBeingSold = _tokenBeingSold;
        admin = _admin;
        receiver = _receiver;
    }

    function addStage(uint256 _maxTokensForStage, uint256 _price, uint256 _startTime, uint256 _endTime, bool _isActive) external onlyAdmin{
        require(_startTime<_endTime,"Start time should be greater than endtime");
        require(_maxTokensForStage>0,"Max cap should be greater than 0");
        uint256 _stage = totalStages + 1;
        stageInfo[_stage] = StageStruct(_maxTokensForStage, 0, _price, _startTime, _endTime);
        if(_isActive==true){
            currentStage = _stage;
        }
        totalStages++;
    }

    function updateStage(uint256 _stage, uint256 _maxTokensForStage, uint256 _price, uint256 _startTime, uint256 _endTime) external onlyAdmin{
        require(_startTime<_endTime,"Start time should be greater than endtime");
        require(_maxTokensForStage>0,"Max cap should be greater than 0");
        StageStruct storage stage = stageInfo[_stage];
        stage.maxTokensForStage = _maxTokensForStage;
        stage.price = _price;
        stage.startTime = _startTime;
        stage.endTime = _endTime;
    }

    function startStage(uint256 _stage) external onlyAdmin{
        require(_stage<=totalStages && _stage>0,"Invalid Stage Id");
        StageStruct storage stage = stageInfo[_stage];
        require(stage.endTime>block.timestamp,"Stage has expired");
        currentStage = _stage;
    }

    function disableSale()  external onlyAdmin{
        currentStage = 0;
    }

    function buyTokens(uint256 _amount) external {
        require(currentStage!=0,"No active stage");
        require(_amount>0,"Zero amount can't be purchased");
        require(receiver!=address(0),"Receiver Is Zero Address");
        uint256 cxcBal = IERC20(tokenBeingSold).balanceOf(address(this));
        require(cxcBal>=_amount,"Contract have insufficient CXC tokens");
        StageStruct storage stage = stageInfo[currentStage];
        require(block.timestamp >= stage.startTime && block.timestamp <= stage.endTime, "Token sale not available at this time");
        require(_amount <= stage.maxTokensForStage - stage.totalTokensSold, "Exceeds stage cap");
        uint256 decimals = IERC20Metadata(tokenBeingSold).decimals();

         ERC20(paymentToken).transferFrom(msg.sender, receiver,( _amount * stage.price)/(10**decimals));
        
        

        // Transfer tokens being sold from admin to buyer
        IERC20(tokenBeingSold).transfer(msg.sender, _amount);
        
        stage.totalTokensSold += _amount;
        totalTokensSoldTillNow += _amount;
        emit BuyTokens(msg.sender, _amount);
    }

    function withdrawDumpedTokens(address token) external onlyAdmin{
        require(receiver!=address(0),"Receiver Is Zero Address");
        IERC20(token).transfer(receiver, IERC20(token).balanceOf(address(this)));
        emit withdrawTokens(token,IERC20(token).balanceOf(address(this)));
    }

    function setReceiverAddress(address _receiver) external onlyAdmin{
        require(receiver!=address(0),"Receiver Is Zero Address");
        receiver = _receiver;
    }

    function setAdmin(address _admin) external onlyAdmin{
        admin = _admin;
    }
}