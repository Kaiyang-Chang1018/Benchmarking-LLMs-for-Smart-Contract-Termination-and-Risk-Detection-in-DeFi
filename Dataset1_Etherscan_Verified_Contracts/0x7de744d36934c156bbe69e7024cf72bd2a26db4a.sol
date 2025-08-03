/**

.____                  .__                                _____  .___     _____ __________.___ 
|    |    __ __  _____ |__| ____   ____  __ __  ______   /  _  \ |   |   /  _  \\______   \   |
|    |   |  |  \/     \|  |/    \ /  _ \|  |  \/  ___/  /  /_\  \|   |  /  /_\  \|     ___/   |
|    |___|  |  /  Y Y  \  |   |  (  <_> )  |  /\___ \  /    |    \   | /    |    \    |   |   |
|_______ \____/|__|_|  /__|___|  /\____/|____//____  > \____|__  /___| \____|__  /____|   |___|
        \/           \/        \/                  \/          \/              \/              

Luminous Web3 is pioneering the seamless integration of payment processes through their advanced wallet API. 
This platform offers a unique blend of privacy, security, and efficiency for Web3 developers, making it effortless 
to connect to any wallet API. Its standout features include anonymous transactions on Solana, trusted third-party 
technology for secure transactions, multi-chain support, and an SDK designed for developers to build smarter payment systems easily. 
With just a few lines of code, businesses can streamline their payment systems, ensuring fast, secure, and versatile transactions across the globe. 
For more information, visit us. Lumin Technologies 

Website: https://www.luminousweb3.io/
X: https://x.com/luminousapi
Telegram Group: https://t.me/luminousapi
Telegram Support: https://t.me/luminoussupport
Telegram AI Calculation Bot: https://t.me/luminousaibot 

*/


// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

contract Lumin is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;
    address private uniswapV2Pair;
    IUniswapV2Router02 private uniswapV2Router;

    uint256 private constant _initialBuyTax = 10;
    uint256 private constant _initialSellTax = 15;
    uint256 private constant _reduceBuyTaxAt = 20;
    uint256 private constant _reduceSellTaxAt = 30;
    uint256 private constant _preventSwapBefore = 25;
    uint256 private _finalBuyTax = 5;
    uint256 private _finalSellTax = 5;
    uint256 private _buyCount = 0;
    uint256 private _countTax = 0;

    string private constant _name = unicode"Luminous AI API";
    string private constant _symbol = unicode"Lumin";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 10000000 * 10**_decimals;
    uint256 public constant _countTrigger = 20000 * 10**_decimals;
    uint256 public constant _taxSwapThreshold = 20000 * 10**_decimals;
    uint256 public _maxTaxSwap = 100000 * 10**_decimals;
    uint256 public _maxTxAmount = 100000 * 10**_decimals;
    uint256 public _maxWalletSize = 250000 * 10**_decimals;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event FinalTax(uint256 _valueBuy, uint256 _valueSell, bool _shelid);
    event TradingActive(bool _tradingOpen, bool _swapEnabled);
    event maxAmount(uint256 _value);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address taxWallet) {
        _taxWallet = payable(taxWallet);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(
            owner != address(0) && spender != address(0),
            "ERC20: approve the zero address"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {
            if (!tradingOpen) {
                require(
                    _isExcludedFromFee[to] || _isExcludedFromFee[from],
                    "trading not yet open"
                );
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            } else if (from == uniswapV2Pair && to != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);
            }

            _countTax += taxAmount;
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore &&
                _countTax > _countTrigger
            ) {
                uint256 getMin = (contractTokenBalance > _maxTaxSwap)
                    ? _maxTaxSwap
                    : contractTokenBalance;
                swapTokensForEth((amount > getMin) ? getMin : amount);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                _countTax = 0;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function createPair() external onlyOwner {
        require(!tradingOpen, "init already called");
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokenAmount,
            0,
            0,
            _msgSender(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading already open");
        swapEnabled = true;
        tradingOpen = true;
        emit TradingActive(tradingOpen, swapEnabled);
    }

    function maxLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit maxAmount(_tTotal);
    }

    function clearETH() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "ETH balance must be greater than 0");
        (bool success,) = address(this).call{value: ethBalance}("");
        require(success, "Failed to clear ETH balance");
    }

    function reduceFee(uint256 _valueBuy, uint256 _valueSell) external onlyOwner {
        require( _valueBuy <= 30 && _valueSell <= 30 && tradingOpen,
            "Exceeds value"
        );
        _finalBuyTax = _valueBuy;
        _finalSellTax = _valueSell;
        uint256 clogSheild = _finalSellTax > 5 ? _maxTaxSwap = (5 *_tTotal).div(1000)  : (1 *_tTotal).div(100);
        emit FinalTax(_valueBuy, _valueSell, (clogSheild == (5 *_tTotal).div(1000)));
    }

    receive() external payable {}
}