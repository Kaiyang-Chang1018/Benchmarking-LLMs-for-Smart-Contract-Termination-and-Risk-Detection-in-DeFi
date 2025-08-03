// SPDX-License-Identifier: MIT
/*
         __    __    __    __    __    __    __    __    __    __    
         \  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \
          \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  
         __\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  
         \  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \
          \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  
         __\  \__\  \                                   \__\  \__\  
         \  \__\  \__\   https://links.squareslabs.ai    \  \__\  \
          \__\  \__\  \                                   \__\  \__\  
         __\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\ 
         \  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \
          \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  
         __\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  
         \  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \
          \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  \__\  
*/

pragma solidity 0.8.20;

interface IERC20 {
    // Emitted when tokens are transferred from one account to another.
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);

    // Emitted when an allowance is set for a spender by an owner.
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // Returns the total supply of the token.
    function totalSupply() external view returns (uint256);

    // Returns the balance of a given account.
    function balanceOf(address account) external view returns (uint256);

    // Transfers tokens from the caller to a recipient.
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Returns the remaining allowance a spender has from the owner.
    function allowance(address owner, address spender) external view returns (uint256);

    // Approves a spender to transfer tokens on behalf of the caller.
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfers tokens from a sender to a recipient using an allowance.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    // Provides the address of the caller of the function.
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _contractOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Constructor sets the deployer as the initial owner of the contract.
     */
    constructor() {
        address msgSender = _msgSender();
        _contractOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Returns the address of the current owner.
    function owner() public view returns (address) {
        return _contractOwner;
    }

    // Modifier to restrict access to only the owner.
    modifier onlyOwner() {
        require(_contractOwner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership to a new address.
     *      The newOwner cannot be the zero address.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _updateOwnership(newOwner);
    }

    // Internal function to update the owner address.
    function _updateOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_contractOwner, newOwner);
        _contractOwner = newOwner;
    }

    /**
     * @dev Renounces ownership, leaving the contract ownerless.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_contractOwner, address(0));
        _contractOwner = address(0);
    }
}

interface IUniswapV2Factory {
    // Creates a pair for tokenA and tokenB.
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    /**
     * @dev Swaps an exact amount of tokens for ETH, supporting fee-on-transfer tokens.
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 tokenAmount,
        uint256 minETHAmount,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    // Returns the factory address.
    function factory() external pure returns (address);

    // Returns the address of WETH.
    function WETH() external pure returns (address);

    /**
     * @dev Adds liquidity for ETH and tokens.
     */
    function addLiquidityETH(
        address token,
        uint tokenDesired,
        uint tokenMin,
        uint ethMin,
        address to,
        uint deadline
    ) external payable returns (uint tokenAmount, uint ethAmount, uint liquidity);
}

