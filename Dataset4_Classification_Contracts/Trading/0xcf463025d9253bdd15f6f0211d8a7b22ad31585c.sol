// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        
        _status = _NOT_ENTERED;
    }

   
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: InfoSphere.sol


pragma solidity ^0.8.26;

interface IUniswapV2Router02 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
abstract contract ERC20 {
    mapping(address => uint256) internal _balances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_, uint256 initialSupply, address owner_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = initialSupply;
        _balances[owner_] = initialSupply;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        require(_balances[msg.sender] >= amount, "ERC20: insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        return true;
    }
}
contract InfoSphere is ERC20, Ownable, ReentrancyGuard {
    IUniswapV2Router02 public uniswapRouter;
    address public WETH;
    uint256 public constant FIXED_SUPPLY = 999999999999 * 10 ** 18;
    uint256 public constant MIN_PRICE_IN_ETH = 3300000000000000; 
    event TokensSold(address indexed seller, uint256 amount, uint256 price);
    constructor(address _uniswapRouter, address _WETH) ERC20("InfoSphere", "ISPH", FIXED_SUPPLY, msg.sender) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        WETH = _WETH;
    }
  
function getCurrentPrice() public view returns (uint256) {
        address[] memory path = new address[](2); 
        path[0] = address(this); 
        path[1] = WETH; 
        uint[] memory amounts = uniswapRouter.getAmountsOut(1 * 10**18, path);
        require(amounts.length > 1, "Insufficient liquidity in pool");
        return amounts[1];
    }



    // Function to sell tokens with price limit
    function sellTokens(uint256 amount) external nonReentrant {
        uint256 currentPrice = getCurrentPrice();
        require(currentPrice >= MIN_PRICE_IN_ETH, "Price is below the minimum limit");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[address(this)] += amount;
        emit TokensSold(msg.sender, amount, currentPrice);
    }
}