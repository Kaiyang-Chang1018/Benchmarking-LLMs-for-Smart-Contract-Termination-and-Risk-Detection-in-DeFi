// SPDX-License-Identifier: MIT
/*
     ____                  _ ______                          
    / __ \____ ___  ____  (_)_  __/__  ____  _________  _____
   / / / / __ `__ \/ __ \/ / / / / _ \/ __ \/ ___/ __ \/ ___/
  / /_/ / / / / / / / / / / / / /  __/ / / (__  ) /_/ / /    
  \____/_/ /_/ /_/_/ /_/_/ /_/  \___/_/ /_/____/\____/_/    

  Website:  https://omnitensor.io/
  X:        https://x.com/OmniTensor/
  Telegram: https://t.me/OmniTensor/
  Github:   https://github.com/omnitensor/
  Docs:     https://docs.omnitensor.io/
  Explorer: https://explorer.omnitensor.io/

*/

pragma solidity 0.8.20;

interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _contractOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * Constructor sets the deployer as the initial owner of the contract.
     */
    constructor() {
        address msgSender = _msgSender();
        _contractOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _contractOwner;
    }

    modifier onlyOwner() {
        require(_contractOwner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * Transfers ownership to a new address.
     * newOwner cannot be a zero address.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _updateOwnership(newOwner);
    }

    function _updateOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_contractOwner, newOwner);
        _contractOwner = newOwner;
    }

    /**
     * Renounces ownership, making the contract ownerless.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_contractOwner, address(0));
        _contractOwner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 tokenAmount,
        uint256 minETHAmount,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint tokenDesired,
        uint tokenMin,
        uint ethMin,
        address to,
        uint deadline
    ) external payable returns (uint tokenAmount, uint ethAmount, uint liquidity);
}

contract OmniTensor is Context, IERC20, Ownable {
    string private constant _tokenName = "OmniTensor";
    string private constant _tokenSymbol = "OMNIT";
    uint8 private constant _tokenDecimals = 18;
    uint256 private constant _totalSupply = 1000000000 * 10**_tokenDecimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _excludedAccounts; // Track excluded accounts for fees or limits

    uint256 private constant _minSwapTokens = 100000 * 10**_tokenDecimals; // Minimum tokens to trigger swap
    uint256 private _maxSwapTokens = 5000000 * 10**_tokenDecimals; // Maximum tokens to swap at once

    uint256 public maxTxValue = 5000000 * 10**_tokenDecimals; // Max transaction value allowed
    uint256 public maxWalletHoldings = 10000000 * 10**_tokenDecimals; // Max wallet balance allowed

    uint256 private _launchBlock;
    uint256 buyFeeRate = 30; // Buy transaction fee rate (percentage)
    uint256 sellFeeRate = 30; // Sell transaction fee rate (percentage)

    IUniswapV2Router02 private _uniswapV2Router;
    address public uniswapV2Pair;
    address OmegaWallet; // Wallet for specific allocation
    address GammaWallet;
    address BetaWallet;
    address AlphaWallet;

    bool private _isTradingActive = false; // Flag to check if trading is active

    /**
     * Constructor initializes wallets and assigns the total token supply to the contract deployer.
     */
    constructor() {
        OmegaWallet = 0x891C76B4729b8bddAB00FD5deCd419FB9f33BEdF;
        GammaWallet = 0xBd92bF5d4f7d1E4E8f3B3E99F99738B9aEEfCC55;
        BetaWallet = 0xca9Ca67a79a23681A6A13C55724128D023F6A953;
        AlphaWallet = 0x2F6D0A6B2bC5e219eb9a288F63048b911648B9Aa;

        _balances[msg.sender] = _totalSupply;
        _excludedAccounts[msg.sender] = 1;
        _excludedAccounts[address(this)] = 1;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _tokenName;
    }

    function symbol() public pure returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() public pure returns (uint8) {
        return _tokenDecimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns current buy and sell tax rates.
     */
    function getFeeRates() external view returns (uint256 buyTax, uint256 sellTax) {
        buyTax = buyFeeRate;
        sellTax = sellFeeRate;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _setAllowance(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _setAllowance(sender, _msgSender(), currentAllowance - amount);
            }
        }
        return true;
    }

    function _setAllowance(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Starts trading by setting up Uniswap pair and enabling liquidity.
     */
    function startTrading() external onlyOwner {
        require(!_isTradingActive, "Trading is already enabled");
        _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAllowance(address(this), address(_uniswapV2Router), _totalSupply);
        
        _uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(address(_uniswapV2Router), type(uint).max);
        _isTradingActive = true;
        _launchBlock = block.number;
    }

    /**
     * Excludes or includes an account from fee calculations or limits.
     */
    function setExcludedAccount(address account, uint256 value) external onlyOwner {
        _excludedAccounts[account] = value;
    }

    /**
     * Removes transaction and wallet holding limits.
     */
    function disableLimits() external onlyOwner {
        maxTxValue = _totalSupply;
        maxWalletHoldings = _totalSupply;
    }

    /**
     * Adjusts the buy and sell tax rates. The new tax rates cannot exceed the existing rates.
     */
    function adjustTaxRates(uint256 newBuyTaxRate, uint256 newSellTaxRate) external onlyOwner {
        require(newBuyTaxRate <= buyFeeRate && newSellTaxRate <= sellFeeRate, "Tax cannot be increased");
        buyFeeRate = newBuyTaxRate;
        sellFeeRate = newSellTaxRate;
    }

    /**
     * Handles token transfer and applies a tax based on the transaction type (buy/sell).
     */
    function _executeTokenTransfer(address from, address to, uint256 amount, uint256 taxRate) private {
        uint256 taxAmount = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;

        _balances[from] -= amount;
        _balances[to] += transferAmount;
        _balances[address(this)] += taxAmount;

        emit Transfer(from, to, transferAmount);
    }

    /**
     * Core transfer logic, including validation and fee application.
     */
    function _executeTransfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        uint256 taxRate = 0;

        if (_excludedAccounts[from] == 0 && _excludedAccounts[to] == 0) {
            require(_isTradingActive, "Trading is not enabled yet");
            require(amount <= maxTxValue, "Transaction amount exceeds the maximum limit");
            
            if (to != uniswapV2Pair && to != address(0xdead)) {
                require(balanceOf(to) + amount <= maxWalletHoldings, "Recipient wallet exceeds the maximum limit");
            }

            if (block.number < _launchBlock + 3) {
                taxRate = (from == uniswapV2Pair) ? 30 : 30;
            } else {
                if (from == uniswapV2Pair) {
                    taxRate = buyFeeRate;
                } else if (to == uniswapV2Pair) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > _minSwapTokens) {
                        uint256 swapAmount = _maxSwapTokens;
                        if (contractTokenBalance > amount) contractTokenBalance = amount;
                        if (contractTokenBalance > swapAmount) contractTokenBalance = swapAmount;
                        _exchangeTokensForEth(contractTokenBalance);
                    }
                    taxRate = sellFeeRate;
                }
            }
        }
        _executeTokenTransfer(from, to, amount, taxRate);
    }

    /**
     * Withdraws ETH from the contract.
     */
    function withdrawEth() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Rescue ETH failed");
    }

    /**
     * Transfers the remaining tokens in the contract to the owner.
     */
    function recoverTokens() external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens to rescue");

        _executeTokenTransfer(address(this), owner(), contractTokenBalance, 0);
    }

    /**
     * Swaps a percentage of the contract's tokens for ETH.
     */
    function executeManualSwap(uint256 percent) external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 swapAmount = (percent * contractTokenBalance) / 100;
        _exchangeTokensForEth(swapAmount);
    }

    /**
     * Swaps tokens for ETH using the Uniswap router and allocates ETH to specific wallets.
     */
    function _exchangeTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _setAllowance(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 contractEthBalance = address(this).balance;
        uint256 OmegaFund = (contractEthBalance * 10) / 100;
        uint256 GammaFund = (contractEthBalance * 30) / 100;
        uint256 BetaFund = (contractEthBalance * 30) / 100;
        uint256 AlphaFund = (contractEthBalance * 30) / 100;

        (bool success, ) = OmegaWallet.call{value: OmegaFund}("");
        (success, ) = GammaWallet.call{value: GammaFund}("");
        (success, ) = BetaWallet.call{value: BetaFund}("");
        (success, ) = AlphaWallet.call{value: AlphaFund}("");
        

        require(success, "Transfer failed");
    }

    receive() external payable {}
}