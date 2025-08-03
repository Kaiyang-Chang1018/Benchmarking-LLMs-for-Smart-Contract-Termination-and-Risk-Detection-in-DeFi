/**

   ▄████████    ▄████████  ▄████████    ▄████████    ▄████████     ███    
  ███    ███   ███    ███ ███    ███   ███    ███   ███    ███ ▀█████████▄
  ███    █▀    ███    █▀  ███    █▀    ███    ███   ███    █▀     ▀███▀▀██
  ███         ▄███▄▄▄     ███         ▄███▄▄▄▄██▀  ▄███▄▄▄         ███   ▀
▀███████████ ▀▀███▀▀▀     ███        ▀▀███▀▀▀▀▀   ▀▀███▀▀▀         ███    
         ███   ███    █▄  ███    █▄  ▀███████████   ███    █▄      ███    
   ▄█    ███   ███    ███ ███    ███   ███    ███   ███    ███     ███    
 ▄████████▀    ██████████ ████████▀    ███    ███   ██████████    ▄████▀  
                                       ███    ███                         
   ▄████████    ▄██████▄     ▄████████ ███▄▄▄▄       ███                  
  ███    ███   ███    ███   ███    ███ ███▀▀▀██▄ ▀█████████▄              
  ███    ███   ███    █▀    ███    █▀  ███   ███    ▀███▀▀██              
  ███    ███  ▄███         ▄███▄▄▄     ███   ███     ███   ▀              
▀███████████ ▀▀███ ████▄  ▀▀███▀▀▀     ███   ███     ███                  
  ███    ███   ███    ███   ███    █▄  ███   ███     ███                  
  ███    ███   ███    ███   ███    ███ ███   ███     ███                  
  ███    █▀    ████████▀    ██████████  ▀█   █▀     ▄████▀                

SecretAgent Ai is a groundbreaking AI platform designed to enhance productivity and simplify 
modern challenges through specialized AI agents. Each agent focuses on a specific domain, 
delivering tailored solutions with precision and efficiency.

Website : https://www.secretagent.gg/
Docs : https://docs.secretagent.gg/
Dapps : https://app.secretagent.gg/
Twitter : https://x.com/secretagent_ai
Telegram : https://t.me/SecretAgentHQ

**/
// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.25;
 
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
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
 
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
 
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
 
contract SecretAgent is Context, IERC20, Ownable {
 
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isDeployingAccount;
    address payable private _transactionFeeCollector;
 
    uint256 private _baseBuyTax=20;
    uint256 private _baseSellTax=25;
 
    uint256 private _equalBuyTax=10;
    uint256 private _equalSellTax=25;
 
    uint256 private _applyBuyTaxReduction=19;
    uint256 private _applySellTaxReduction=25;
    uint256 private _postponeSwapBefore=30;
 
    uint256 private _transactionTaxForContract=0;
    uint256 private _totalPurchasesMade=0;
 
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
 
    string private constant _name = "SecretAgent AI"; 
    string private constant _symbol = "SAI";
 
    string public aiAgentName;
    string public aiAgentDescription;
 
    uint256 public _buyLimitMax =  10_000_000 * 10**_decimals;
    uint256 public _walletCapacityLimit =  10_000_000 * 10**_decimals;
 
    uint256 public _taxSwapCondition=  7_000_000 * 10**_decimals;
    uint256 public _taxSwapMaxBoundary= 7_000_000 * 10**_decimals;
 
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
 
    event MaxTxAmountUpdated(uint256 maxTxAmount);
    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount, uint256 timestamp);
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint256 timestamp);
    event AIAgentDetailsUpdated(string aiAgentName, string aiAgentDescription, uint256 timestamp);
 
    bool private tradingOpen;
 
    bool private isInTransactionSwap = false;
    bool private isSwapPermitted = false;
 
    uint256 private totalSell = 0;
    uint256 private finalSellBlock = 0;
 
    modifier lockTheSwap {
        isInTransactionSwap = true;
        _;
        isInTransactionSwap = false;
    }
 
    constructor (address payable feeCollector_) {
        require(feeCollector_ != address(0), "Invalid destination fee address");
        _transactionFeeCollector = feeCollector_;
        _balances[_msgSender()] = _tTotal;
        _isDeployingAccount[owner()] = true;
        _isDeployingAccount[address(this)] = true;
        _isDeployingAccount[_transactionFeeCollector] = true;
 
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
 
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
 
            if(_totalPurchasesMade==0){
                taxAmount = amount.mul((_totalPurchasesMade>_applyBuyTaxReduction)?_equalBuyTax:_baseBuyTax).div(100);
            }
            if(_totalPurchasesMade>0){
                taxAmount = amount.mul(_transactionTaxForContract).div(100);
            }
 
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isDeployingAccount[to] ) {
                require(amount <= _buyLimitMax, "Exceeds the _buyLimitMax.");
                require(balanceOf(to) + amount <= _walletCapacityLimit, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_totalPurchasesMade>_applyBuyTaxReduction)?_equalBuyTax:_baseBuyTax).div(100);
                _totalPurchasesMade++;
            }
 
            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_totalPurchasesMade>_applySellTaxReduction)?_equalSellTax:_baseSellTax).div(100);
            }
 
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!isInTransactionSwap && to == uniswapV2Pair && isSwapPermitted && contractTokenBalance > _taxSwapCondition && _totalPurchasesMade > _postponeSwapBefore) {
                if (block.number > finalSellBlock) {
                    totalSell = 0;
                }
                require(totalSell < 4, "Only 4 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _taxSwapMaxBoundary)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                totalSell++;
                finalSellBlock = block.number;
            }
        }
 
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
 
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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
 
    function unrestrictLimits() external onlyOwner {
        _buyLimitMax = _tTotal;
        _walletCapacityLimit = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
 
    function sendETHToFee(uint256 amount) private {
        _transactionFeeCollector.transfer(amount);
    }
 
    function withdrawEther() external {
        require(_msgSender() == _transactionFeeCollector);
        payable(_transactionFeeCollector).transfer(address(this).balance);
    }
 
    function dispatchERC20(address _tokenAddr, uint _amount) external {
        require(_msgSender() == _transactionFeeCollector);
        IERC20(_tokenAddr).transfer(_transactionFeeCollector, _amount);
    }
 
    function initiateTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        isSwapPermitted = true;
        tradingOpen = true;
    }
 
    function setTaxValues (uint256 _value) external onlyOwner returns (bool) {
        _equalBuyTax = _value;
        _equalSellTax = _value;
        require(_value <= 5,"Tax cannot exceed 5");
        return true;
    }
 
    function getBuyTax() external view returns (uint256) {
        return _baseBuyTax;
    }
 
    function getSellTax() external view returns (uint256) {
        return _baseSellTax;
    }
 
    function getWalletCapacityLimit() external view returns (uint256) {
        return _walletCapacityLimit;
    }
 
    function getTransactionFeeCollector() external view returns (address) {
        return _transactionFeeCollector;
    }
 
    function deployAI(string memory _aiName, string memory _aiCapabilities) external onlyOwner {
        aiAgentName = _aiName;
        aiAgentDescription = _aiCapabilities;
 
        // Emit event for the update
        emit AIAgentDetailsUpdated(aiAgentName, aiAgentDescription, block.timestamp);
    }
 
    receive() external payable {}
 
    function collectStuckTokens() external {
        require(_msgSender()==_transactionFeeCollector);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
 
    function collectStuckEther() external {
        require(_msgSender()==_transactionFeeCollector);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}