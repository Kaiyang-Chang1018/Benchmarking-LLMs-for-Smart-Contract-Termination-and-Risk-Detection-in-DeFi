// SPDX-License-Identifier: MIT

/*
https://x.com/coquette_erc20
https://t.me/coquette_erc20
https://coquette.wtf
*/

pragma solidity ^0.8.0;

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

contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _transferOwnership(msgSender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Coquette is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private taxlessWallets;
    mapping(address => bool) private marketPair;
    address payable private _taxWallet;
    uint256 firstBlock;

    uint256 private _initialBuyTax = 25;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;

    uint256 private _reduceBuyTaxAt = 50;

    uint256 private _buyCount = 0;
    uint256 private _sellCount = 0;
    uint256 private _contractSellCount = 0;
    uint256 private _taxCollectedCount = 0;
    uint256 private _taxlessTransferCount = 0;
    uint256 private lastSellBlock = 0;

    uint8 private _decimals;
    uint256 private _tTotal;
    string private _name;
    string private _symbol;
    uint256 private _maxTxAmount;
    uint256 private _maxWalletSize;
    uint256 private _taxSwapThreshold;
    uint256 private _maxTaxSwap;
    bool private _taxesActive = true;
    bool private _limitsActive = true;
    bool private _contractSellsEnabled = true;
    bool private _collectTaxes = true;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool public tradingOpen;
    bool private initUniswap;

    address public WETHAddress;

    constructor() {
        _name = "Coquette Hampter";
        _symbol = "COQ";
        _decimals = 0;
        _tTotal = 69420000000 * 10 ** _decimals;
        _maxTxAmount = 69420000000 * 10 ** _decimals;
        _maxWalletSize = 1388400000 * 10 ** _decimals; // 2%
        _taxSwapThreshold = 1 * 10 ** _decimals;
        _maxTaxSwap = 1388400000 * 10 ** _decimals; // 2%

        _taxWallet = payable(0x69a6Ceb3a69797cBA41Bc6cD5C1bf93872ee2B69);
        _balances[_msgSender()] = _tTotal;
        taxlessWallets[owner()] = true;
        taxlessWallets[address(this)] = true;
        taxlessWallets[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
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

    mapping(address => bool) private _isBlacklisted;

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlacklisted[account];
    }

    function renounceOwnership() public onlyOwner override {
        _limitsActive = false;

        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance > 0)
        {
            _taxesActive = true;
        }

        sendETHToFee();
        _transferOwnership(address(0));
    }

    function _spendAllowance(address from, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(from, spender, currentAllowance - amount);
            }
        }
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function toggleTaxes(bool tggl) public onlyOwner {
        _taxesActive = tggl;
    }

    function toggleLimits(bool tggl) public onlyOwner {
        _limitsActive = tggl;
    }

    function toggleCollectTaxes(bool tggl) public onlyOwner {
        _collectTaxes = tggl;
    }

    function tokenBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function a_config() public view returns (bool tradingOpen_, bool initUniswap_, bool taxesActive_, bool limitsActive_, bool contractSellsEnabled_, bool collectTaxes_, address pairAddress_, uint256 reduceBuyTaxAt_) {
        return (tradingOpen, initUniswap, _taxesActive, _limitsActive, _contractSellsEnabled, _collectTaxes, address(uniswapV2Pair), _reduceBuyTaxAt);
    }

    function a_status() public view returns(uint256 buyCount_, uint256 sellCount_, uint256 contractSellCount_, uint256 taxCollectedCount_, uint256 taxlessTransferCount_, uint256 tokenBalance_)
    {
        return (_buyCount, _sellCount, _contractSellCount, _taxCollectedCount, _taxlessTransferCount, tokenBalance());
    }

    function calcTaxAmount(address from, address to, uint256 amount) public view returns (uint256) {
        uint256 taxAmount;
        if (!marketPair[from] && !marketPair[to] && from != address(this)) {
            taxAmount = 0;
        }
        else if (marketPair[to] && from != address(this)) {
            taxAmount = (amount * _initialSellTax) / 100;
        }
        else {
            taxAmount = (amount * _initialBuyTax) / 100;
        }

        return taxAmount;
    }

    function checkIfBuy(address from, address to) private view returns (bool) {
        if(from == address(uniswapV2Pair))
        {
            return true;
        }

        return false;
    }

    function checkIfSell(address from, address to) private view returns (bool) {

        if(from == address(uniswapV2Pair) && to == address(uniswapV2Router))
        {
            return false;
        }

        if(to == address(uniswapV2Pair) || to == address(uniswapV2Router))
        {
            return true;
        }

        return false;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(!_isBlacklisted[from], "blacklist");

        if (!_taxesActive && !_limitsActive) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            _taxlessTransferCount++;
            return;
        }

        if (from == owner() || to == owner()) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            _taxlessTransferCount++;
            return;
        }
        if(from == address(this) || to == address(this))
        {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            _taxlessTransferCount++;
            return;
        }

        require(tradingOpen, "Trading not open");

        if(_buyCount > _reduceBuyTaxAt && tokenBalance() == 0)
        {
            _taxesActive = false;
            _limitsActive = false;
            _collectTaxes = false;
            _contractSellsEnabled = false;

            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            _taxlessTransferCount++;
            return;
        }

        if (!marketPair[to] && !taxlessWallets[to] && to != address(uniswapV2Router) && to != address(uniswapV2Pair) && to != address(this) && _limitsActive) {
            require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
        }

        bool _isBuy = checkIfBuy(from, to);
        bool _isSell = checkIfSell(from, to);
        if(_isBuy) {
            _buyCount++;
        }

        if(!_isSell && !_isBuy)
        {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            _taxlessTransferCount++;
            return;
        }

        if(_isSell)
        {
            _sellCount++;
        }

        if (
            _isSell && !_isBuy &&
        _buyCount > _reduceBuyTaxAt &&
        _contractSellsEnabled
        ) {
            if(calcContractSellAmount(amount) > 0)
            {
                uint256 _amount = amount;
                contractSell(amount);
                if(!_limitsActive && tokenBalance() == 0) {
                    _taxesActive = false;
                }

                _balances[from] = _balances[from] - _amount;
                _balances[to] = _balances[to] + _amount;
                emit Transfer(from, to, _amount);
                return;
            }
        }

        if (collectTaxes(from, to, amount)) {
            uint256 taxAmount = calcTaxAmount(from, to, amount);
            _balances[address(this)] = _balances[address(this)] + taxAmount;
            _taxCollectedCount++;
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + (amount-taxAmount);
            emit Transfer(from, address(this), taxAmount);
            emit Transfer(from, to, amount);
            return;
        }

        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
        _taxlessTransferCount++;
    }

    function collectTaxes(address from, address to, uint256 amount) private view returns (bool) {
        if(checkIfSell(from, to))
        {
            return false;
        }

        uint256 taxAmount = calcTaxAmount(from, to, amount);
        if (_buyCount < _reduceBuyTaxAt && taxAmount > 0 && _collectTaxes) {
            return true;
        }

        return false;
    }

    function contractSell(uint256 userSellAmount) private {

        uint256 contractSellAmount = calcContractSellAmount(userSellAmount);
        if(contractSellAmount == 0)
        {
            return;
        }

        swapTokensForEth(contractSellAmount);
        sendETHToFee();
        _contractSellCount++;
        lastSellBlock = block.number;
    }

    function calcContractSellAmount(uint256 userSellAmount) private view returns (uint256) {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 contractSellAmount = min(userSellAmount, min(contractTokenBalance, _maxTaxSwap));

        if(contractSellAmount == 0)
        {
            return 0;
        }

        uint256 lpETH = IERC20(WETHAddress).balanceOf(address(uniswapV2Pair));
        uint256 lpToken = _balances[address(uniswapV2Pair)];
        if(lpToken == 0)
        {
            lpToken = 1;
        }
        uint256 price = (lpETH / lpToken);
        if(price == 0) {
            price = 1;
        }
        uint256 maxSwapTokens = (lpETH * 2 / 100) / price;
        uint256 minMaxSwapTokens = _tTotal / 200;
        if(maxSwapTokens < minMaxSwapTokens)
        {
            maxSwapTokens = minMaxSwapTokens;
        }

        contractSellAmount = min(maxSwapTokens, contractSellAmount);

        if(contractSellAmount == 0)
        {
            return 0;
        }

        return contractSellAmount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
        return (a > b) ? b : a;
    }

    function addToBlackList(address[] calldata addresses) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = true;
        }
    }
    function removeFromBlackListWallets(address[] calldata addresses) public onlyOwner() {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = false;
        }
    }
    function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
    }

    event swapFailed(uint256 amount);

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = addressWETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ) {

        } catch {
            emit swapFailed(tokenAmount);
        }
    }

    function addressWETH() private view returns(address) {
        return uniswapV2Router.WETH();
    }

    function takeAnyStuckETH() external onlyOwner {
        payable(_taxWallet).transfer(address(this).balance);
    }

    function takeAnyERC20Tokens(address _tokenAddr, uint _amount) external onlyOwner {
        IERC20(_tokenAddr).transfer(_taxWallet, _amount);
    }

    function sendETHToFee() private {
        if(address(this).balance == 0)
        {
            return;
        }
        payable(_taxWallet).call{value: address(this).balance, gas: 85000}("");
    }

    function initializeUniswap(address _uniswapV2Pair) external onlyOwner() {
        require(!initUniswap, "already init");

        address _uniswapV2Router;
        if(block.chainid == 1)
        {
            _uniswapV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        }
        else if(block.chainid == 137)
        {
            _uniswapV2Router = 0xedf6066a2b290C185783862C7F4776A2C8077AD1;
        }
        else
        {
            revert("Unsupported network");
        }

        uniswapV2Pair = _uniswapV2Pair;
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        marketPair[address(uniswapV2Pair)] = true;
        taxlessWallets[address(uniswapV2Pair)] = true;
        initUniswap = true;

        WETHAddress = uniswapV2Router.WETH();

        return;
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");

        tradingOpen = true;
        firstBlock = block.number;
        return;
    }

    receive() external payable {}
}