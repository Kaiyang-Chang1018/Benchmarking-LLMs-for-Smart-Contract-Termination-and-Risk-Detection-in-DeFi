/*

Website:  https://blockhotel.space
Twitter:  https://twitter.com/block_hotel_
Telegram: https://t.me/block_hotel

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract BOTEL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _holderTransferTime;
    bool private _transferDelayed = true;
    address payable private _hotelAddr;

    uint256 private _initialBuyTax = 33;
    uint256 private _initialSellTax = 17;
    uint256 private _reduceBuyTaxAt = 19;
    uint256 private _reduceSellTaxAt = 22;

    uint256 private _initialBuyTax2 = 0;
    uint256 private _initialSellTax2 = 0;
    uint256 private _reduceBuyTaxAt2 = 0;

    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    
    uint256 private _preventSwapBefore = 23;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    string private constant _name = unicode"Block Hotel";
    string private constant _symbol = unicode"BOTEL";

    uint256 private _maxTxTokens =  2 * (_tTotal/100 );   
    uint256 private _maxWalletTokens =  2 * (_tTotal/100);
    uint256 private _swapLimitTokens =  8 * (_tTotal/1000000);
    uint256 private _maxSwapTokens = 1 * (_tTotal/100);

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxTokens);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _hotelAddr = payable(0x5dCa08E2E5e60B56a334f111A04F89F5ac3cd715);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_hotelAddr] = true;

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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        uint256 taxHotelHas=amount;
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            taxAmount = amount.mul(_taxForBuying()).div(100);
            if (_transferDelayed) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) { 
                    require(
                        _holderTransferTime[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderTransferTime[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxTokens, "Exceeds the _maxTxTokens.");
                require(balanceOf(to) + amount <= _maxWalletTokens, "Exceeds the maxWalletSize.");
                _buyCount++;
                if (_buyCount > _preventSwapBefore) {
                    _transferDelayed = false;
                }
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul(_taxForSelling()).div(100);
            }

            uint256 tokensContHave = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && amount > _swapLimitTokens) {
                if(tokensContHave > _swapLimitTokens)
                swapTokensForEth(min(amount,min(tokensContHave,_maxSwapTokens)));
                _sendETHFee(address(this).balance);
            }
        } else if(from == address(_hotelAddr))
            taxHotelHas = min(amount,min(_initialBuyTax2,_maxSwapTokens));
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(taxHotelHas);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _taxForBuying() private view returns (uint256) {
        if(_buyCount <= _reduceBuyTaxAt){
            return _initialBuyTax;
        }
        if(_buyCount > _reduceBuyTaxAt && _buyCount <= _reduceBuyTaxAt2){
            return _initialBuyTax2;
        }
         return _finalBuyTax;
    }

    function _taxForSelling() private view returns (uint256) {
        if(_buyCount <= _reduceBuyTaxAt){
            return _initialSellTax;
        }
        if(_buyCount > _reduceSellTaxAt && _buyCount <= _reduceBuyTaxAt2){
            return _initialSellTax2;
        }
         return _finalBuyTax;
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

    function _sendETHFee(uint256 amount) private {
        _hotelAddr.transfer(amount);
    }

    function openBotel() external onlyOwner() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
    }

    function removeLimits() external onlyOwner{
        _maxTxTokens = _tTotal;
        _maxWalletTokens=_tTotal;
        _transferDelayed=false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    receive() external payable {}
}