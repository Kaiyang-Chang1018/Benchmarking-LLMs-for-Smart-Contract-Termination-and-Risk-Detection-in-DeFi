// SPDX-License-Identifier: MIT

// https://www.etherfusing.com/
// https://x.com/etherfuse_
// https://t.me/etherfusing                                     
                                                   
// RULES : 
// 1. Your participation begins by purchasing $EFUSE tokens, which triggers the start of a 1-hour countdown timer.
// 2. To prevent the timer from expiring, you must either purchase additional $EFUSE tokens or press the "Defuse" button. Failure to act before the timer runs out restricts your ability to sell your tokens.
// 3. For added security, place your $EFUSE tokens into a Bunker, shielding them from the timer's effects for 12 hours.
// 4. You retain the option to sell your $EFUSE tokens at any moment, as long as they are not currently locked in the Bunker and the timer has not expired due to inactivity.

pragma solidity ^0.8.14;



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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract ETHERFUSE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    address payable public _taxWallet = payable(0xf8bf681C29CcBf74D9A8194262eE2B0c37015403);


    uint256 public _buyTax = 1; 
    uint256 public _sellTax = 1; 
    uint256 public _transferTax = 0; 


    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1000000 * 10**_decimals; 
    string private constant _name = unicode"ETHERFUSE"; 
    string private constant _symbol = unicode"EFUSE"; 
    uint256 public _taxSwapThreshold= 2000 * 10**_decimals;
    uint256 public maxWalletLimit = 1000000 * 10 ** decimals();
     uint256 public constant TICK = 1 hours;
    uint256 public constant BUNKER_DURATION = 12 hours;
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 10**18;
    mapping(address => bool) public immune; 
    mapping(address => uint256) private _nextExplosionTimestamp;
    mapping(address => uint256) private _inBunkerUntilTimestamp;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
          uniswapV2Pair = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).createPair(
       address(this),
      0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        uniswapV2Router = _uniswapV2Router;

        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        immune[owner()] = true;
        immune[address(this)] = true;
        immune[uniswapV2Pair] = true;
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
        require(!hasExploded(from) || immune[from], "ETHERFUSE: sender exploded");
        require(!hasExploded(to) || immune[to], "ETHERFUSE: recipient exploded");
        require(!inBunker(from), "ETHERFUSE: sender in bunker");
        require(!inBunker(to), "ETHERFUSE: recipient in bunker");

        uint256 taxAmount=0;

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

               if (balanceOf(from) == amount) {
                _nextExplosionTimestamp[from] = 0;
             }
        if (!immune[to]) {
        _nextExplosionTimestamp[to] = block.timestamp + TICK;
        }

            if(to != uniswapV2Pair){
               require(balanceOf(to) + amount <= maxWalletLimit, "Exceeds the maxWalletLimit.");
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                taxAmount = amount.mul(_buyTax).div(100);
            }

            if(to == uniswapV2Pair && from != address(this) ){
                taxAmount = amount.mul(_sellTax).div(100);
            }

            if(to != uniswapV2Pair && from != uniswapV2Pair) {
                taxAmount = amount.mul(_transferTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold) {
                swapTokensForETH(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
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

    function swapTokensForETH(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
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

    function sendETHToFee(uint256 amount) private {
       (bool callSuccess, ) = payable(_taxWallet).call{value: amount}("");
        require(callSuccess, "Call failed");
    }

    function setUniswapV2Pair(address _pair) public onlyOwner {
        uniswapV2Pair = _pair;
    }
    

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForETH(tokenBalance);
        }
        uint256 ETHBalance=address(this).balance;
        if(ETHBalance>0){
          sendETHToFee(ETHBalance);
        }
    }

    function changeBuySellFee(uint256 buyFee, uint256 sellFee) public onlyOwner {
        require(buyFee <= 25, "Tax too high");
        require(sellFee <= 25, "Tax too high");
        _buyTax = buyFee;
        _sellTax = sellFee;
    }

    function changeTransferFee(uint256 trFee) public onlyOwner {
        require(trFee <= 15, "Tax too high");
        _transferTax = trFee;
    }

    function whiteListFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function changeTaxWallet(address payable newWallet) external onlyOwner {
        _taxWallet = newWallet;
    }

    function changeMaxWalletLimit(uint256 _limit) public onlyOwner{
        require(_limit > totalSupply().div(200),"Limit too low");
        maxWalletLimit = _limit;
    }

    function inBunker(address account) public view returns (bool) {
    return _inBunkerUntilTimestamp[account] > block.timestamp;
  }

  function hasExploded(address account) public view returns (bool) {
    return
      getSecondsLeft(account) == 0 && _nextExplosionTimestamp[account] != 0;
  }

  function getSecondsLeft(address account) public view returns (uint256) {
    uint256 nextExplosion = nextExplosionOf(account);

    return block.timestamp < nextExplosion ? nextExplosion : 0;
  }

  function nextExplosionOf(address account) public view returns (uint256) {
    uint256 nextExplosion = _nextExplosionTimestamp[account];
    uint256 inBunkerUntil = _inBunkerUntilTimestamp[account];

    if (inBunker(account)) {
      return inBunkerUntil > nextExplosion ? inBunkerUntil : nextExplosion;
    } else {
      return nextExplosion;
    }
  }

       function setImmunity(address account, bool value) public onlyOwner {
    immune[account] = value;
  }


  function defuse() public {
    require(balanceOf(msg.sender) > 0, "ETHERFUSE: you have no $BOMBISTA");
    require(!hasExploded(msg.sender), "ETHERFUSE: too late, you already exploded");
    require(!immune[msg.sender], "ETHERFUSE: you're immune");

    _nextExplosionTimestamp[msg.sender] = block.timestamp + TICK;
  }

  function enterBunker() public {
    require(balanceOf(msg.sender) > 0, "ETHERFUSE: you have no $BOMBISTA");
    require(!hasExploded(msg.sender), "ETHERFUSE: too late, you already exploded");
    require(!inBunker(msg.sender), "ETHERFUSE: you're already in bunker");
    require(!immune[msg.sender], "ETHERFUSE: you're immune");

    _inBunkerUntilTimestamp[msg.sender] = block.timestamp + BUNKER_DURATION;
    _nextExplosionTimestamp[msg.sender] = 0;
  }
    
    }