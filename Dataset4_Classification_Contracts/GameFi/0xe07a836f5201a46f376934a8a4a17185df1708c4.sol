// SPDX-License-Identifier: MIT
/**
Game: https://play.champz.world
TG: https://t.me/champzERC
X: https://x.com/ChampzErc
Website: https://champz.world

Champignons of Arborethia is a well designed, free-to-play browser game, that is based around mushrooms who are tasked with defending their Homeland from evil forces. 
The game provides players multiple ways to earn in game, including Ethereum rewards from daily quests for those who hold the $CHAMPZ token.
**/

pragma solidity 0.8.26;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface InterfaceLP {
    function sync() external;
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

contract Champz is Ownable, ERC20 {
    using SafeMath for uint256;

    address public WETH;

    string constant _name = "Champz";
    string constant _symbol = "CHAMPZ";
    uint8  constant _decimals = 8; 
    uint256 constant _totalSupply =  1_000_000_000 * (10 ** _decimals);


    event TaxChanged(uint256 buyTaxBP, uint256 sellTaxBP);
    event WhitelistUser(address wallet, bool isWhitelisted);
    event StuckEthCleared(uint256 amount);
    event StuckTokenCleared(address tokenAddress, uint256 amount, address destination);
    event MarketingWalletChanged(address newWallet, address previousWallet);
    event SwapbackChanged(uint256 amount, bool enabled);
    event TradingOpen(bool open);


    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;  
    mapping (address => bool) isWhitelisted;


    uint256 public sellTax = 500;  // in basis points (100 = 1%). Initially set to 5%
    uint256 public buyTax = 500;   // in basis points (100 = 1%). Initially set to 5%
    uint256 public constant TAX_DENOMINATOR = 10000;
    uint256 public constant MAX_TAX = 1000; // in basis points (100 = 1%). Set to 10%

    address public marketingWallet;

    IDEXRouter public router;
    address public pair;
    
    bool public isTradingOpen = false; 
    bool public swapEnabled = false;

    uint256 public swapThreshold = _totalSupply.div(5000);

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    constructor (address _marketingWallet) {
        marketingWallet = _marketingWallet;

        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        ERC20(pair).approve(address(router), type(uint).max);

        _allowances[address(this)][address(router)] = type(uint256).max;

        isWhitelisted[msg.sender] = true;
        isWhitelisted[marketingWallet] = true;
        isWhitelisted[address(this)] = true;
        
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) {return owner();}
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if ( inSwap ) {
          return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack())  {
          swapBack(); 
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = 
          (isWhitelisted[sender] || isWhitelisted[recipient]) ? amount : takeFee(sender, amount, recipient);

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isWhitelisted[sender];
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        uint256 bp = 0;

        if(recipient == pair) {
            bp = sellTax;
        } else if(sender == pair) {
            bp = buyTax;
        }

        uint256 feeAmount = amount.mul(bp).div(TAX_DENOMINATOR);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
          && !inSwap
          && swapEnabled
          && _balances[address(this)] >= swapThreshold;
    }
  
    function clearStuckEth() external { 
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH to transfer");

        payable(marketingWallet).transfer(amount);
        emit StuckEthCleared(amount);
    }

    function clearStuckToken(address tokenAddress, address destination) external onlyOwner {
        uint256 amount = ERC20(tokenAddress).balanceOf(address(this));
        require(amount > 0, "No tokens to transfer");

        ERC20(tokenAddress).transfer(destination, amount);
        emit StuckTokenCleared(tokenAddress, amount, destination);
    }

    function setTax(uint256 buyTaxBP, uint256 sellTaxBP) external onlyOwner {
      require(buyTaxBP <= TAX_DENOMINATOR && sellTaxBP <= TAX_DENOMINATOR, "Tax is too high");
      require(buyTaxBP <= MAX_TAX && sellTaxBP <= MAX_TAX, "Exceeds max tax");

      buyTax = buyTaxBP;
      sellTax = sellTaxBP;

      emit TaxChanged(buyTaxBP, sellTaxBP);
    }
       
    function openTrading() external onlyOwner() {
        require(!isTradingOpen, "Trading is already open");

        router.addLiquidityETH{value: address(this).balance}(
          address(this),
          balanceOf(address(this)),
          0,
          0,
          owner(),
          block.timestamp
        );

        swapEnabled = true;
        isTradingOpen = true;

        emit TradingOpen(true);
    }

    function swapBackManual() external onlyOwner {
        require(balanceOf(address(this)) >= swapThreshold, "Insufficient tokens in contract");
        swapBack();
    }
            
    function swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHMarketing = address(this).balance.sub(balanceBefore);

        (bool tmpSuccess,) = payable(marketingWallet).call{value: amountETHMarketing}("");
        require(tmpSuccess, "Marketing fee transfer failed");
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
      marketingWallet = _marketingWallet;
      address oldMarketingWallet = _marketingWallet;

      emit MarketingWalletChanged(marketingWallet, oldMarketingWallet);
    }

    function setSwapBackSettings(bool _enabled, uint256 _threshold) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _threshold;

        emit SwapbackChanged(_threshold, _enabled);
    }

    function whitelistUser(address _wallet, bool _isWhitelist) external onlyOwner {
        isWhitelisted[_wallet] = _isWhitelist;
        emit WhitelistUser(_wallet, _isWhitelist);
    }

    function airdrop(address[] calldata recipients, uint256[] calldata values) external onlyOwner {
        require(recipients.length == values.length, "recipients and values array length must match");

        for (uint i = 0; i < recipients.length; i++) {
            _basicTransfer(msg.sender, recipients[i], values[i]);
        }
    }
}