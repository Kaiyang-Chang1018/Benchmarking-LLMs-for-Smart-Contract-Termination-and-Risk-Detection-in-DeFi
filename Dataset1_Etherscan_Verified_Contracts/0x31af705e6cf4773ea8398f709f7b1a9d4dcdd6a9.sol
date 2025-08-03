/*

Kickoff AI FC - The Ultimate Fantasy Prediction League

Web: https://kickoff.meme
TG: https://t.me/kickoff_meme
X: https://x.com/kickoff_meme
Stream: https://kickoff.meme/stream
Docs: https://kickoff.meme/docs

Kickoff AI FC is the world’s first hybrid fantasy sports prediction market, combining the power of AI-driven teams with player-controlled gameplay.
Buy and trade shares of AI-driven teams and watch your stake grow as they rise through the league.
Build and play as your own custom team or compete head-to-head in player-vs-player matches for total control.
Every win, goal, and ranking shift affects your value — every move is a chance to profit.
With deflationary tokenomics and the ability to create your own team tokens, you hold the keys to strategy, control, and profit.

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

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
    function add(uint256 a, uint256 b) internal pure returns (uint256) { uint256 c = a + b; require(c >= a, "SafeMath: addition overflow"); return c; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return sub(a, b, "SafeMath: subtraction overflow"); }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { require(b <= a, errorMessage); uint256 c = a - b; return c; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { if (a == 0) { return 0; } uint256 c = a * b; require(c / a == b, "SafeMath: multiplication overflow"); return c; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return div(a, b, "SafeMath: division by zero"); }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { require(b > 0, errorMessage); uint256 c = a / b; return c; }
}

contract Ownable is Context {
    address private _owner; 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () { address msgSender = _msgSender(); _owner = msgSender; emit OwnershipTransferred(address(0), msgSender); }
    function owner() public view returns (address) { return _owner; }
    modifier onlyOwner() { require(_owner == _msgSender(), "Ownable: caller is not the owner"); _; }
    function renounceOwnership() public virtual onlyOwner { emit OwnershipTransferred(_owner, address(0)); _owner = address(0); }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract KICKOFF is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Kickoff AI FC";
    string private constant _symbol = "KICKOFF";

    uint256 private constant _totalSupply = 100_000_000 ether;
    uint8 private constant _decimals = 18;
    
    uint256 public _txMaxAmount = 1_000_000 ether;
    uint256 public _txWalletMax = 1_000_000 ether;
    uint256 public _feeSwapThreshold = 1_000_000 ether;
    uint256 public _feeMaxSwap = 1_000_000 ether;

    uint256 private _initFeeBuy = 40;
    uint256 private _initFeeSell = 40;
    uint256 private _reduceFeeAt = 40;
    uint256 private _feeBuy = 5;
    uint256 private _feeSell = 5;

    uint256 private _preventSwapBefore = 40;
    uint256 private _buyCount = 0;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    address payable private _marketingWallet;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => bool) public _automatedMarketMakerPairs;

    bool public _transferDelayEnabled = true;
    bool public _tradingEnabled = false;
    bool public _swapEnabled = false;
    bool public _hasLaunched = false;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint _txMaxAmount);
    event DEXPaired(uint256 tokenAmount, uint256 ethAmount, uint256 timestamp);
    event TradingActivated(bool _tradingEnabled);
    event FeeExemptionUpdated(address indexed account, bool isExempt);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _marketingWallet = payable(_msgSender());
        _balances[address(this)] = _totalSupply * 75 / 100;
        _balances[_msgSender()] = _totalSupply - _balances[address(this)];
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingWallet] = true;

        emit Transfer(address(0), address(this), _balances[address(this)]);
        emit Transfer(address(0), _msgSender(), _balances[_msgSender()]);
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
        require(from != address(0), "ERC20: from zero");
        require(to != address(0), "ERC20: to zero");
        require(amount > 0, "Transfer > 0");
        uint256 taxAmount=0;

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

        if (_transferDelayEnabled) {
            if (!_automatedMarketMakerPairs[to] && to != address(uniswapV2Router)) {
                require(_holderLastTransferTimestamp[msg.sender] < block.number, "One purchase per block");
                _holderLastTransferTimestamp[msg.sender] = block.number;
            }
        }

            if (_automatedMarketMakerPairs[from] && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(amount <= _txMaxAmount, "Exceeds max transaction amount");
                require(balanceOf(to) + amount <= _txWalletMax, "Exceeds max wallet amount");
                _buyCount++;
              
            }

            bool useInitialTaxes = _buyCount < _reduceFeeAt;
            
            if (_automatedMarketMakerPairs[to] && from != address(this)) {
                taxAmount = amount.mul(useInitialTaxes ? _initFeeSell : _feeSell).div(100);
            } 
            else if (_automatedMarketMakerPairs[from] && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                taxAmount = amount.mul(useInitialTaxes ? _initFeeBuy : _feeBuy).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && _automatedMarketMakerPairs[to] && _swapEnabled && contractTokenBalance > _feeSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _feeMaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0.05 ether) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
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
        _txMaxAmount=_totalSupply;
        _txWalletMax=_totalSupply;
        _transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _marketingWallet.transfer(amount);
    }

    function addLiquidityDEX() external onlyOwner {
        require(!_hasLaunched, "Launch already called");
        require(
            address(this).balance > 0 && _balances[address(this)] > 0,
            "Both ETH and Tokens are required for the contract"
        );
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _balances[address(this)]);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 tokenAmountToAdd = _balances[address(this)];
        uint256 ethAmountToAdd = address(this).balance;
        uniswapV2Router.addLiquidityETH{value: ethAmountToAdd}(address(this),tokenAmountToAdd,0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        emit DEXPaired(tokenAmountToAdd, ethAmountToAdd, block.timestamp);
    }

    function enableTrading() external onlyOwner() {
        require(!_tradingEnabled,"Trading is already open");
        _swapEnabled = true;
        _tradingEnabled = true;
        emit TradingActivated(_tradingEnabled);
    }

    function changeFee(uint256 _newBuyFee, uint256 _newSellFee) external onlyOwner {
        require(_newBuyFee <= 5, "Buy fee cannot be higher than 5%");
        require(_newSellFee <= 5, "Sell fee cannot be higher than 5%");
        _feeBuy = _newBuyFee;
        _feeSell = _newSellFee;
    }

    function manualSwap() external {
        require(_msgSender()==_marketingWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function manualTransfer() external onlyOwner{
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function unstuckETH() external {
        require(_msgSender() == _marketingWallet);
        require(address(this).balance > 0, "No ETH to unstuck");
        payable(msg.sender).transfer(address(this).balance);
    }

    function setFeeExemption(address account, bool value) public onlyOwner {
        _isExcludedFromFee[account] = value;
        emit FeeExemptionUpdated(account, value);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(
            pair != uniswapV2Pair || value == true,
            "The uniswap pair cannot be removed"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        _automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateSwapSettings(uint256 newTaxSwapThreshold, uint256 newMaxTaxSwap) external onlyOwner {
        require(newTaxSwapThreshold > 0, "Tax swap threshold must be greater than 0");
        require(newMaxTaxSwap > 0, "Max tax swap must be greater than 0");
        _feeSwapThreshold = newTaxSwapThreshold * 1 ether;
        _feeMaxSwap = newMaxTaxSwap * 1 ether;
    }

    receive() external payable {}
}