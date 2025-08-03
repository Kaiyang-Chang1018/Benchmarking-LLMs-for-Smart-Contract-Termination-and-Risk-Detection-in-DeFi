// SPDX-License-Identifier: MIT

/**
	LIMONCELLO AI - $LIMON

	An autonomous crypto trading bot powered by AI agents

	https://t.me/limoncelloAI

	https://www.limoncelloai.xyz
                                                               
                                                                 
                          .......                                
                         :-:.....:::                             
                       :-:          ::                           
                   .---:  .::.  ----..:::.                       
                 .:---- .:----:..:---::  .:.                     
                 ------ .------: :-----:.  .-                    
              .:-------  .-----:..:-------   -:                  
              :--------   -------  -------  :.::                 
            .----------    .:----.  :---:: .--. -:               
           .:---------- .--:....--: :---. :---:. :-              
           :----------- .----:   :::..--. :-----:..-.            
          -------------..:-----:  .:..- .--------:.:..           
          --------------. --------:.... .---------: :-           
         .--------------.  :-------::.    ::::::---:..-.         
        :----------------- .:--:.......   ..........  =.         
        :-----------------:  .....:----  . .:---:.::  .::        
        :------------------.  .:------- .--: .:------: --        
       .:-------------------- .:------- .----. .-----: --        
       ----------------------:  ------- .-----:. :---: --        
       -----------------------.  .:-----. :----:: .:-:  .=.      
       .:-----------------------.  .:---. :------: .-:   =.      
         .-----------------------::  .--. :-------:  : ::.       
           .:-----------------------.     ::-------:   --        
             .------------------------:     .----:.   ::.        
                 :------------------------          :--.         
                   :::-----------------------....-=:::           
                      ....--------------------:....              
                              :---------:                        
                                                                 
                                                                 
**/

pragma solidity >=0.8.20 <=0.8.23;

// Context contract for accessing msg.sender details
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Standard ERC20 interface
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

// SafeMath library to prevent overflows and underflows
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow detected");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow detected");
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
        require(c / a == b, "SafeMath: multiplication overflow detected");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero detected");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

// Ownership contract for managing admin rights
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

// Uniswap interfaces for liquidity management
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

// Main contract for LimoncelloAI token
contract LimoncelloAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _taxWallet;
    uint256 firstBlock;

    uint256 private _buyTaxInitial=20;
    uint256 private _sellTaxInitial=40;
    uint256 private _buyTaxFinal=4;
    uint256 private _sellTaxFinal=4;
    uint256 private _buyTaxFinalAt=20;
    uint256 private _sellTaxFinalAt=20;
    uint256 private _taxSwapStartAt=30;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10000000 * 10**_decimals;
    string private constant _name = unicode"LimoncelloAI";
    string private constant _symbol = unicode"LIMON";
    uint256 public _maxTransaction =   200000 * 10**_decimals;
    uint256 public _maxWallet = 200000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 50000 * 10**_decimals;
    uint256 public _maxTaxSwap= 200000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTransaction);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    // Basic ERC20 functions
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

    // Transfer functions
    function transfer(address recipient, uint256 value) public override returns (bool) {
        _transfer(_msgSender(), recipient, value);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 value) public override returns (bool) {
        _transfer(sender, recipient, value);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(value, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // Approve function to authorize spending
    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // Core transfer logic with fee deductions
    function _transfer(address from, address to, uint256 value) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "Transfer value must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            taxAmount = value.mul((_buyCount>_buyTaxFinalAt)?_buyTaxFinal:_buyTaxInitial).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(value <= _maxTransaction, "Exceeds the _maxTransaction.");
                require(balanceOf(to) + value <= _maxWallet, "Exceeds the maxWalletSize.");

                if (firstBlock + 3  > block.number) {
                    require(!isContract(to));
                }
                _buyCount++;
            }

            if (to != uniswapV2Pair && ! _isExcludedFromFee[to]) {
                require(balanceOf(to) + value <= _maxWallet, "Exceeds the maxWalletSize.");
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = value.mul((_buyCount>_sellTaxFinalAt)?_sellTaxFinal:_sellTaxInitial).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_taxSwapStartAt) {
                swapTokensForEth(min(value,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(value);
        _balances[to]=_balances[to].add(value.sub(taxAmount));
        emit Transfer(from, to, value.sub(taxAmount));
    }

    // Function to return the minimum of two values
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    // Function to check if address is contract
    function isContract(address account) private view returns (bool) {
        return account.code.length > 0;
    }

    // Swap tokens for ETH
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

    // Transfer collected ETH to the tax wallet
    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    // Remove transaction limits
    function removeLimits() external onlyOwner{
        _maxTransaction = _tTotal;
        _maxWallet=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    // Enable trading on Uniswap
    function openTrading() external onlyOwner() {
        require(!tradingOpen, "Not authorized action, trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
    }

    receive() external payable {}

    // Manual swap function for the owner
    function manualSwap() external {
        require(_msgSender() == _taxWallet, "Not authorized action");
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}