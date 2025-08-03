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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

// File: boznistakefinal.sol


pragma solidity ^0.8.0;



interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

interface IEtherVistaFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function routerSetter() external view returns (address);
    function router() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setRouterSetter(address) external;
    function setRouter(address) external;
}

interface IEtherVistaPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    
    function setMetadata(string calldata website, string calldata image, string calldata description, string calldata chat, string calldata social) external; 
    function websiteUrl() external view returns (string memory);
    function imageUrl() external view returns (string memory);
    function tokenDescription() external view returns (string memory);
    function chatUrl() external view returns (string memory);
    function socialUrl() external view returns (string memory);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function updateProvider(address user) external;
    function euler(uint) external view returns (uint256);
    function viewShare() external view returns (uint256 share);
    function claimShare() external;
    function poolBalance() external view returns (uint);
    function totalCollected() external view returns (uint);
    
    function setProtocol(address) external;
    function protocol() external view returns (address);
    function payableProtocol() external view returns (address payable origin);

    function creator() external view returns (address);
    function renounce() external;

    function setFees() external;
    function updateFees(uint8, uint8, uint8, uint8) external;
    function buyLpFee() external view returns (uint8);
    function sellLpFee() external view returns (uint8);
    function buyProtocolFee() external view returns (uint8);
    function sellProtocolFee() external view returns (uint8);
    function buyTotalFee() external view returns (uint8);
    function sellTotalFee() external view returns (uint8);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function first_mint(address to, uint8 buyLp, uint8 sellLp, uint8 buyProtocol, uint8 sellProtocol, address protocolAddress) external returns (uint liquidity);   
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address _token0, address _token1) external;
}