contract SquaresAI is Context, IERC20, Ownable {
    string private constant _tokenName = "SquaresAI";
    string private constant _tokenSymbol = "SQUARES";
    uint8 private constant _tokenDecimals = 18;
    uint256 private constant _totalSupply = 100000000 * 10**_tokenDecimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _excludedAccounts; // Tracks excluded accounts for fees or limits.

    uint256 private constant _minSwapTokens = 10000 * 10**_tokenDecimals; // Minimum tokens required to trigger a swap.
    uint256 private _maxSwapTokens = 500000 * 10**_tokenDecimals; // Maximum tokens to swap at once.

    uint256 private _launchBlock;
    uint256 buyFeeRate = 30; // Buy transaction fee rate in percentage.
    uint256 sellFeeRate = 30; // Sell transaction fee rate in percentage.

    uint256 public maxTxValue = 500000 * 10**_tokenDecimals; // Maximum transaction value allowed.
    uint256 public maxWalletHoldings = 1000000 * 10**_tokenDecimals; // Maximum wallet balance allowed.

    IUniswapV2Router02 private _uniswapV2Router;
    address public uniswapV2Pair;
    address OperationalWallet; // Address for operational funds.
    address TeamWallet; // Address for team funds.
    address MarketingWallet; // Address for marketing funds.

    bool private _isTradingActive = false; // Indicates whether trading is active.

    /**
     * @dev Constructor initializes wallets and assigns the total token supply to the deployer.
     */
    constructor() {
        _balances[msg.sender] = _totalSupply;
        _excludedAccounts[msg.sender] = 1;
        _excludedAccounts[address(this)] = 1;

        OperationalWallet = 0x4F3447E56464A329bCF0FDfa8AE82Ba4E09cF9D8;

        TeamWallet = 0x72Bce0Da7bC5e3a596521B70F054fD342A02Eb96;
        
        MarketingWallet = 0x184Af822Dba5f8D9E5f628D31F0a14a4F130a422;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // Returns the name of the token.
    function name() public pure returns (string memory) {
        return _tokenName;
    }

    // Returns the symbol of the token.
    function symbol() public pure returns (string memory) {
        return _tokenSymbol;
    }

    // Returns the number of decimals used by the token.
    function decimals() public pure returns (uint8) {
        return _tokenDecimals;
    }

    // Returns the total supply of the token.
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns current buy and sell tax rates.
     */
    function currentFeeRates() external view returns (uint256 buyTax, uint256 sellTax) {
        buyTax = buyFeeRate;
        sellTax = sellFeeRate;
    }

    // Returns the balance of the specified account.
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // Transfers tokens to a specified recipient.
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(_msgSender(), recipient, amount);
        return true;
    }

    // Returns the remaining allowance for a spender from the owner.
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Approves a spender to transfer tokens on behalf of the caller.
    function approve(address spender, uint256 amount) public override returns (bool) {
        _setAllowance(_msgSender(), spender, amount);
        return true;
    }

    // Transfers tokens from a sender to a recipient using an allowance.
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

    // Internal function to set the allowance for a spender by the owner.
    function _setAllowance(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Enables trading by setting up the Uniswap pair and liquidity.
     */
    function enableTrading() external onlyOwner {
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
     * @dev Adds or removes an account from exclusion lists.
     */
    function excludeAccount(address account, uint256 value) external onlyOwner {
        _excludedAccounts[account] = value;
    }

    /**
     * @dev Disables transaction and wallet limits.
     */
    function removeLimits() external onlyOwner {
        maxTxValue = _totalSupply;
        maxWalletHoldings = _totalSupply;
    }

    /**
     * @dev Updates the buy and sell tax rates. New rates cannot exceed current ones.
     */
    function setTaxRates(uint256 newBuyTaxRate, uint256 newSellTaxRate) external onlyOwner {
        require(newBuyTaxRate <= buyFeeRate && newSellTaxRate <= sellFeeRate, "Tax cannot be increased");
        buyFeeRate = newBuyTaxRate;
        sellFeeRate = newSellTaxRate;
    }

    /**
     * @dev Internal function to handle token transfers with tax application.
     */
    function _processTransfer(address from, address to, uint256 amount, uint256 taxRate) private {
        uint256 taxAmount = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;

        _balances[from] -= amount;
        _balances[to] += transferAmount;
        _balances[address(this)] += taxAmount;

        emit Transfer(from, to, transferAmount);
    }

    /**
     * @dev Core transfer function that includes validation and fee processing.
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
                        _swapTokensForEther(contractTokenBalance);
                    }
                    taxRate = sellFeeRate;
                }
            }
        }
        _processTransfer(from, to, amount, taxRate);
    }

    /**
     * @dev Swaps tokens for ETH and allocates ETH to designated wallets.
     */
    function _swapTokensForEther(uint256 tokenAmount) private {
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
        uint256 _operationalWallet = (contractEthBalance * 4) / 100;
        uint256 _teamWallet = (contractEthBalance * 48) / 100;
        uint256 _marketingWallet = (contractEthBalance * 48) / 100;

        (bool success, ) = OperationalWallet.call{value: _operationalWallet}("");
        (success, ) = TeamWallet.call{value: _teamWallet}("");
        (success, ) = MarketingWallet.call{value: _marketingWallet}("");
        
        require(success, "Transfer failed");
    }

    /**
     * @dev Withdraws ETH from the contract to the owner's wallet.
     */
    function withdrawEther() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Rescue ETH failed");
    }

    /**
     * @dev Transfers remaining tokens in the contract to the owner.
     */
    function collectTokens() external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens to rescue");

        _processTransfer(address(this), owner(), contractTokenBalance, 0);
    }

    /**
     * @dev Allows the owner to manually swap a percentage of tokens for ETH.
     */
    function manualSwap(uint256 percent) external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 swapAmount = (percent * contractTokenBalance) / 100;
        _swapTokensForEther(swapAmount);
    }



    // Allows the contract to receive ETH.
    receive() external payable {}
}