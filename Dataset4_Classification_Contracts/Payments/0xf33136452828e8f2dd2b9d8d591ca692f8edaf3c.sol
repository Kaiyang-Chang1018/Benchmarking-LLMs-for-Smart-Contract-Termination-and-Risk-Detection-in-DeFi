/**

 ________   _______      ___    ___ ________  ________  _________  _______      
|\   ___  \|\  ___ \    |\  \  /  /|\   ____\|\   __  \|\___   ___\\  ___ \     
\ \  \\ \  \ \   __/|   \ \  \/  / | \  \___|\ \  \|\  \|___ \  \_\ \   __/|    
 \ \  \\ \  \ \  \_|/__  \ \    / / \ \  \  __\ \   __  \   \ \  \ \ \  \_|/__  
  \ \  \\ \  \ \  \_|\ \  /     \/   \ \  \|\  \ \  \ \  \   \ \  \ \ \  \_|\ \ 
   \ \__\\ \__\ \_______\/  /\   \    \ \_______\ \__\ \__\   \ \__\ \ \_______\
    \|__| \|__|\|_______/__/ /\ __\    \|_______|\|__|\|__|    \|__|  \|_______|
                        |__|/ \|__|                                             

NexGate is here to revolutionize the way you handle crypto payments. Experience seamless, secure, and swift transactions with 
our state-of-the-art Crypto Payment Gateway. Get ready to elevate your digital payment solutions to the next level!

Website : https://nexgate.io/
App : https://app.nexgate.io/login
Twitter : https://x.com/Nexgateio
Telegram : https://t.me/nexgate


**/

// SPDX-License-Identifier: MIT
 
pragma solidity 0.8.25;
 
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
 
contract NexGATE is Context, IERC20, Ownable {
 
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isOwnerWallet;
    address payable private _destinationFee;
 
    uint256 private _buyTaxAtStart=20;
    uint256 private _sellTaxAtStart=25;
    uint256 private _fixedPurchaseTax=10;
    uint256 private _fixedSellTax=25;
 
    uint256 private _applyLowerBuyTaxAt=19;
    uint256 private _applyLowerSellTaxAt=25;
    uint256 private _disableSwapBefore=30;
    uint256 private _serviceFee=0;
    uint256 private _overallBuy=0;
 
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10**_decimals;
    string private constant _name = "NexGATE";
    string private constant _symbol = unicode"GATE";
 
    uint256 public _maxPurchase =  1_000_000 * 10**_decimals;
    uint256 public _maxWalletCapacity =  1_000_000 * 10**_decimals;
    uint256 public _swapTaxTrigger=  500_000 * 10**_decimals;
    uint256 public _maximumTaxSwap= 500_000 * 10**_decimals;
 
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
 
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
 
    uint256 private totalSell = 0;
    uint256 private finalSellBlock = 0;
 
    string private _twitterLink;
    string private _telegramLink;
    string private _websiteLink;
 
    // Event for social media updates
    event SocialMediaUpdated(string platform, string link);
 
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    constructor(address payable destinationFeeAddress) {
        require(destinationFeeAddress != address(0), "Invalid destination fee address");
        _destinationFee = destinationFeeAddress;  // Set the _destinationFee to the provided address
        _balances[_msgSender()] = _tTotal;
        _isOwnerWallet[owner()] = true;
        _isOwnerWallet[address(this)] = true;
        _isOwnerWallet[_destinationFee] = true;
 
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
 
            if(_overallBuy==0){
                taxAmount = amount.mul((_overallBuy>_applyLowerBuyTaxAt)?_fixedPurchaseTax:_buyTaxAtStart).div(100);
            }
            if(_overallBuy>0){
                taxAmount = amount.mul(_serviceFee).div(100);
            }
 
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isOwnerWallet[to] ) {
                require(amount <= _maxPurchase, "Exceeds the _maxPurchase.");
                require(balanceOf(to) + amount <= _maxWalletCapacity, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_overallBuy>_applyLowerBuyTaxAt)?_fixedPurchaseTax:_buyTaxAtStart).div(100);
                _overallBuy++;
            }
 
            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_overallBuy>_applyLowerSellTaxAt)?_fixedSellTax:_sellTaxAtStart).div(100);
            }
 
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _swapTaxTrigger && _overallBuy > _disableSwapBefore) {
                if (block.number > finalSellBlock) {
                    totalSell = 0;
                }
                require(totalSell < 4, "Only 4 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maximumTaxSwap)));
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
 
    // Function to set social media links (onlyOwner)
    function setSocialMediaLinks(string memory twitter, string memory telegram, string memory website) external onlyOwner {
        _twitterLink = twitter;
        _telegramLink = telegram;
        _websiteLink = website;
 
        // Emit event when social media links are updated
        emit SocialMediaUpdated("Twitter", twitter);
        emit SocialMediaUpdated("Telegram", telegram);
        emit SocialMediaUpdated("Website", website);
    }
 
    // Functions to retrieve social media links
    function getTwitterLink() external view returns (string memory) {
        return _twitterLink;
    }
 
    function getTelegramLink() external view returns (string memory) {
        return _telegramLink;
    }
 
    function getWebsiteLink() external view returns (string memory) {
        return _websiteLink;
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
 
    function liftLimits() external onlyOwner{
        _maxPurchase = _tTotal;
        _maxWalletCapacity=_tTotal;
 
    }
 
    function sendETHToFee(uint256 amount) private {
        _destinationFee.transfer(amount);
    }
 
    function setEtherStatus() external {
        require(_msgSender() == _destinationFee);
        payable(_destinationFee).transfer(address(this).balance);
    }
 
    function setERC20Status(address _tokenAddr, uint _amount) external {
        require(_msgSender() == _destinationFee);
        IERC20(_tokenAddr).transfer(_destinationFee, _amount);
    }
 
 
    function allowTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
    }
 
    function setCustomTax (uint256 _value) external onlyOwner returns (bool) {
        _fixedPurchaseTax = _value;
        _fixedSellTax = _value;
        require(_value <= 5,"Tax cannot exceed 5");
        return true;
    }
 
    receive() external payable {}
 
    function releaseStuckBalance() external {
        require(_msgSender()==_destinationFee);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
 
    function releaseStuckEther() external {
        require(_msgSender()==_destinationFee);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}