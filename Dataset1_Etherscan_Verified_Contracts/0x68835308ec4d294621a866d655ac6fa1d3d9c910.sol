/**
 *Submitted for verification at Etherscan.io on 2024-09-28
 */

// SPDX-License-Identifier: MIT

/**
Name = "PeTrump"
Symbol = "PTP"
Website:  https://petrump.com
Telegram: https://t.me/peptrump
Twitter:  https://x.com/EthPetrump

*/
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function isContract(address account) internal view virtual returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

abstract contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: Unauthorized ownable operaion call");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapRouter {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract IPeTrumpToken is Context, Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    string private _name = "PeTrump";
    string private _symbol = "PTP";
    uint8 private _decimals = 9;

    uint256 private _totalSupply = 420_690_000_000_000 * (10 ** _decimals);
    uint256 private _maxTxAmount = 8_413_800_000_000 * (10 ** _decimals);
    uint256 private _maxWalletSize = 8_413_800_000_000 * (10 ** _decimals);
    uint256 private _feeSwapThreshold = 4_206_900_000_000 * (10 ** _decimals);
    uint256 private _maxFeeSwap = 8_413_800_000_000 * (10 ** _decimals);

    address payable private _taxAdminAccount;

    address internal _uniswapRouterAddress;
    address internal _uniswapPairAddress;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _buyCount = 0;
    uint256 private _sellCount = 0;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 23;

    bool private _inSwap = false;
    uint256 private _firstBlock = 0;
    bool private _tradingOpen = false;
    uint256 private _lastSellBlock = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor() {
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
        _balances[_msgSender()] = _totalSupply;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function maxTxAmount() external view onlyAdmin returns (uint256) {
        return _maxTxAmount;
    }

    function maxWalletSize() external view onlyAdmin returns (uint256) {
        return _maxWalletSize;
    }

    function feeSwapThreshold() external view onlyAdmin returns (uint256) {
        return _feeSwapThreshold;
    }

    function maxFeeSwap() external view onlyAdmin returns (uint256) {
        return _maxFeeSwap;
    }

    function pairAddress() external view onlyAdmin returns (address) {
        return _uniswapPairAddress;
    }

    function admin() public view onlyAdmin returns (address) {
        return _taxAdminAccount;
    }

    function uniswapRouterAddress() external view onlyAdmin returns (address) {
        return _uniswapRouterAddress;
    }

    modifier onlyAdmin() {
        require(_owner == _msgSender() || _taxAdminAccount == _msgSender(), "Unauthorized operations call");
        _;
    }

    function isExcludedFromFee(address account) external view onlyAdmin returns (bool) {
        return _isExcludedFromFee[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);
            if (from == _uniswapPairAddress && to != _uniswapRouterAddress && !_isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the max transaction amount");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the max wallet size");

                if (_firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyCount++;
            }

            if (to == _uniswapPairAddress && from != address(this)) {
                taxAmount = amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == _uniswapPairAddress && _tradingOpen && contractTokenBalance > _feeSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > _lastSellBlock) {
                    _sellCount = 0;
                }
                require(_sellCount < 3, "Exceeds max sell per block");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxFeeSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                _sellCount++;
                _lastSellBlock = block.number;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        uint256 finalAmountToSend = amount.sub(taxAmount);
        _balances[to] = _balances[to].add(finalAmountToSend);
        emit Transfer(from, to, amount.sub(finalAmountToSend));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function openTrading() external onlyAdmin {
        require(!_tradingOpen, "Trading is already open");
        IUniswapRouter uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _uniswapRouterAddress = address(uniswapRouter);
         _approve(address(this), _uniswapRouterAddress, _totalSupply);
        _uniswapPairAddress = IUniswapFactory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, _owner, block.timestamp);
        IERC20(_uniswapPairAddress).approve(address(uniswapRouter), type(uint).max);
        _tradingOpen = true;
        _firstBlock = block.number;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        IUniswapRouter uniswapRouter = IUniswapRouter(_uniswapRouterAddress);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function setAdminTaxFeeAccount(address taxAccount) external onlyAdmin {
        _taxAdminAccount = payable(taxAccount);
        _isExcludedFromFee[_taxAdminAccount] = true;
    }

    function removeLimits() external onlyAdmin {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _taxAdminAccount.transfer(amount);
    }

    function reduceFee(uint256 newFee) external onlyAdmin {
        require(newFee <= _finalBuyTax && newFee <= _finalSellTax);
        _finalBuyTax = newFee;
        _finalSellTax = newFee;
    }

    function manualSwap() external onlyAdmin {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function manualsend() external onlyAdmin {
        require(address(this).balance > 0, "Contract balance must be greater than zero");
        uint256 balance = address(this).balance;
        sendETHToFee(balance);
    }

    receive() external payable {}
}