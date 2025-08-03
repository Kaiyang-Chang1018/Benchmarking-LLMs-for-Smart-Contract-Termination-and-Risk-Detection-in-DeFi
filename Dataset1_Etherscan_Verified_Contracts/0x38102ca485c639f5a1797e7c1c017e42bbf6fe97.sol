/*

One of Pyrosis's standout features is the BurnToETH function, available via our decentralized application (dApp).
This feature enables holders to burn their $PYRO and receive Ethereum (ETH) in return. 


https://t.me/pyrosisentry
https://x.com/Pyrosis_ERC
https://pyrosis.app/

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Pyrosis is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedWallet;
    uint8 private constant _decimals = 9;

    string private constant _name = "Pyrosis";
    string private constant _symbol = "Pyro";

    uint256 private constant _totalSupply = 100_000_000 * 10**_decimals;
    uint256 public maxWallet = (_totalSupply * 2)/100;
    uint256 public maxTx = (_totalSupply * 2)/100;
    uint256 private constant minCASell = _totalSupply / 1000;  //0.1%
    uint256 private maxCASell = _totalSupply / 100 ; // 1%

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=30;
    uint256 private _reduceTaxAt=20;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=7;
    uint256 private splitToCA = 40; // % from taxed ETH will go to CA for execute BURN

    uint256 public burnCapDivisor = 10; // Divisor for burn reward cap per tx
    uint256 public burnSub1EthCap = 100000000000000000; // cap in WEI if rewards < 1 Eth
    uint256 public totalBurned = 0;
    uint256 public totalBurnRewards = 0;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool private launch = false;
    uint256 private blockLaunch;
    uint256 private lastSellBlock;
    uint256 private sellCount;
    uint256 private _buyCount= 0;
    uint256 private totalBuysCount = 0;
    uint256 private totalSellsCount = 0;
    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    event BurnedTokensForEth (
        address account,
        uint256 burnAmount,
        uint256 ethRecievedAmount
    );
    address payable private treasury; 

    constructor() payable {
        treasury = payable(0xeF52A749d9Ab96D77485261253F7dd493E10faA6);
        _isExcludedWallet[msg.sender] = true;
        _isExcludedWallet[address(this)] = true;
        _isExcludedWallet[treasury] = true;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _allowances[owner()][address(uniswapV2Router)] = _totalSupply;
        _balance[owner()] = _totalSupply;

        emit Transfer(address(0), owner(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"low allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "approve zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function openTrading() external onlyOwner {
        launch = true;
        blockLaunch = block.number;
    }

    // msg.sender burns tokens and recieve uniswap rate TAX FREE, instead of selling.
    function burnForEth(uint256 amount) public returns (bool) {
        require(balanceOf(_msgSender()) >= amount, "not enough funds to burn");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint[] memory a = uniswapV2Router.getAmountsOut(amount, path);

        uint256 cap;
        if (address(this).balance <= 1 ether) {
            cap = burnSub1EthCap;
        } else {
            cap = address(this).balance / burnCapDivisor;
        }

        require(a[a.length - 1] <= cap, "amount greater than cap");
        require(address(this).balance >= a[a.length - 1], "not enough funds in contract");

        transferToAddressETH(_msgSender(), a[a.length - 1]);
        _burn(_msgSender(), amount);
        
        totalBurnRewards += a[a.length - 1];
        totalBurned += amount;

        emit BurnedTokensForEth(_msgSender(), amount, a[a.length - 1]);
        return true;
    }

    function transferToAddressETH(address  recipient, uint256 amount) private {
        payable(recipient).transfer(amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balance[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balance[account] = accountBalance - amount;
        }
        _balance[deadAddress] = _balance[deadAddress] + amount;

        emit Transfer(account, address(deadAddress), amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer zero address");
        require(amount > 0, "transfer zero amount");
        uint256 _tax = 0;

        if(!_isExcludedWallet[from] && !_isExcludedWallet[to]){
            //NOT EXCLUDED:

            require(launch); // check CA allowed trading on DEX
            require(amount <= maxTx, "Over MaxTx limit");
            
            if (from == uniswapV2Pair) {
                //BUY:
                require(balanceOf(to) + amount <= maxWallet, "Over MaxWallet limit");
                
                if(block.number != blockLaunch){
                   totalBuysCount++;
                    _tax = totalBuysCount > _reduceTaxAt ? _finalBuyTax : _initialBuyTax;
                }else{
                    _buyCount++;
                    _tax = 0;
                    require(_buyCount <= 52,"Exceeds buys on the first block.");
                }
            } else if (to == uniswapV2Pair) {
                //SELL:
                totalSellsCount++;
                _tax = totalSellsCount > _reduceTaxAt ? _finalSellTax : _initialSellTax;
                uint256 tokensSwap = balanceOf(address(this));
                if (tokensSwap > minCASell && !inSwap) {
                    if (block.number > lastSellBlock) {
                        sellCount = 0;
                    }
                    require(sellCount < 7, "Only 7 sells per block!");
                    sellCount++;
                    lastSellBlock = block.number;
                    swapTokenToEth(min(maxCASell, min(amount, tokensSwap)));
                }
            }
        }
        _balance[from] = _balance[from] - amount;

        if(_tax > 0){
            uint256 taxTokens = (amount * _tax) / 100;
            _balance[address(this)] = _balance[address(this)] + taxTokens;
            amount = amount - taxTokens;
            emit Transfer(from, address(this), taxTokens);
        }

        _balance[to] = _balance[to] + amount;
        emit Transfer(from, to, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokenToEth(uint256 tokenAmount) private lockTheSwap {
        uint256 balance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
        balance = address(this).balance - balance;
        treasury.transfer(balance - (balance * splitToCA / 100));
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _isExcludedWallet[owner()] = false;
        super.transferOwnership(newOwner);
        _isExcludedWallet[newOwner] = true;
    }

    function newFee(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= 20 && newSellTax <= 20); //Protect: Tax less then 20%
        _finalBuyTax = newBuyTax;
        _finalSellTax = newSellTax;
        _reduceTaxAt = 0;
    }

    function setExcludedWallet(address wAddress, bool isExcle) external  onlyOwner {
        _isExcludedWallet[wAddress] = isExcle;
    }

    function triggerSell(uint256 percentToSell) external onlyOwner {
        uint256 amount = percentToSell = min(balanceOf(address(this)), (_totalSupply * percentToSell / 100));
        swapTokenToEth(amount);
    }

    function setMaxCASell(uint256 _maxCaSell) external onlyOwner{
        maxCASell = _maxCaSell * 10**_decimals;
    }

    function setLimits(uint256 newMaxWalletAmount, uint256 newMaxTxAmount) external onlyOwner {
        maxWallet = newMaxWalletAmount * 10**_decimals;
        maxTx = newMaxTxAmount * 10**_decimals;
    }

    function removeAllLimits() external onlyOwner {
        maxWallet = _totalSupply;
        maxTx = _totalSupply;
    }

    //Amounts with decimals
    function getStuckTokens(address tokenAddress, uint256 amounts) external {
        require(msg.sender == treasury);
        if(amounts == 0){
            amounts = IERC20(tokenAddress).balanceOf(address(this));
        }
        IERC20(tokenAddress).transfer(treasury, amounts);
    }

    //Send tokens from ca to dead, call only from owner (without decimals)
    function burnTokens(uint256 amounts) external {
        require(msg.sender == treasury);
        IERC20(address(this)).transfer(0x000000000000000000000000000000000000dEaD, min(balanceOf(address(this)), amounts * 10**_decimals));
    }

    function getETH() external {
        require(msg.sender == treasury);
        treasury.transfer(address(this).balance);
    }

    function addLPeth() external payable onlyOwner() {
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)) - (_totalSupply * _initialBuyTax / 100),
            0,
            0,
            owner(),
            block.timestamp);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function getStats() public view returns (uint256, uint256, uint256) {
        return (totalBurned, totalBurnRewards, address(this).balance);
    }

    receive() external payable {}
}