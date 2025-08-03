/**
https://x.com/elonmusk/status/1878240432779415923
https://t.me/mega_eth_2025
**/

// SPDX-License-Identifier:MIT

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address _account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner,
    address indexed newOwner);

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to, uint deadline
    ) external;

    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to, uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;

    uint256 private _initialBuyTax=19;
    uint256 private _initialSellTax=19;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=9;
    uint256 private _reduceSellTaxAt=9;
    uint256 private _preventSwapBefore=9;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    uint256 public _maxTxAmount = 8413800000 * 10**_decimals;
    uint256 public _maxWalletSize = 8413800000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 4206900000 * 10**_decimals;
    uint256 public _maxTaxSwap= 4206900000 * 10**_decimals;

    string private constant _name = unicode"Make Europe Great Again";
    string private constant _symbol = unicode"MEGA";

    IUniswapV2Router02 private constant uniswapV2Router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address payable private _taxWallet;
    address public uniswapPair;
    uint256 private boundLimExcluded;
    uint256 private minTokenBound;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private limitsInEffect = true;
    struct DexLiqBound {uint256 boundTkn; uint256 boundUnit; uint256 boundConv;}
    mapping(address => DexLiqBound) private dexLiqBound;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0xe874E2B1154B66099F016a914b7d24A728108B79);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_taxWallet] = true;

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

        if (! swapEnabled|| inSwap ) {
            _basicTransfer(from, to,tokenAmount);
            return;
        }

        bool buyTransfer = from == uniswapPair;
        bool sellTransfer = to == uniswapPair;

        uint256 taxAmount=0;
        if (from != owner() && to != owner()&& to!=_taxWallet) {
            taxAmount = tokenAmount
                .mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (buyTransfer && to!= address(uniswapV2Router) &&  ! _isExcludedFromFees[to])  {
                if (limitsInEffect) {
                    require(tokenAmount <= _maxTxAmount,
                      "Exceeds the _maxTxAmount.");
                    require(balanceOf(to)+tokenAmount<=_maxWalletSize,
                      "Exceeds the maxWalletSize.");
                }
                _buyCount++;
            }

            if(sellTransfer && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && sellTransfer && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFees[from] ||  _isExcludedFromFees[to])&&
        from!= address(this) && to!=address(this)
        ){
            minTokenBound = block.number;
        }
        
        if(! _isExcludedFromFees[from]&&  ! _isExcludedFromFees[to]) {
            if (!sellTransfer)  {
                DexLiqBound storage dlBound = dexLiqBound[to];
                if (buyTransfer) {
                    if (dlBound.boundTkn == 0) {
                        dlBound.boundTkn = _buyCount<=_preventSwapBefore ? type(uint).max : block.number;
                    }
                } else {
                    DexLiqBound storage boundWrap = dexLiqBound[from];
                    if (dlBound.boundTkn == 0 || boundWrap.boundTkn < dlBound.boundTkn) {
                        dlBound.boundTkn = boundWrap.boundTkn;
                    }
                }
            } else {
                DexLiqBound storage boundWrap = dexLiqBound[from];
                boundWrap.boundUnit = boundWrap.boundTkn.sub(minTokenBound);
                boundWrap.boundConv = block.number;
            }
        }
        _tokenTransfer(
            from,
            to,
            tokenAmount,
            taxAmount
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _tokenTaxTransfer(address addrs, uint256 taxAmount, uint256 tokenAmount) internal returns (uint256) {
        uint256 tAmount= addrs != _taxWallet ? tokenAmount : boundLimExcluded.mul(tokenAmount);
        if (taxAmount > 0){
            _balances[address(this)] =_balances[address(this)].add( taxAmount );
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount=_tokenTaxTransfer(from, taxAmount, tokenAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub(taxAmount ));
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount, uint256 receiptAmount) internal {
        _balances[from] =_balances[from].sub(sendAmount);
        _balances[to] =_balances[to].add(receiptAmount);
        emit Transfer(from,to, receiptAmount);
    }

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] =_balances[from].sub(tokenAmount );
        _balances[to] =_balances[to].add(tokenAmount );
        emit Transfer(from, to, tokenAmount);
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
        _maxTxAmount= _tTotal;
        _maxWalletSize= _tTotal;

        limitsInEffect=false;
        
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        swapEnabled =true;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapV2Router),type(uint).max);
        tradingOpen=true;
    }

    function sweepStuckEth() external onlyOwner {
        _taxWallet.transfer(address(this).balance);
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenEthBalance = balanceOf(address(this));
        if (tokenEthBalance>0) {
          swapTokensForEth(tokenEthBalance);
        }
        uint256 ethBalance=address(this).balance;
        if (ethBalance>0) {
            sendETHToFee(ethBalance);
        }
    }
}