// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;


/*

In this world,
acquiring these arcane tokens 
requires more than mere transactions. 

To possess these tokens, one must first solve a riddle that tests wit and perseverance. 
Only those who unravel the enigma are deemed worthy to acquire the RiddleToken. 

Me gatekeeper of this realm,
has crafted these challenges to ensure that only the moscunning minds
can partake in this journey

-riddlemaster


The Riddle

"I speak without a mouth and hear without ears. I have no body, but I come alive with the wind. What am I?"





*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IArcaneToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library EnigmaMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "EnigmaMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "EnigmaMath: subtraction overflow");
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
        require(c / a == b, "EnigmaMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "EnigmaMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract MysticalOwnable is Context {
    address private _riddleMaster;
    event OwnershipTransferred(address indexed previousRiddleMaster, address indexed newRiddleMaster);

    constructor () {
        address msgSender = _msgSender();
        _riddleMaster = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function riddleMaster() public view returns (address) {
        return _riddleMaster;
    }

    modifier onlyRiddleMaster() {
        require(_riddleMaster == _msgSender(), "MysticalOwnable: caller is not the RiddleMaster");
        _;
    }

    function renounceRiddleMaster() public virtual onlyRiddleMaster {
        emit OwnershipTransferred(_riddleMaster, address(0));
        _riddleMaster = address(0);
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

contract RiddleToken is Context, IArcaneToken, MysticalOwnable {
    using EnigmaMath for uint256;
    mapping (address => uint256) private _mysticalBalances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExemptFromFee;
    mapping (address => bool) private banished;
    mapping (address => bool) private _allowedToAcquire;

    address payable private _treasuryWallet;
    string private constant _name = unicode"The Riddle";
    string private constant _symbol = unicode"RIDDLE";
    string public constant deployerTitle = "RiddleMaster";
    bytes32 private constant riddleAnswerHash = keccak256(abi.encodePacked("echo"));

    
    uint256 private _initialAcquireTax=23;
    uint256 private _initialSellTax=23;
    uint256 private _finalAcquireTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceAcquireTaxAt=25;
    uint256 private _reduceSellTaxAt=25;
    uint256 private _preventSwapBefore=5;
    uint256 private _transferTax=0;
    uint256 private _acquireCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 369000000000 * 10**_decimals;
    uint256 public _maxTxAmount = 7380000000 * 10**_decimals;
    uint256 public _maxWalletSize = 7380000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 3690000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 3690000000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    bool private riddleProtectionEnabled = true;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _treasuryWallet = payable(_msgSender());
        _mysticalBalances[_msgSender()] = _totalSupply;
        _isExemptFromFee[riddleMaster()] = true;
        _isExemptFromFee[address(this)] = true;
        _isExemptFromFee[_treasuryWallet] = true;

        // Initialize Uniswap Router and Pair
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isExemptFromFee[address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)] = true;
        _isExemptFromFee[uniswapV2Pair] = true;
        _isExemptFromFee[uniswapV2Router.factory()] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _mysticalBalances[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ArcaneToken: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ArcaneToken: approve from the zero address");
        require(spender != address(0), "ArcaneToken: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ArcaneToken: transfer from the zero address");
        require(to != address(0), "ArcaneToken: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != riddleMaster() && to != riddleMaster()) {
            require(!banished[from] && !banished[to]);

            if (riddleProtectionEnabled) {
                require(_allowedToAcquire[to] || _isExemptFromFee[to], "You must solve the riddle to acquire tokens.");
            }

            if(_acquireCount==0){
                taxAmount = amount.mul((_acquireCount>_reduceAcquireTaxAt)?_finalAcquireTax:_initialAcquireTax).div(100);
            }
            if(_acquireCount>0){
                taxAmount = amount.mul(_transferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExemptFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_acquireCount>_reduceAcquireTaxAt)?_finalAcquireTax:_initialAcquireTax).div(100);
                _acquireCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_acquireCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _acquireCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if(taxAmount>0){
          _mysticalBalances[address(this)]=_mysticalBalances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _mysticalBalances[from]=_mysticalBalances[from].sub(amount);
        _mysticalBalances[to]=_mysticalBalances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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

    function removeLimits() external onlyRiddleMaster{
        _maxTxAmount = _totalSupply;
        _maxWalletSize=_totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function removeTransferTax() external onlyRiddleMaster{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    function sendETHToFee(uint256 amount) private {
        _treasuryWallet.transfer(amount);
    }

    function addBanished(address[] memory banished_) public onlyRiddleMaster {
        for (uint i = 0; i < banished_.length; i++) {
            banished[banished_[i]] = true;
        }
    }

    function delBanished(address[] memory notBanished) public onlyRiddleMaster {
      for (uint i = 0; i < notBanished.length; i++) {
          banished[notBanished[i]] = false;
      }
    }

    function isBanished(address a) public view returns (bool){
      return banished[a];
    }

    function openTheRiddle() external onlyRiddleMaster() {
        require(!tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,riddleMaster(),block.timestamp);
        IArcaneToken(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    function solveRiddle(string memory answer) external {
        require(keccak256(abi.encodePacked(answer)) == riddleAnswerHash, "Incorrect riddle answer.");
        _allowedToAcquire[_msgSender()] = true;
    }

    function disableRiddleProtection() external onlyRiddleMaster {
        riddleProtectionEnabled = false;
    }

    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_treasuryWallet);
      require(_newFee<=_finalAcquireTax && _newFee<=_finalSellTax);
      _finalAcquireTax=_newFee;
      _finalSellTax=_newFee;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_treasuryWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function manualSend() external {
        require(_msgSender()==_treasuryWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}