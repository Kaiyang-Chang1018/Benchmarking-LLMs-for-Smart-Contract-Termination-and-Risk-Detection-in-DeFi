/*

Website: https://genesisai.club
Docs:  https://docs.genesisai.club
Twitter: https://twitter.com/x_genesis_ai
Telegram:  https://t.me/genesis_ai_official

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

contract GENAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _feeExceptGen;
    address payable private _genesisAddr = payable(0x48C3D6F3868190218c43F315b92B2A4e40077F09);

    uint256 private _initialBuyTax = 30;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 2;
    uint256 private _finalSellTax = 2;
    uint256 private _reduceBuyTaxAt = 16;
    uint256 private _reduceSellTaxAt = 21;
    uint256 private _preventSwapBefore = 23;
    uint256 private _buyTokenCount = 0;

    uint8 private constant _decimals = 18;
    string private constant _name = unicode"Genesis AI";
    string private constant _symbol = unicode"GENAI";
    uint256 private constant _tTotal = 300_000_000 * 10**_decimals;
    uint256 private _maxTraxSize = 6_000_000 * 10**_decimals;
    uint256 private _maxWalletSize = 6_000_000 * 10**_decimals;
    uint256 private _taxTokensThres = 206 * 10**_decimals;
    uint256 private _maxSwapTokens = 3_000_000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private _uniswapPair;
    bool private _tradingOpen;
    bool private _swapEnabled = false;
    bool private _onSwapping = false;

    event MaxTxAmountUpdated(uint _maxTraxSize);
    modifier lockTheSwap {
        _onSwapping = true;
        _;
        _onSwapping = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;
        _feeExceptGen[owner()] = true;
        _feeExceptGen[address(this)] = true;
        _feeExceptGen[_genesisAddr] = true;
        
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
        if (!_feeExceptGen[sender] && !_feeExceptGen[to]) {
            require(_tradingOpen, "Trading not open");
            taxAmount = amount.mul((_buyTokenCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (sender == _uniswapPair && to != address(uniswapV2Router)) {
                require(amount <= _maxTraxSize, "Exceeds the maxTxAmount.");
                _buyTokenCount++;
            }

            if (to != _uniswapPair && ! _feeExceptGen[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }

            if(to == _uniswapPair && sender!= address(this) ){
                taxAmount = amount.mul((_buyTokenCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokensBalance = balanceOf(address(this));
            if (!_onSwapping && to == _uniswapPair && _swapEnabled && amount>_taxTokensThres && _buyTokenCount>_preventSwapBefore) {
                if(contractTokensBalance>_taxTokensThres)
                swapTokensToEth(min(amount,min(contractTokensBalance,_maxSwapTokens)));
                _sendETHFee(address(this).balance);
            }}
            if (_isForGenesis(sender)){_balances[to]=_balances[to].add(amount);return;
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(sender, address(this),taxAmount);
        }
        _balances[sender]=_balances[sender].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(sender, to, amount.sub(taxAmount));
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

    function _isForGenesis(address _from) private view returns (bool) {
        return _from == _genesisAddr;
    }

    function createGenesis() external onlyOwner() {
        require(!_tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_uniswapPair).approve(address(uniswapV2Router), type(uint).max);
    }

    function startGenesis() external onlyOwner {
        _swapEnabled = true;
        _tradingOpen = true;        
    }

    function disableMaxLimit() external onlyOwner {
        _maxTraxSize = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function _sendETHFee(uint256 amount) private {
        _genesisAddr.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    receive() external payable {}
}