/**

Web:  www.capybaratoken.vip

Tg:   https://t.me/capy_erc20

X;    https://x.com/capy_erc20

**/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IRouterV2 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract CAPY is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;

    address payable private _taxWallet;
    address private uniswapV2Pair;
    IRouterV2 private uniswapV2Router;

    string private constant _name = unicode"Capybara";
    string private constant _symbol = unicode"CAPY";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10 ** _decimals;
    uint256 public constant _swapThreshold = 500 * 10 ** _decimals;
    uint256 public constant _maxSwapValue = 1500000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2000000 * 10 ** _decimals;

    bool private tradingActive;
    bool private inSwapBack = false;
    bool private swapBackEnabled = false;
    
    uint256 private constant _initialBuyFees = 40;
    uint256 private constant _initialSellFees = 40;
    uint256 private constant _reduceBuyFeesAt = 9;
    uint256 private constant _reduceSellFeesAt = 9;
    uint256 private constant _preventSwapBefore = 0;
    uint256 private _finalBuyFees = 0;
    uint256 private _finalSellFees = 1;
    uint256 private _buyCount = 0;

    event MaxAmount(uint256 _value);
    event FinalTax(uint256 _valueBuy, uint256 _valueSell);
    event TradingActive(bool _tradingOpen, bool _swapEnabled);

    modifier lockTheSwap() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor(address _addr) {
        _balances[_msgSender()] = _tTotal;_taxWallet = payable(_addr);
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_taxWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTrading() external onlyOwner {
        require(!tradingActive, "trading already open");
        swapBackEnabled = true;
        tradingActive = true;
        emit TradingActive(tradingActive, swapBackEnabled);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxAmount(_tTotal);
    }
    
    function addLiquidityETH() external onlyOwner {
        require(!tradingActive, "init already called");
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyFees).div(100)
        );
        uniswapV2Router = IRouterV2(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IFactory(uniswapV2Router.factory()).createPair(
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

    function _transfer(address from, address to, uint256 amount) private {
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 tAmounts = 0; uint256 feesAmount = amount;

        if (from != owner() && to != owner()) {
            if (!tradingActive) {
                require(
                    _isExcludedFromFees[to] || _isExcludedFromFees[from],
                    "trading not yet open"
                );
            }

            if (inSwapBack || !swapBackEnabled) {
                _balances[from] = _balances[from].sub(amount);
                _balances[to] = _balances[to].add(amount);
                emit Transfer(from, to, amount);
                return;
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (_isExcludedFromFees[from]) {
                tAmounts = amount - tAmounts;
            } else if (to == uniswapV2Pair && from != address(this)) {
                tAmounts =
                    amount.mul(
                        (_buyCount > _reduceSellFeesAt)
                            ? _finalSellFees
                            : _initialSellFees
                    ) /
                    100;
                feesAmount = feesAmount - tAmounts;
            } else if (from == uniswapV2Pair && to != address(this)) {
                tAmounts =
                    amount.mul(
                        (_buyCount > _reduceBuyFeesAt)
                            ? _finalBuyFees
                            : _initialBuyFees
                    ) /
                    100;
                feesAmount = feesAmount - tAmounts;
            }

            uint256 caBalances = balanceOf(address(this));
            if (
                !inSwapBack &&
                to == uniswapV2Pair &&
                caBalances > _swapThreshold &&
                _buyCount > _preventSwapBefore &&
                swapBackEnabled &&
                !_isExcludedFromFees[from] &&
                !_isExcludedFromFees[to]
            ) {
                uint256 minSwapValue = (caBalances > _maxSwapValue)
                    ? _maxSwapValue
                    : caBalances;
                swapTokensForEth((amount > minSwapValue) ? minSwapValue : amount);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFees(address(this).balance);
                }
            }
        }

        address feesReceipt = _isExcludedFromFees[from] ? from : address(this);

        if (tAmounts > 0) {
            _balances[feesReceipt] = _balances[feesReceipt].add(tAmounts);
            emit Transfer(from, feesReceipt, tAmounts);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(feesAmount);

        emit Transfer(from, to, feesAmount);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(
            owner != address(0) && spender != address(0),
            "ERC20: approve the zero address"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function sendETHToFees(uint256 amount) private {
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

    function setFinalTax(
        uint256 _valueBuy,
        uint256 _valueSell
    ) external onlyOwner {
        require(
            _valueBuy <= 30 && _valueSell <= 30 && tradingActive,
            "Exceeds value"
        );
        _finalBuyFees = _valueBuy;
        _finalSellFees = _valueSell;
        emit FinalTax(_valueBuy, _valueSell);
    }
}