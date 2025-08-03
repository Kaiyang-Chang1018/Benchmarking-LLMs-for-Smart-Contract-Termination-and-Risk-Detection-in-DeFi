pragma solidity =0.5.17;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract Token is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    address public owner;
    uint256 public _totalSupply = 10000 * 1e18; // 10k tokens with 18 decimals
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    bool public tradingEnabled = false;
    address public v2Router;
    address public v2PairAddress;
    mapping (address => bool) public isWhitelisted;

    modifier onlyOwner {
        require(msg.sender == owner, 'This function can only be executed by the owner');
        _;
    }

    constructor (
        string memory _nameAndSymbol,
        uint256 __totalSupply,
        uint256 _decimals,
        address _v2Router
    ) public {
        _balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        name = _nameAndSymbol;
        symbol = _nameAndSymbol;
        decimals = _decimals;
        _totalSupply = __totalSupply * 10 ** _decimals;
        v2Router = _v2Router;
        address factory = IUniswapV2Router02(v2Router).factory();
        address weth = IUniswapV2Router02(v2Router).WETH();
        v2PairAddress = IUniswapV2Factory(factory).createPair(address(this), weth);
        isWhitelisted[msg.sender] = true;
        isWhitelisted[v2PairAddress] = true;
        isWhitelisted[v2Router] = true;
        isWhitelisted[factory] = true;
    }

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
    }

    function disableTrading() external onlyOwner {
        tradingEnabled = false;
    }

    function addRemoveWhitelisted(address[] calldata _users, bool _addOrRemove) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            isWhitelisted[_users[i]] = _addOrRemove;
        }
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return _balances[_user];
    }

    function allowance(address _user, address spender) public view returns (uint256) {
        return _allowed[_user][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(tradingEnabled || (isWhitelisted[from] && isWhitelisted[to]), 'Must be whitelisted');
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _approve(address _user, address spender, uint256 value) internal {
        require(spender != address(0));
        require(_user != address(0));

        _allowed[_user][spender] = value;
        emit Approval(_user, spender, value);
    }
}