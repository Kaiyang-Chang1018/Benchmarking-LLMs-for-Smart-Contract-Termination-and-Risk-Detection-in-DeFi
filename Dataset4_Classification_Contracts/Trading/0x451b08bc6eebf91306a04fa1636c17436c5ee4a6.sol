// SPDX-License-Identifier: MIT


// Twitter : https://twitter.com/BirbXerc
// Telegram : https://t.me/BirbXErc

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ERC20 {
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

contract BirbXToken is Context, ERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isFeeExmpt;
    address payable public marketingWallet;

    uint256 private intlBuyTax=0;
    uint256 private intlSellTax=0;
    uint256 private finalBuyTx=0;
    uint256 private finalSellTx=0;
    uint256 private _reduceBuyFeeAt=5;
    uint256 private _reduceSellFeeAt=5;
    uint256 private _preventSwapBefore=8;
    uint256 private _buyCount=0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 666_000_000_000 * 10**decimals;
    string public constant name = "BirbX";
    string public constant symbol = "BIRBX";
    uint256 public _maxWallet = totalSupply / 50;
    uint256 public _taxSwapThreshold = totalSupply / 100;
    uint256 public _maxTaxSwap = totalSupply / 50;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool public tradingOpen;
    bool public zerotax;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        marketingWallet = payable(0x924e2119028B94138fFf68b66F7D9b55De5C1fF3);
        _balances[_msgSender()] = totalSupply;
        isFeeExmpt[owner()] = true;
        isFeeExmpt[address(this)] = true;
        isFeeExmpt[marketingWallet] = true;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        emit Transfer(address(0), _msgSender(), totalSupply);
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
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if ((from != owner() && to != owner()) || zerotax)  {
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! isFeeExmpt[to] ) {
                require(balanceOf(to) + amount <= _maxWallet, "Exceeds the Max wallet holding amount");
                _buyCount++;
            }

            taxAmount = amount.mul((_buyCount>_reduceBuyFeeAt)?finalBuyTx:intlBuyTax).div(100);
            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellFeeAt)?finalSellTx:intlSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(!tradingOpen){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketingWallet,
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner{
        _maxWallet = totalSupply;
        _buyCount = 100;
        finalSellTx = 0;
        finalBuyTx = 0;
        zerotax = true;
    }

    function sendETHToFee(uint256 amount) private {
        marketingWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uint256 tokensforLP = 99 * balanceOf(address(this)) / 100;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),tokensforLP,0,0,owner(),block.timestamp);
        ERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        intlBuyTax = 10;
        intlSellTax = 10;
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwapTokens() external {
        require(_msgSender()==marketingWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
    
    function reduceFee(uint256 _newFee) external{
      require(_buyCount>1);
      require(_newFee<=finalSellTx && _newFee<=finalBuyTx);
      finalSellTx=_newFee;
      finalBuyTx=_newFee;
    }
}