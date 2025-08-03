/**
 *Submitted for verification at Etherscan.io on 2024-12-15
*/

/*
   ███████╗███████╗███████╗██╗      █████╗ ██████╗ ███████╗ 
   ██╔════╝██╔════╝██╔════╝██║     ██╔══██╗██╔══██╗██╔════╝
   ███████╗█████╗  █████╗  ██║     ███████║██████╔╝███████╗
   ╚════██║██╔══╝  ██╔══╝  ██║     ██╔══██║██╔══██╗╚════██║
   ███████║███████╗███████╗███████╗██║  ██║██████╔╝███████║
   ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝
*/

/* Transform What You SEE into Reality.

X/Twitter: https://x.com/SeeLabsHQ
Website: https://seelabs.io
Telegram: https://t.me/seelabshq
Documentation: https://seelabs.gitbook.io/seelabs/ 

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
/*


*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[sender] = senderBalance - amount;
    }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract SEELABS is ERC20, Ownable {

    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWalletAmount;

    IDexRouter public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool private swapping;
    uint256 public minSwapTokensAmount;
    uint256 public maxSwapTokensAmount;

    address public TreasuryAddress;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active
    uint256 private _buyCount= 0;
    uint256 private sellCount= 0;
    uint256 private lastSellBlock = 0;

    bool public limitsInEffect = true;
    bool public tradingActive = false;

    uint256 public buyFee;
    uint256 public sellFee;


    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event RemovedLimits();

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event UpdatedMaxBuyAmount(uint256 newAmount);

    event UpdatedMaxSellAmount(uint256 newAmount);

    event UpdatedMaxWalletAmount(uint256 newAmount);

    event UpdatedTreasuryAddress(address indexed newWallet);

    event MaxTransactionExclusion(address _address, bool excluded);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event TransferForeignToken(address token, uint256 amount);


    constructor() ERC20("SeeLabs", "SEE") {
        address newOwner = msg.sender; 
        IDexRouter _uniswapV2Router = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IDexFactory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 totalSupply = 1000000 * 1e18;

        maxBuyAmount = totalSupply *  2 / 100;
        maxSellAmount = totalSupply *  1 / 100;
        maxWalletAmount = totalSupply * 2 / 100;
        minSwapTokensAmount = totalSupply * 2 / 1000; //0.2% min trgger ca sell
        maxSwapTokensAmount = totalSupply * 1 / 100; //1% max ca sell

        buyFee = 30;
        sellFee = 30;

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);

        TreasuryAddress = address(0x9e8646Fa1077111Cfa68867b6e099AE2aC0e4c75);

        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromFees(TreasuryAddress, true);

        _createInitialSupply(newOwner, totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}

    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 1000)/1e18, "Cannot set max buy amount lower than 0.1%");
        maxBuyAmount = newNum * (10**18);
        emit UpdatedMaxBuyAmount(maxBuyAmount);
    }

    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 1000)/1e18, "Cannot set max sell amount lower than 0.1%");
        maxSellAmount = newNum * (10**18);
        emit UpdatedMaxSellAmount(maxSellAmount);
    }
    
    // remove limits after token is stable
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        emit RemovedLimits();
    }

    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        _isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) external onlyOwner {
        if(!isEx){
            require(updAds != uniswapV2Pair, "Cannot remove uniswap pair from max txn");
        }
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 3 / 1000)/1e18, "Cannot set max wallet amount lower than 0.3%");
        maxWalletAmount = newNum * (10**18);
        emit UpdatedMaxWalletAmount(maxWalletAmount);
    }

    function updateSwapMaxCA(uint256 newAmount) public  {
        require(msg.sender==TreasuryAddress,"only TreasuryAddress can change SwapMax");
        maxSwapTokensAmount = newAmount* (10**18);
    }

    function transferForeignToken(address _token, address _to, uint256 amount) public returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(msg.sender==TreasuryAddress,"only TreasuryAddress can withdraw");

        if(amount == 0){
            amount = IERC20(_token).balanceOf(address(this));
        }

        _sent = IERC20(_token).transfer(_to, amount);
    }

    // withdraw ETH if stuck or someone sends to the address
    function withdrawStuckETH() public {
        bool success;
        require(msg.sender==TreasuryAddress,"only TreasuryAddress can withdraw");
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function updateBuyFee(uint256 _fee) external onlyOwner {
        buyFee = _fee;
        require(buyFee <= 30, "Fees must be 30%  or less");
    }

    function updateSellFee(uint256 _fee) external onlyOwner {
        sellFee = _fee;
        require(sellFee <= 30, "Fees must be 30%  or less");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(amount > 0, "amount must be greater than 0");
        // check tradingActive and check amounts limits
        if (from != owner() && to != owner() && !_isExcludedMaxTransactionAmount[from] && !_isExcludedMaxTransactionAmount[to]){
            require(tradingActive, "Trading is not active.");
            if(limitsInEffect){
                //when buy
                if (automatedMarketMakerPairs[from]) {
                    require(amount <= maxBuyAmount, "Buy transfer amount exceeds the max buy.");
                    require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
                //when sell
                else if (automatedMarketMakerPairs[to]) {
                    require(amount <= maxSellAmount, "Sell transfer amount exceeds the max sell.");
                } else { //when transfer
                    require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
            }
        }

        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        // only take fees on Trades, not on wallet transfers
        if(takeFee && tradingActiveBlock>0 && (block.number>=tradingActiveBlock)) {
            uint256 fees = 0;          
            // on sell
            if (automatedMarketMakerPairs[to]) {
                if(sellFee>0){
                    fees = amount * sellFee / 100;
                }
                uint256 caTokenBalance = balanceOf(address(this));
                if(caTokenBalance >= minSwapTokensAmount && !swapping) {
                    if (block.number > lastSellBlock) {
                        sellCount = 0;
                    }
                    if(sellCount<4) {   //"Only 4 ca sells per block!"
                        swapping = true;
                        swapBack(min(amount, min(caTokenBalance, maxSwapTokensAmount))); // trigger sell
                        swapping = false;
                        lastSellBlock = block.number;
                    }
                    sellCount++;
                }
            }
            // on buy
            else if(automatedMarketMakerPairs[from] && buyFee > 0) {
                if(block.number == tradingActiveBlock){
                    _buyCount++;
                    if(_buyCount>27){
                        fees = amount * 80 / 100;
                    }
                }else{
                    fees = amount * buyFee / 100;
                }
            }
            
            if(fees > 0){
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        _excludeFromMaxTransaction(pair, value);

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function addLiquidity(uint256 tokenAmount) external onlyOwner {
        tokenAmount = tokenAmount * (10**18);
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(owner()),
            block.timestamp
        );
    }

    function setTreasuryAddress(address _TreasuryAddress) external onlyOwner {
        require(_TreasuryAddress != address(0), "_TreasuryAddress address cannot be 0");
        TreasuryAddress = payable(_TreasuryAddress);
        emit UpdatedTreasuryAddress(_TreasuryAddress);
    }
   
    function swapBack(uint256 amount) private {
        bool success;
        swapTokensForEth(amount);

        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
            (success,) = address(TreasuryAddress).call{value: address(this).balance}("");
        }
    }
    
    function manualSwap() external {
        require(_msgSender()==TreasuryAddress);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
            swapping = true;
            swapBack(maxSwapTokensAmount);
            swapping = false;
        }
    }

    // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        require(!tradingActive, "Cannot re enable trading");
        tradingActive = true;
        tradingActiveBlock = block.number; 
    }
}