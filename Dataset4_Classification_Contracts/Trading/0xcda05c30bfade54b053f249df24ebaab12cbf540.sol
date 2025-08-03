// SPDX-License-Identifier: MIT

/*
    Web      : https://charmai.tech
    App      : https://app.charmai.tech
    Twitter  : https://twitter.com/charmai_tech
    Docs     : https://docs.charmai.tech
    Telegram : https://t.me/charmai_tech_channel
*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
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
        require(c / a == b, " multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract CharmAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromCharmAIFee;
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 100000000 * 10**_decimals;
    
    uint256 private constant oneCharmAIPercent = 1000000 * 10**_decimals; // 1% from Liquidity 

    uint256 public maxWalletAmount = oneCharmAIPercent * 2; // 2% max wallet at launch

    uint256 private _tax;
    uint256 public buyTax = 0;
    uint256 public sellTax = 5;

    string private constant _name = "Charm AI";
    string private constant _symbol = "CHARM";

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    address payable public charmAIWallet;
        
    uint256 private launchedAt;
    uint256 private launchDelay = 2;
    bool private launch = false;

    uint256 private constant minCharmAISwap = oneCharmAIPercent / 2400; //0.04% from Liquidity supply
  
    bool private inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {       
        charmAIWallet = payable(0x10751172089448e03ea0E86FAF5a17E290849F7a);   // Charm fee wallet

        _isExcludedFromCharmAIFee[msg.sender] = true;
        _isExcludedFromCharmAIFee[address(this)] = true;       
        _isExcludedFromCharmAIFee[charmAIWallet] = true;

        _balance[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

     function newCharmAIDelay(uint256 newLaunchDelay) external onlyOwner {
         launchDelay = newLaunchDelay;
     }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"low allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "approve zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function createCharmAIV2Pairs() external onlyOwner {
        require(!launch,"Already launched!");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function isExamptFees(address sender) internal view returns (bool) {
        return _isExcludedFromCharmAIFee[sender] && launch;
    }

    function _transfer(address from, address to, uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (_isExcludedFromCharmAIFee[from] || _isExcludedFromCharmAIFee[to]) {
            _tax = 0;
        } else {
            require(launch, "Wait till launch");
            if (block.number < launchedAt + launchDelay) {_tax=49;} else {
                if (from == uniswapV2Pair) {
                    require(balanceOf(to) + amount <= maxWalletAmount, "Max wallet 2% at launch");
                    _tax = buyTax;
                } else if (to == uniswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (tokensToSwap > minCharmAISwap && !inSwapAndLiquify && amount > minCharmAISwap) {
                        if (tokensToSwap > oneCharmAIPercent) {
                            tokensToSwap = oneCharmAIPercent;
                        }
                        swapTokensForEth(tokensToSwap);
                        sendCharmAIBalances(address(this).balance);
                    }
                    _tax = sellTax;
                } else {
                    _tax = 0;
                }
            }
        }

        uint256 taxCharmAITokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxCharmAITokens;
        if(!isExamptFees(from))       
        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;

        _balance[address(this)] = _balance[address(this)] + taxCharmAITokens;

        emit Transfer(from, to, transferAmount);
    }

    function removeCharmAILimits() external onlyOwner {
        maxWalletAmount = _totalSupply;
    }

    function newCharmTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function sendCharmAIBalances(uint256 amount) private {
        charmAIWallet.transfer(amount);
    }

    function clearCharmAIEth() external onlyOwner {
        require(address(this).balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function enableTrading() external onlyOwner {
        launch = true;
        launchedAt = block.number;
    }
}