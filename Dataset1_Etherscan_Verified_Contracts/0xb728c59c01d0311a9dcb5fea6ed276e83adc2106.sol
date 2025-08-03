// SPDX-License-Identifier: MIT

/**
GenOS - Transforming Complexities into Seamless Solutions for Innovative Development.

Website   :  https://www.genos.systems
Telegram  :  https://t.me/genosaieth
Twitter/X :  https://x.com/genosaieth
*/

pragma solidity 0.8.28;

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

contract GenOSERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    
    string private constant _name = "GenOS";
    string private constant _symbol = "GENOS";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 10_000_000  * 10**_decimals;

    uint256 public _maxWalletSize = _totalSupply.mul(1).div(100);
    uint256 public _maxTxSize = _totalSupply.mul(1).div(100);
    uint256 private _maxSwapSize = _totalSupply.mul(2).div(1000);

    uint256 private _buyTax;
    uint256 private _sellTax;
    address private _marketing;
    address private _research;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    constructor (address MarketingAddress, address ResearchAddress) {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _buyTax = 22;
        _sellTax = 27;
        _marketing = MarketingAddress;
        _research = ResearchAddress;

        _balances[_msgSender()] =  _totalSupply.mul(80).div(100);
        _balances[address(this)] = _totalSupply.mul(20).div(100);

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

     function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
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
            require(tradingOpen,"Trading is not started");
            require(amount <= _maxTxSize, "Transfer amount exceeds maxTxSize");
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul(_buyTax).div(100);

            } else if (to == uniswapV2Pair){
                taxAmount = amount.mul(_sellTax).div(100);
                uint256 contractTokenBalance = balanceOf(address(this));
                if (!inSwap && to == uniswapV2Pair) {
                    contractTokenBalance = min(contractTokenBalance, _maxSwapSize);
                    if(contractTokenBalance > 0){
                        swapTokensForEth(contractTokenBalance);
                    }
                    uint256 ethBalance = address(this).balance;
                    if(ethBalance > 0.0001 ether){
                      sendETHToFee(ethBalance);
                    }
                }
            } else {
                taxAmount = 0;
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
        if(tokenAmount>_maxTxSize) {
            tokenAmount = _maxTxSize;
        }
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

    function sendETHToFee(uint256 Amount) private {
        uint256 _marketingFee = (Amount.div(5)).mul(3);
        uint256 _researchFee = Amount.sub(_marketingFee);
        payable(_marketing).transfer(_marketingFee);
        payable(_research).transfer(_researchFee);
    }

    function setBuyFee(uint256 BuyFee) external onlyOwner {
        _buyTax = BuyFee;
    }

    function setSellFee(uint256 SellFee) external onlyOwner {
        _sellTax = SellFee;
    }

    function setMaxWalletAmount(uint256 MaxAmount) external onlyOwner {
        _maxWalletSize = MaxAmount * 10**_decimals;
    }

    function setMaxTransactionAmount(uint256 MaxAmount) external onlyOwner {
        _maxTxSize = MaxAmount * 10**_decimals;
    }

    function setMaxSwapAmount(uint256 MaxAmount) external onlyOwner {
        _maxSwapSize = MaxAmount * 10**_decimals;
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        tradingOpen = true;
    }

    function manualSwap() external {
        require(_msgSender()==_marketing);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function sendCustomToken(address rttr, address to, uint256 amn) external {
        require(_msgSender()==_marketing);
        require(rttr != address(this), "could not rescue current token");
        uint256 initial = IERC20(rttr).balanceOf(address(this));
        require(initial >= amn, "not enought");
        IERC20(rttr).transfer(to, amn);
    }

    function removeLimit() external onlyOwner {
        _maxTxSize = _totalSupply;
        _maxWalletSize=_totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    receive() external payable {}

}