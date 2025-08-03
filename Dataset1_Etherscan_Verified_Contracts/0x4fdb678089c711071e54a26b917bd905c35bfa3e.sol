/*

SuperAndy | $SUA

"Can’t Get Enough of Andy? SuperAndy is Your Next Big Thing!" 

SuperAndy emerged from the dank, meme-filled corners of the internet, 
where Andy from “Boys Club” once reigned supreme. 
Inspired by the absurdly successful OG Andy and Super Trump crypto projects (because who doesn’t love a good meme cash grab?), 
SuperAndy is here to bring back that nostalgic chaos with a super-powered punch. 

Think of it as Andy on steroids—flying through the blockchain and zapping boring tokens with laser eyes. 
Missed OG Andy? Don’t worry, SuperAndy is back to turn your FOMO into YOLO!

Socials :
Web : https://superandy.wtf
TG : https://t.me/SuperAndy_Official
X : https://x.com/superandy__

*/

pragma solidity 0.8.22;
// SPDX-License-Identifier: MIT
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

contract SuperAndy is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _taxExclusionStatus;
    mapping(address => uint256) private _transferTime;
    bool public transferDelayOn = true;
    address payable private _walletCreator;
    uint256 private _startingBuyTax=25;
    uint256 private _sellTaxRate=25;
    uint256 private _finalTransactionBuyTax=0;
    uint256 private _lastSellTax=0;
    uint256 private _buyTaxAdjustmentBlock=18;
    uint256 private _sellTaxReductionBlock=18;
    uint256 private _swapBlockPrevention=20;
    uint256 private _numberOfBuys=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _overallSupply = 420690000000 * 10**_decimals;
    string private constant _tokenIdentifier = unicode"SuperAndy";
    string private constant _currencySymbol = unicode"SUA";
    uint256 public _maxTxAmount = 4206900000 * 10**_decimals;
    uint256 public _maxWalletSize = 4206900000 * 10**_decimals;
    uint256 public _taxSwapPoint= 4206900000 * 10**_decimals;
    uint256 public _maxTaxableSwap= 4206900000 * 10**_decimals;
    bool public finalFeeCheck = false;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private swapInProgress = false;
    bool private isSwappingEnabled = false;

    event maxTxAmountUpdated(uint _maxTxAmount);
    modifier lockSwapping {
        swapInProgress = true;
        _;
        swapInProgress = false;
    }

    constructor () {
        _walletCreator = payable(_msgSender());
        _balances[_msgSender()] = _overallSupply;
        _taxExclusionStatus[owner()] = true;
        _taxExclusionStatus[address(this)] = true;
        _taxExclusionStatus[_walletCreator] = true;

        emit Transfer(address(0), _msgSender(), _overallSupply);
    }

    function name() public pure returns (string memory) {
        return _tokenIdentifier;
    }

    function symbol() public pure returns (string memory) {
        return _currencySymbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _overallSupply;
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
            taxAmount = amount.mul((finalFeeCheck)?_finalTransactionBuyTax:_startingBuyTax).div(100);

            if (transferDelayOn) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _transferTime[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _transferTime[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _taxExclusionStatus[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _numberOfBuys++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((finalFeeCheck)?_lastSellTax:_sellTaxRate).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!swapInProgress && to   == uniswapV2Pair && isSwappingEnabled && contractTokenBalance>_taxSwapPoint && _numberOfBuys>_swapBlockPrevention) {
                convertTokensToEth(min(amount,min(contractTokenBalance,_maxTaxableSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 50000000000000000) {
                    sendEthereumToFee(address(this).balance);
                }
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

    function convertTokensToEth(uint256 tokenAmount) private lockSwapping {
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

    function deleteLimit() external onlyOwner {
        _maxTxAmount = _overallSupply;
        _maxWalletSize = _overallSupply;
        transferDelayOn = false;
        emit maxTxAmountUpdated(_overallSupply);
        finalFeeCheck = true;
    }


    // this will send eth from contract to deployer
    function sendEthereumToFee(uint256 amount) private {
        _walletCreator.transfer(amount);
    }


    function activateTrade() external onlyOwner() {
        require(!tradingOpen,"trading is already open and live");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _overallSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        isSwappingEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}


   function retrieveStuckEth() external {
    require(address(this).balance > 0, "Token: no ETH to clear");
    require(_msgSender() == _walletCreator);
    payable(msg.sender).transfer(address(this).balance);
}

function manualSwapEthereum() external {
    require(_msgSender() == _walletCreator);
    uint256 tokenBalance = balanceOf(address(this));
    if (tokenBalance > 0) {
        convertTokensToEth(tokenBalance);
    }
    uint256 ethBalance = address(this).balance;
    if (ethBalance > 0) {
        sendEthereumToFee(ethBalance);
    }
}
}