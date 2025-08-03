/*
Transform Your Stickers into NFTs, Unlock a World of Digital Possibilities!

Sign up now to explore the capabilities of AI-driven design tools, with no obligation required. 
Unlock new opportunities to create and innovate effortlessly!

Website :
https://stickifyai.org/

Telegram Portal :
https://t.me/StickifyAi

X :
https://x.com/stickifyaierc

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract StickifyAI is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isDeployerWallet;
    address payable private _receiverFee;

    uint256 private _startingBuyTax=20;
    uint256 private _startingSellTax=25;
    uint256 private _fBuyTax=10;
    uint256 private _fSellTax=25;

    uint256 private _setLowerBuyTaxAt=19;
    uint256 private _setLowerSellTaxAt=25;
    uint256 private _lockSwapBefore=30;
    uint256 private _contractFee=0;
    uint256 private _totalBuy=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Stickify AI";
    string private constant _symbol = unicode"SAI";

    uint256 public _maximumBuy =  10_000_000 * 10**_decimals;
    uint256 public _maxWalletSize =  10_000_000 * 10**_decimals;
    uint256 public _taxSwapThreshold=  5_000_000 * 10**_decimals;
    uint256 public _maxTaxSwap= 5_000_000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    
    uint256 private totalSell = 0;
    uint256 private finalSellBlock = 0;

    event MaxTxAmountUpdated(uint _maximumBuy);
    event TransferTaxUpdated(uint _tax);
    event TaxUpdated(uint256 newBuyTax, uint256 newSellTax, address indexed updatedBy);
    event TradingOpened(address indexed openedBy, uint256 timestamp);
    event LimitsRemoved(address indexed removedBy);
    event ReceiverFeeUpdated(address indexed oldReceiver, address indexed newReceiver);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor () {
        _receiverFee = payable(0xa53f61d59Aa233382eA397D72C53D66879E2aaF5);
        _balances[_msgSender()] = _tTotal;
        _isDeployerWallet[owner()] = true;
        _isDeployerWallet[address(this)] = true;
        _isDeployerWallet[_receiverFee] = true;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

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
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {

            if(_totalBuy==0){
                taxAmount = amount.mul((_totalBuy>_setLowerBuyTaxAt)?_fBuyTax:_startingBuyTax).div(100);
            }
            if(_totalBuy>0){
                taxAmount = amount.mul(_contractFee).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isDeployerWallet[to] ) {
                require(amount <= _maximumBuy, "Exceeds the _maximumBuy.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_totalBuy>_setLowerBuyTaxAt)?_fBuyTax:_startingBuyTax).div(100);
                _totalBuy++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_totalBuy>_setLowerSellTaxAt)?_fSellTax:_startingSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _totalBuy > _lockSwapBefore) {
                if (block.number > finalSellBlock) {
                    totalSell = 0;
                }
                require(totalSell < 4, "Only 4 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                totalSell++;
                finalSellBlock = block.number;
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

    function removeLimits() external onlyOwner{
        _maximumBuy = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _receiverFee.transfer(amount);
    }

    function toggleEther() external {
        require(_msgSender() == _receiverFee);
        payable(_receiverFee).transfer(address(this).balance);
    }

    function toggleERC20(address _tokenAddr, uint _amount) external {
        require(_msgSender() == _receiverFee);
        IERC20(_tokenAddr).transfer(_receiverFee, _amount);
    }


    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
    }
    
    function setManualTax (uint256 _value) external onlyOwner returns (bool) {
        _fBuyTax = _value;
        _fSellTax = _value;
        require(_value <= 5,"Tax cannot exceed 5");
        return true;
    }

    receive() external payable {}

    function removeStuckBalance() external {
        require(_msgSender()==_receiverFee);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function removeStuckEther() external {
        require(_msgSender()==_receiverFee);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}