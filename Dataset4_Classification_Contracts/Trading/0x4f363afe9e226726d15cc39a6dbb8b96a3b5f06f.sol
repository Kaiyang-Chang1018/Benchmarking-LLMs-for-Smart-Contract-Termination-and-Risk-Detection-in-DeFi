// Telegram: https://t.me/thugpepe
// Twitter: https://twitter.com/thugpepe_erc
// Website: https://thugpepe.vip

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ThugPepe is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant zeroAddress = address(0);
    address public constant deadAddress = address(0xdead);

    bool private swapping;
    bool public swapTrigger = false;
    bool public tradingOpen = false;
    bool public limitsInEffect = true;

    address public marketingWallet;
    address private developmentWallet;

    uint256 public swapTokensAtAmount;
    uint256 public maxTxAmount;
    uint256 public maxWallet;

    struct Taxes {
        uint256 marketing;
        uint256 development;
        uint256 liquidity;
        uint256 total;
    }
    Taxes public buyTax;
    Taxes public sellTax;

    uint256 private tokensForMarketing;
    uint256 private tokensForDevelopment;
    uint256 private tokensForLiquidity;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTxAmount;
    mapping(address => bool) private automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndLiquidity(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

    constructor() ERC20("Thug Pepe", "THUG") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        excludeFromMaxTxAmount(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTxAmount(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 totalSupply = 420000000000 * 10**decimals();

        maxTxAmount = totalSupply.mul(2).div(100);
        maxWallet = totalSupply.mul(4).div(100);
        swapTokensAtAmount = totalSupply.mul(1).div(1000);

        marketingWallet = _msgSender();
        developmentWallet = address(0xfbfEaF0DA0F2fdE5c66dF570133aE35f3eB58c9A);

        buyTax = Taxes(5, 0, 0, 5);
        sellTax = Taxes(40, 0, 0, 40);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        excludeFromMaxTxAmount(owner(), true);
        excludeFromMaxTxAmount(address(this), true);
        excludeFromMaxTxAmount(address(0xdead), true);

        _mint(_msgSender(), totalSupply);
    }

    receive() external payable {}

    function openTrading() external onlyOwner {
        require(tradingOpen == false, "The trading has been opened.");
        tradingOpen = true;
        swapTrigger = true;
    }

    function removeLimits() external onlyOwner {
        require(limitsInEffect == true, "The limits has been removed.");
        limitsInEffect = false;
    }

    function toggerSwapTrigger() external onlyOwner {
        swapTrigger = !swapTrigger;
    }

    function updateBuyTaxes(uint256 _marketing, uint256 _development, uint256 _liquidity) external onlyOwner {
        uint256 _total = _marketing + _development + _liquidity;
        require(_total <= 15, "Must keep fees at 15% or less");
        buyTax = Taxes(_marketing, _development, _liquidity, _total);
    }

    function updateSellTaxes(uint256 _marketing, uint256 _development, uint256 _liquidity) external onlyOwner {
        uint256 _total = _marketing + _development + _liquidity;
        require(_total <= 15, "Must keep fees at 15% or less");
        sellTax = Taxes(_marketing, _development, _liquidity, _total);
    }

    function updateMaxWalletAndTxnAmount(uint256 _maxTxAmount, uint256 _maxWallet) external onlyOwner {
        maxTxAmount = totalSupply().mul(_maxTxAmount).div(1000);
        maxWallet = totalSupply().mul(_maxWallet).div(1000);
    }

    function excludeFromMaxTxAmount(address _address, bool excluded) public onlyOwner {
        _isExcludedMaxTxAmount[_address] = excluded;
    }

    function excludeFromFees(address _address, bool excluded) public onlyOwner {
        _isExcludedFromFees[_address] = excluded;
        emit ExcludeFromFees(_address, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != zeroAddress, "ERC20: transfer from the zero address.");
        require(to != zeroAddress, "ERC20: transfer to the zero address.");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero.");

        if (from != owner() && to != owner() && to != zeroAddress && to != deadAddress && !swapping) {
            if (tradingOpen == false) {
                require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "ERC20: Trading is not active.");
            }

            if (limitsInEffect == true) {
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTxAmount[to]) {
                    require(amount <= maxTxAmount, "ERC20: Buy transfer amount exceeds the max transaction amount.");
                    require(amount + balanceOf(to) <= maxWallet, "TOKEN: Max wallet exceeded.");
                } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTxAmount[from]) {
                    require(amount <= maxTxAmount, "ERC20: Sell transfer amount exceeds the max transaction amount.");
                } else if (!_isExcludedMaxTxAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "ERC20: Max wallet exceeded.");
                }
            }
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (swapTrigger && canSwap && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[to] && sellTax.total > 0) {
                fees = amount.mul(sellTax.total).div(100);
                tokensForLiquidity += (fees * sellTax.liquidity) / sellTax.total;
                tokensForMarketing += (fees * sellTax.marketing) / sellTax.total;
                tokensForDevelopment += (fees * sellTax.development) / sellTax.total;
            }
            else if (automatedMarketMakerPairs[from] && buyTax.total > 0) {
                fees = amount.mul(buyTax.total).div(100);
                tokensForLiquidity += (fees * buyTax.liquidity) / buyTax.total;
                tokensForMarketing += (fees * buyTax.marketing) / buyTax.total;
                tokensForDevelopment += (fees * buyTax.development) / buyTax.total;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAddress,
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForDevelopment;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > swapTokensAtAmount * 20) {
            contractBalance = swapTokensAtAmount * 20;
        }

        uint256 liquidityTokens = (contractBalance * tokensForLiquidity) / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(tokensForMarketing).div(totalTokensToSwap);
        uint256 ethForDevelopment = ethBalance.mul(tokensForDevelopment).div(totalTokensToSwap);

        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForDevelopment;

        tokensForLiquidity = 0;
        tokensForMarketing = 0;
        tokensForDevelopment = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquidity(
                amountToSwapForETH,
                ethForLiquidity,
                tokensForLiquidity
            );
        }

        (success, ) = address(marketingWallet).call{value: ethForMarketing}("");
        (success, ) = address(developmentWallet).call{value: address(this).balance}("");
    }
}