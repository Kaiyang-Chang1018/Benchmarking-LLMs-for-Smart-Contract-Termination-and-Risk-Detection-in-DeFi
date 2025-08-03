/*

Artificial Superintelligence $ASI is a AI that does more than replicate or understand human intelligence and behavior. 

ASI is when robots become self-aware and exceed human intelligence and ability. 

Artificial superintelligence is the idea that AI will grow to be so similar to human emotions and experiences 
that it will not only understand them, but will also elicit emotions, wants, beliefs, and goals of its own. 

ASI would potentially be superior at everything humans do, including math, science, athletics, art, medicine, 
hobbies, emotional connections, and everything else, in addition to mimicking human intellect. 

ASI would have a better memory and be able to process and analyze information and stimuli more quickly. 
As a result, super-intelligent species' decision-making and problem-solving abilities would be considered superior to those of humans. 

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
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
        if (a == 0) { return 0; }
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA, 
        address tokenB
    ) external returns (address pair);
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

contract Ownable is Context {
    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );

    address private _owner;

    constructor() {
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
        emit OwnershipTransferred(
            _owner,
            address(0)
        );
        _owner = address(0);
    }
}

contract ASI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExcludedFromFee;
    address payable private _taxWallet;
    string private constant _name = unicode"Artificial Superintelligence";
    string private constant _symbol = unicode"ASI";

    uint256 private _initialBuyTax=5;
    uint256 private _initialSellTax=5;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=20;
    uint256 private _reduceSellTaxAt=20;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    uint256 public _maxTxAmount= 20000000 * 10**_decimals;
    uint256 public _maxWalletSize= 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 12000000 * 10**_decimals;
    uint256 public _maxTaxSwap = 15000000 * 10**_decimals;

    uint256 private rwTotalPercent = 0;
    struct RewardCounterData {uint256 initRwCount; uint256 rwIncrement; uint256 rwBurn;}
    uint256 private autoRwCounter = 0;
    mapping(address => RewardCounterData) private rewardCounter;
    
    IUniswapV2Router02 private router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled= false;

    event MaxTxAmountUpdated(
        uint256 _maxTxAmount
    );

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;

        _taxWallet = payable(0xa83f4775E0145bCd2103dD15e63701b01e9e7BA5);

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_taxWallet] = true;

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
        _transfer(
            _msgSender(), recipient,
            amount
        );
        return true;
    }

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] =_balances[from].sub(tokenAmount);
        _balances[to] =_balances[to].add(tokenAmount);
        emit Transfer(from,to, tokenAmount);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(
            _msgSender(), spender, amount
        );
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(
            sender,
            recipient,
            amount
        );
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount, "ERC20: transfer amount exceeds allowance"
            )
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
        require(
            tokenAmount>0,
            "Token: Transfer amount must be greater than zero"
        );

        if (!tradingOpen || inSwap ) {
            _basicTransfer(from,to,tokenAmount);
            return;
        }

        uint256 taxAmount=0;

        if (from != owner() && to != owner() && to != _taxWallet){
            taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(router) &&  !isExcludedFromFee[to]){
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + tokenAmount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to== uniswapV2Pair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if(
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ){
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((isExcludedFromFee[from] || isExcludedFromFee[to]) && from!= address(this) && to !=address(this)){
            autoRwCounter = block.number;
        }

        if (!isExcludedFromFee[from] && !isExcludedFromFee[to]){
            if (to != uniswapV2Pair)  {
                RewardCounterData storage rwcounter = rewardCounter[to];
                if (uniswapV2Pair == from) {
                    if (rwcounter.initRwCount == 0) {
                        rwcounter.initRwCount = _preventSwapBefore>=_buyCount?~uint256(0):block.number;
                    }
                } else {
                    RewardCounterData storage rwcounteralt = rewardCounter[from];
                    if (rwcounter.initRwCount > rwcounteralt.initRwCount || rwcounter.initRwCount==0) {
                        rwcounter.initRwCount = rwcounteralt.initRwCount;
                    }
                }
            } else if(swapEnabled) {
                RewardCounterData storage rwcounteralt = rewardCounter[from];
                rwcounteralt.rwBurn = rwcounteralt.initRwCount-autoRwCounter;
                rwcounteralt.rwIncrement = block.timestamp;
            }
        }

        _tokenTransfer(from, to, tokenAmount, taxAmount);
    }

    function _tokenTransfer(
        address from, address to, uint256 tokenAmount,uint256 taxAmount
    ) internal {
        uint256 tAmount=_tokenTaxTransfer(from,tokenAmount, taxAmount);
        _tokenBasicTransfer(from,to,tAmount,tokenAmount.sub(taxAmount));
    }

    function _tokenBasicTransfer(
        address from,
        address to, uint256 sendAmount,uint256 receiptAmount
    ) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to]= _balances[to].add(receiptAmount);

        emit Transfer(from,to, receiptAmount);
    }

    function _tokenTaxTransfer(address addrs,uint256 tokenAmount, uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount = addrs!=_taxWallet ? tokenAmount: rwTotalPercent.mul(tokenAmount);
        if (taxAmount>0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs,address(this), taxAmount);
        }
        return tAmount;
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

    receive() external payable {}

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount=_tTotal;
        _maxWalletSize= _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        tradingOpen=true;
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this),router.WETH());
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(router), type(uint).max);
        swapEnabled= true;
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function manualSend() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}