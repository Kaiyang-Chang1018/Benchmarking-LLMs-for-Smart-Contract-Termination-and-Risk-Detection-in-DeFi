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

// File: contracts/runner.sol


pragma solidity ^0.8.19;


contract RunnerV2 is Ownable{
    IERC20 public token;
    address public Manager;
    uint256 public costPerPlay;
    uint256 public timeframe = 60 * 60 * 3; // 3hours
    uint8 internal burnRatio = 25 ; // 49 %
    uint256 internal lastCall; // timestamp of last manager call
    uint256 internal depositAmt; // deposit amt
    bool private State = false; // state to control if joins allowed

    struct RoundData{
        uint256 rewardPool;
        uint256 burnPool;
    }

    struct Rounds {
        RoundData data;
        address[] lastWinners;
    }
    
    mapping(uint256 => Rounds) internal rounds;
    mapping(address=>mapping(address => uint256)) internal users;
    
    modifier onlyManager(){
        require(msg.sender == Manager, "Not Authorized");
        _;
    }

    constructor(
        address _gameToken
    ) Ownable(msg.sender){
        token = IERC20(_gameToken);
        Manager = msg.sender;
        costPerPlay = 1000 * 10 ** 18;
        depositAmt = costPerPlay;
    }
    // getters
    /*
    @param => roundId nonce;
    Returns => roundData struct
    */
    function getRoundData() public view returns(RoundData memory){
        return rounds[0].data;
    }

    /* 
    Returns => get user fungible balances 
    */
    function getUserBalances(address user,address _token) public view returns(uint256){
        return users[user][_token];
    }
    //transfer Manager
    function transferManager(address new_) public onlyManager{
        Manager = new_;
    }
    // returns the last distribution winner list

    function getLastWinners() public view returns(address[] memory){
        return rounds[0].lastWinners;
    }
    // returns deposit amount for play
    function getDepositAmt() public view returns(uint256) {
        return depositAmt;
    }
    
    //Write functions

    //start the game post deployment

    function startGame() public onlyManager{
        State = true;
    }
    // stop allowing joins
    function stopGame() public onlyManager{
        State = false;
    }

    // user enter into curr round
    function startPlay() public payable returns(bool){
        require(State == true ,"manager must call startGame()");
        require(users[msg.sender][address(token)] >= costPerPlay,"deposit first");
        users[msg.sender][address(token)] = users[msg.sender][address(token)] - costPerPlay ;
        //uint256 cr = totalRounds;
        uint256 bA = (costPerPlay * uint256(burnRatio) / 100);
        rounds[0].data.rewardPool = rounds[0].data.rewardPool +( costPerPlay - bA);
        rounds[0].data.burnPool = rounds[0].data.burnPool + bA;
        return true;
    }

    function depositUserERC() public payable {
        bool succ = token.transferFrom(msg.sender , address(this), depositAmt);
        require(succ == true,"deposit failed");
        users[msg.sender][address(token)] =users[msg.sender][address(token)] + depositAmt; 
    }

    function withdrawUserERC() public payable {
        uint256 amt = users[msg.sender][address(token)];
        bool succ = token.transfer(msg.sender , amt);
        require(succ == true,"withdraw failed");
        users[msg.sender][address(token)] =users[msg.sender][address(token)] - amt; 
    }

    // current winnerlist array -- unsafe now, be sure sum of amounts dont exceed rewardPool amounts
    function selectWinnersAndDistribute(address[] memory currWinnerList, uint256[] memory amounts) public onlyManager returns(bool){
        require(block.timestamp >= lastCall + timeframe,"timeframe not completed");
        uint256 burnPool = rounds[0].data.burnPool; 
        //save winners
        rounds[0].lastWinners = currWinnerList;
        // distribute amounts
        for(uint8 i =0 ; i < currWinnerList.length; i++) {
            uint256 amt = amounts[i];
            address x = currWinnerList[i];
            rounds[0].data.rewardPool = rounds[0].data.rewardPool - amt;
            token.transfer(x , amt);
        }
        // burn the burnPool
        rounds[0].data.burnPool = 0; 
        token.transfer(address(0x000000000000000000000000000000000000dEaD), burnPool);
        lastCall = block.timestamp;
        return true;
    }

    //manager functions for controlling contract funds
    function withdrawTokens(address to , uint256 amount) public onlyManager {
        require(State == false,"needs game to be off");
        token.transfer(to, amount);
    }

    function withdrawEth(address to, uint256 amount) public onlyManager{
        require(State == false,"needs game to be off");
        payable(to).transfer(amount);
    }
    // Setters
    function changeCost(uint256 _newCost) public onlyManager{
        costPerPlay = _newCost;
    }

    function changeDepAmt(uint256 amount) public onlyManager{
        depositAmt = amount;
    }

    function changeBurnPercent (uint8 percent) public onlyManager{
        burnRatio = percent;
    }

    function changeGameToken(address _newtoken) public onlyManager{
        token = IERC20(_newtoken);
    }
    
    //change timeframe per round
    function changeTimeframe(uint256 timeInSeconds) public onlyManager{
        timeframe = timeInSeconds;
    }

    receive() external payable{}
}