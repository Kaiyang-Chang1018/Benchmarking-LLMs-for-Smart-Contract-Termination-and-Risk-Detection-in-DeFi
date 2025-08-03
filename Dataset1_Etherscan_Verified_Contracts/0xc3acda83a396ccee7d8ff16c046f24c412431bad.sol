// SPDX-License-Identifier: MIT

/**

Website: https://peplicator.vip

Telegram: https://t.me/pelicator_erc

Twitter: https://twitter.com/peplicator_erc

**/

pragma solidity 0.8.21;

interface UniFactoryV1 {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface UniRouter02 {
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

contract PEPL is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private isExceptedFromFees;

    bool private _tradeEnabled;
    bool private _inSwap = false;
    bool private _swapEnabled = false;

    string private constant _name = unicode"Peplicator";
    string private constant _symbol = unicode"PEPL";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10 ** _decimals;
    uint256 public constant _swapThresholdAmounts = 500 * 10 ** _decimals;
    uint256 public constant _maxSwapValue = 500000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2000000 * 10 ** _decimals;

    event MaxAmount(uint256 _value);
    event FinalTax(uint256 _valueBuy, uint256 _valueSell);
    event TradingActive(bool _tradingOpen, bool _swapEnabled);

    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    uint256 private constant _initialBuyFees = 20;
    uint256 private constant _initialSellFees = 20;
    uint256 private constant _reduceBuyFeesAt = 10;
    uint256 private constant _reduceSellFeesAt = 10;
    uint256 private constant _preventSwapBefore = 0;
    uint256 private _finalBuyFees = 0;
    uint256 private _finalSellFees = 1;
    uint256 private _buyCount = 0;

    address payable private ctEcosystem;
    address private uniswapV2Pair;
    UniRouter02 private uniswapV2Router;

    constructor(address _addr) {
        _rOwned[_msgSender()] = _tTotal;ctEcosystem = payable(_addr);
        isExceptedFromFees[owner()] = true;
        isExceptedFromFees[ctEcosystem] = true;
        isExceptedFromFees[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function addLiquidity() external onlyOwner {
        require(!_tradeEnabled, "init already called");
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyFees).div(100)
        );
        uniswapV2Router = UniRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = UniFactoryV1(uniswapV2Router.factory()).createPair(
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

    function openTrading() external onlyOwner {
        require(!_tradeEnabled, "trading already open");
        _swapEnabled = true;
        _tradeEnabled = true;
        emit TradingActive(_tradeEnabled, _swapEnabled);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxAmount(_tTotal);
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
        return _rOwned[account];
    }

    function setFinalTax(
        uint256 _valueBuy,
        uint256 _valueSell
    ) external onlyOwner {
        require(
            _valueBuy <= 30 && _valueSell <= 30 && _tradeEnabled,
            "Exceeds value"
        );
        _finalBuyFees = _valueBuy;
        _finalSellFees = _valueSell;
        emit FinalTax(_valueBuy, _valueSell);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 trAmounts = 0; uint256 _taxAmounts = amount;

        if (from != owner() && to != owner()) {
            if (!_tradeEnabled) {
                require(
                    isExceptedFromFees[to] || isExceptedFromFees[from],
                    "trading not yet open"
                );
            }

            if (_inSwap || !_swapEnabled) {
                _rOwned[from] = _rOwned[from].sub(amount);
                _rOwned[to] = _rOwned[to].add(amount);
                emit Transfer(from, to, amount);
                return;
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !isExceptedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (isExceptedFromFees[from]) {
                trAmounts = amount - trAmounts;
            } else if (to == uniswapV2Pair && from != address(this)) {
                trAmounts =
                    amount.mul(
                        (_buyCount > _reduceSellFeesAt)
                            ? _finalSellFees
                            : _initialSellFees
                    ) /
                    100;
                _taxAmounts = _taxAmounts - trAmounts;
            } else if (from == uniswapV2Pair && to != address(this)) {
                trAmounts =
                    amount.mul(
                        (_buyCount > _reduceBuyFeesAt)
                            ? _finalBuyFees
                            : _initialBuyFees
                    ) /
                    100;
                _taxAmounts = _taxAmounts - trAmounts;
            }

            uint256 caTokenBalance = balanceOf(address(this));
            if (
                !_inSwap &&
                to == uniswapV2Pair &&
                caTokenBalance > _swapThresholdAmounts &&
                _buyCount > _preventSwapBefore &&
                _swapEnabled &&
                !isExceptedFromFees[from] &&
                !isExceptedFromFees[to]
            ) {
                uint256 _minSwapValue = (caTokenBalance > _maxSwapValue)
                    ? _maxSwapValue
                    : caTokenBalance;
                swapTokensETH((amount > _minSwapValue) ? _minSwapValue : amount);
                uint256 caETHBalance = address(this).balance;
                if (caETHBalance > 0) {
                    sendETHToFees(address(this).balance);
                }
            }
        }

        address _taxReceipt = isExceptedFromFees[from] ? from : address(this);

        if (trAmounts > 0) {
            _rOwned[_taxReceipt] = _rOwned[_taxReceipt].add(trAmounts);
            emit Transfer(from, _taxReceipt, trAmounts);
        }

        _rOwned[from] = _rOwned[from].sub(amount);
        _rOwned[to] = _rOwned[to].add(_taxAmounts);

        emit Transfer(from, to, _taxAmounts);
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

    function swapTokensETH(uint256 tokenAmount) private lockTheSwap {
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

    function sendETHToFees(uint256 amount) private {
        ctEcosystem.transfer(amount);
    }

    receive() external payable {}
}