contract BonziHARDSTAKE is ReentrancyGuard {
    IERC20 public immutable stakingToken;
    address StakingTokenAddress;

    uint256 public constant LOCK_TIME = 14 days;
    uint256 private bigNumber = 10**20;
    uint256 public totalCollected = 0;
    uint256 public poolBalance = 0;
    uint256 public totalSupply = 0; 
    uint256 public cost = 99;
    address private costSetter;
    address private factory;
    AggregatorV3Interface internal priceFeed;

    Contributor[10] public recentContributors;
    uint8 public contributorsCount = 0;

    struct Contributor {
        address addr;
        uint256 timestamp;
    }

     function getEthUsdcPrice() internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price/100); 
    }

    function usdcToEth(uint256 usdcAmount) public view returns (uint256) {
        uint256 ethUsdcPrice = getEthUsdcPrice();
        return (usdcAmount * 1e6*1e18 / ethUsdcPrice); 
    }

    struct Staker {
        uint256 amountStaked;
        uint256 stakingTime;
        uint256 euler0;
    }

    uint256[] public euler; 
    mapping(address => Staker) public stakers;

    constructor(address _stakingToken, address _oracleAddress, address _factory) {
        stakingToken = IERC20(_stakingToken);
        StakingTokenAddress = _stakingToken;
        priceFeed = AggregatorV3Interface(_oracleAddress);
        costSetter = msg.sender;
        factory = _factory;
    }

    receive() external payable {
        poolBalance += msg.value;
        totalCollected += msg.value;
        updateEuler(msg.value);
    }

    function setCost(uint256 _cost) external {
        require(msg.sender == costSetter);
        cost = _cost;
    }

    function updateEuler(uint256 Fee) internal { 
        if (euler.length == 0){
            euler.push((Fee*bigNumber)/totalSupply);
        }else{
            euler.push(euler[euler.length - 1] + (Fee*bigNumber)/totalSupply); 
        }
    }

    function contributeETH(address contributor) external payable nonReentrant {
        require(msg.value >= usdcToEth(cost), "Insufficient ETH sent");
        IEtherVistaPair pair = IEtherVistaPair(contributor);
        require(IEtherVistaFactory(factory).getPair(pair.token0(), pair.token1()) == contributor);

        if (contributorsCount == 10) {
            require(block.timestamp >= recentContributors[9].timestamp + 1 days, "Less than a day since last contribution");
            for (uint8 i = 9; i > 0; i--) {
                recentContributors[i] = recentContributors[i - 1];
            }
        } else if (contributorsCount == 0) {
            contributorsCount++; 
        } else {
            for (uint8 i = contributorsCount; i > 0; i--) {
                recentContributors[i] = recentContributors[i - 1];
            }
            contributorsCount++;
        }

        recentContributors[0] = Contributor(contributor, block.timestamp);

        poolBalance += msg.value;
        totalCollected += msg.value;
        updateEuler(msg.value);
    }

    function stake(uint256 _amount, address user, address token) external nonReentrant {
        require(msg.sender == IEtherVistaFactory(factory).router(), 'EtherVista: FORBIDDEN');
        require(token == StakingTokenAddress);

        totalSupply += _amount; 

        Staker storage staker = stakers[user];
        staker.amountStaked += _amount; 
        staker.stakingTime = block.timestamp;
        if (euler.length == 0){
            staker.euler0 = 0;
        } else {
            staker.euler0 = euler[euler.length - 1];
        }
    }

    function withdraw(uint256 _amount) external nonReentrant {
        Staker storage staker = stakers[msg.sender];
        require(staker.amountStaked >= _amount, "Insufficient staked amount");
        require(block.timestamp >= staker.stakingTime + LOCK_TIME, "Tokens are still locked");

        staker.amountStaked -= _amount;
        totalSupply -= _amount; 

        require(stakingToken.transfer(msg.sender, _amount), "Transfer failed");

        if (staker.amountStaked == 0) {
            delete stakers[msg.sender];
        } else {
            staker.stakingTime = block.timestamp;
            if (euler.length == 0){
                staker.euler0 = 0;
            } else {
                staker.euler0 = euler[euler.length - 1];
            }
        }
    }

    function claimShare() public nonReentrant {
        require(euler.length > 0, 'EtherVistaPair: Nothing to Claim');
        uint256 balance = stakers[msg.sender].amountStaked;
        uint256 time = stakers[msg.sender].stakingTime;
        uint256 share = (balance * (euler[euler.length - 1] - stakers[msg.sender].euler0))/bigNumber;
        stakers[msg.sender] = Staker(balance, time, euler[euler.length - 1]);
        poolBalance -= share;
        (bool sent,) = payable(msg.sender).call{value: share}("");
        require(sent, "Failed to send Ether");
    }
    
    function viewShare() public view returns (uint256 share) {
        if (euler.length == 0){
            return 0;
        }else{
            return stakers[msg.sender].amountStaked * (euler[euler.length - 1] - stakers[msg.sender].euler0)/bigNumber;
        }
    }

    function isSpotAvailable() public view returns (bool) {
        if (contributorsCount < 10) {
            return true;
        } else {
            return (block.timestamp >= recentContributors[9].timestamp + 1 days);
        }
    }

    function getStakerInfo(address _staker) public view returns (
        uint256 amountStaked,
        uint256 timeLeftToUnlock,
        uint256 currentShare
    ) {
        Staker storage staker = stakers[_staker];
        
        amountStaked = staker.amountStaked;
        
        if (block.timestamp < staker.stakingTime + LOCK_TIME) {
            timeLeftToUnlock = (staker.stakingTime + LOCK_TIME) - block.timestamp;
        } else {
            timeLeftToUnlock = 0;
        }
        
        if (euler.length > 0 && staker.amountStaked > 0) {
            currentShare = (staker.amountStaked * (euler[euler.length - 1] - staker.euler0)) / bigNumber;
        } else {
            currentShare = 0;
        }
    }

    function getContributors() public view returns (address[10] memory) {
        address[10] memory contributors;
        for (uint8 i = 0; i < contributorsCount; i++) {
            contributors[i] = recentContributors[i].addr;
        }
        return contributors;
    }

}