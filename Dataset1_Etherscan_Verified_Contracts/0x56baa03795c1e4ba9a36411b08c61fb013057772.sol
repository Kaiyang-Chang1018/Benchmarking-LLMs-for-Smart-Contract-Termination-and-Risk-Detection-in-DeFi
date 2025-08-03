// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Context.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), 'ERC20: mint to the zero address');
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), 'ERC20: burn from the zero address');
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 *Telegram: https://t.me/VoteDonnaTramp
 * Twitter: https://x.com/VoteDonnaTramp
 * Website: https://donnatramp.com/
 */

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Uniswap.sol";

contract DonnaTramp is ERC20, Ownable, ReentrancyGuard {
    // Uniswap router and pair
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    // Dead address for token burns
    address public constant deadAddress = address(0xdead);

    // Wallet addresses for fee distribution
    address public trampWallet;
    address public devWallet;

    // Flags for trading and swapping
    bool private swapping;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    bool public limitsInEffect = true;

    // Block number when trading was enabled
    uint256 public tradingActiveBlock;

    // Maximum transaction amount and wallet balance
    uint256 public maxTransactionAmount;
    uint256 public maxWallet;

    // Fee percentages
    uint256 public buyTotalFees;
    uint256 public buyFee;

    uint256 public sellTotalFees;
    uint256 public sellFee;

    // Tokens accumulated for fees
    uint256 public tokensForFees;

    // Mappings for fee and transaction exclusions
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    // Automated market maker pairs
    mapping(address => bool) public automatedMarketMakerPairs;

    // Events for tracking state changes
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event TrampWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event DevWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event TradingEnabled(uint256 blockNumber);
    event LimitsRemoved();
    event MaxTransactionAmountUpdated(uint256 newAmount);
    event MaxWalletUpdated(uint256 newAmount);
    event ExcludedFromMaxTransaction(address indexed account, bool isExcluded);
    event SwapEnabledUpdated(bool enabled);
    event BuyFeesUpdated(uint256 fee);
    event SellFeesUpdated(uint256 fee);
    event TokenSwap(uint256 tokensSwapped, uint256 ethReceived);
    event TokenSwapFailed(uint256 tokenAmount);
    event TokenSwapFailedWithReason(uint256 tokenAmount, string reason);
    event TokenSwapFailedWithData(uint256 tokenAmount, bytes data);


    constructor(address _router) ERC20("Donna Tramp", "TRAMP") {
        address _owner = _msgSender();

        uint256 totalSupply_ = 420_690_000 * (10 ** decimals());

        maxTransactionAmount = totalSupply_ * 2 / 100;
        maxWallet = totalSupply_ * 2 / 100;

        buyFee = 30; // 30% buy fee - Once fee is reduced, it cannot be raised again!
        buyTotalFees = buyFee;

        sellFee = 30; // 30% sell fee - Once fee is reduced, it cannot be raised again!
        sellTotalFees = sellFee;

        // Set initial trampWallet and devWallet to specific addresses
        trampWallet = address(0x48A853cDA0525B8779d3F652D5152C65B876082B);
        devWallet = address(0xE886Bb9dB058B5631Cfc3ea7945bEB33a503f238);

        require(_router != address(0), "Router address cannot be zero");

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);

        uniswapV2Router = _uniswapV2Router;

        excludeFromMaxTransaction(address(_uniswapV2Router), true);

        // Create or get existing Uniswap pair for this token
        address existingPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .getPair(address(this), _uniswapV2Router.WETH());
        if (existingPair != address(0)) {
            uniswapV2Pair = existingPair;
        } else {
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        // Exclude from fees and max transaction limits
        excludeFromFees(_owner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadAddress, true);

        excludeFromMaxTransaction(_owner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(deadAddress, true);

        // Mint total supply to the owner
        _mint(_owner, totalSupply_);
    }

    /**
     * @dev Enables trading and allows swaps
     */
    function enableTrading() external onlyOwner {
        require(trampWallet != address(0), "Tramp wallet not set");
        require(devWallet != address(0), "Dev wallet not set");
        tradingActive = true;
        swapEnabled = true;
        limitsInEffect = true; // Ensure limits are in effect when trading is enabled
        tradingActiveBlock = block.number;
        emit TradingEnabled(block.number);
    }

    /**
     * @dev Removes transaction and wallet limits
     */
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        emit LimitsRemoved();
        return true;
    }

    /**
     * @dev Updates the maximum transaction amount
     * @param newAmount The new maximum transaction amount
     */
    function updateMaxTransactionAmount(uint256 newAmount) external onlyOwner {
        require(
            newAmount >= (totalSupply() * 1) / 100,
            "Cannot set maxTransactionAmount lower than 1%"
        );
        maxTransactionAmount = newAmount;
        emit MaxTransactionAmountUpdated(newAmount);
    }

    /**
     * @dev Updates the maximum wallet balance
     * @param newAmount The new maximum wallet balance
     */
    function updateMaxWallet(uint256 newAmount) external onlyOwner {
        require(
            newAmount >= (totalSupply() * 1) / 100,
            "Cannot set maxWallet lower than 1%"
        );
        maxWallet = newAmount;
        emit MaxWalletUpdated(newAmount);
    }

    /**
     * @dev Excludes or includes an account from the max transaction limit
     * @param account The account to modify
     * @param isExcluded Whether the account is excluded
     */
    function excludeFromMaxTransaction(address account, bool isExcluded)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[account] = isExcluded;
        emit ExcludedFromMaxTransaction(account, isExcluded);
    }

    /**
     * @dev Enables or disables the swap mechanism
     * @param enabled Whether swapping is enabled
     */
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
        emit SwapEnabledUpdated(enabled);
    }

    /**
     * @dev Excludes or includes an account from fees
     * @param account The account to modify
     * @param excluded Whether the account is excluded
     */
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    /**
     * @dev Sets an address as an automated market maker pair
     * @param pair The address to set
     * @param value Whether it is an AMM pair
     */
    function setAutomatedMarketMakerPair(address pair, bool value)
        external
        onlyOwner
    {
        require(pair != uniswapV2Pair, "Cannot remove primary pair");
        _setAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev Internal function to set an AMM pair
     * @param pair The address to set
     * @param value Whether it is an AMM pair
     */
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev Updates the tramp wallet address
     * @param newWallet The new wallet address
     */
    function updateTrampWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            "New wallet cannot be the zero address"
        );
        emit TrampWalletUpdated(newWallet, trampWallet);
        trampWallet = newWallet;
    }

    /**
     * @dev Updates the dev wallet address
     * @param newWallet The new wallet address
     */
    function updateDevWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            "New wallet cannot be the zero address"
        );
        emit DevWalletUpdated(newWallet, devWallet);
        devWallet = newWallet;
    }

    /**
     * @dev Checks if an account is excluded from fees
     * @param account The account to check
     * @return True if excluded, false otherwise
     */
    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * @dev Updates the buy fees
     * @param newFee The new buy fee percentage
     */
    function updateBuyFees(uint256 newFee) external onlyOwner {
        require(newFee <= 30, "Fee cannot exceed 30%");
        require(newFee <= buyFee, "Cannot increase fees");
        buyFee = newFee;
        buyTotalFees = buyFee;
        emit BuyFeesUpdated(buyFee);
    }

    /**
     * @dev Updates the sell fees
     * @param newFee The new sell fee percentage
     */
    function updateSellFees(uint256 newFee) external onlyOwner {
        require(newFee <= 30, "Fee cannot exceed 30%");
        require(newFee <= sellFee, "Cannot increase fees");
        sellFee = newFee;
        sellTotalFees = sellFee;
        emit SellFeesUpdated(sellFee);
    }

    /**
     * @dev Internal transfer function with fee logic
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");

        uint256 fromBalance = balanceOf(from);
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        // Prevent trading before it's enabled
        if (!tradingActive) {
            require(
                _isExcludedFromFees[from] || _isExcludedFromFees[to],
                "Trading is not active."
            );
        }

        // Early return if amount is zero
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        // Limits and transaction checks
        if (limitsInEffect && !swapping) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != deadAddress &&
                !_isExcludedMaxTransactionAmount[from] &&
                !_isExcludedMaxTransactionAmount[to]
            ) {
                // Buy transaction
                if (automatedMarketMakerPairs[from]) {
                    require(
                        amount <= maxTransactionAmount,
                        "Buy transfer amount exceeds the maximum allowed."
                    );
                    require(
                        balanceOf(to) + amount <= maxWallet,
                        "Recipient exceeds maximum wallet token amount."
                    );
                }
                // Sell transaction
                else if (automatedMarketMakerPairs[to]) {
                    require(
                        amount <= maxTransactionAmount,
                        "Sell transfer amount exceeds the maximum allowed."
                    );
                }
                // Regular transfer
                else {
                    require(
                        balanceOf(to) + amount <= maxWallet,
                        "Recipient exceeds maximum wallet token amount."
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= tokensForFees;

        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

        // If any account is excluded from fee, remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            // On sell
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                fees = (amount * sellTotalFees) / 100;
                tokensForFees += fees;
            }
            // On buy
            else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                fees = (amount * buyTotalFees) / 100;
                tokensForFees += fees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    /**
     * @dev Swaps tokens for ETH using Uniswap
     * @param tokenAmount The amount of tokens to swap
     */
    function swapTokensForEth(uint256 tokenAmount) private {
    // Generate Uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

    // Approve token transfer to cover all possible scenarios
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // Attempt the swap and handle failures
    try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0, // Accept any amount of ETH
        path,
        address(this),
        block.timestamp
    ) {
        emit TokenSwap(tokenAmount, address(this).balance);
    } catch Error(string memory reason) {
        // Handle known errors with reason
        emit TokenSwapFailedWithReason(tokenAmount, reason);
        revert(reason);
    } catch (bytes memory lowLevelData) {
        // Handle unknown errors
        emit TokenSwapFailedWithData(tokenAmount, lowLevelData);
        revert("Swap failed due to an unknown error");
    }
}

    /**
     * @dev Swaps back tokens for ETH and distributes to wallets
     */
    function swapBack() private nonReentrant {
    swapping = true;

    uint256 contractBalance = balanceOf(address(this));
    uint256 tokensToSwap = tokensForFees;

    if (contractBalance == 0 || tokensToSwap == 0) {
        swapping = false;
        return;
    }

    if (tokensToSwap > (totalSupply() * 2) / 1000) {
        tokensToSwap = (totalSupply() * 2) / 1000; // Cap at 0.2% of total supply
    }

    uint256 initialETHBalance = address(this).balance;

    // Attempt to swap tokens for ETH
    swapTokensForEth(tokensToSwap);

    uint256 ethBalance = address(this).balance - initialETHBalance;

    // Only reduce tokensForFees if swap was successful
    tokensForFees -= tokensToSwap;

    if (ethBalance > 0) {
        uint256 ethForDev = (ethBalance * 20) / 100; // 20% to dev wallet
        uint256 ethForTramp = ethBalance - ethForDev; // Remaining 80% to tramp wallet

        // Transfer ETH to dev wallet
        if (ethForDev > 0) {
            (bool successDev, ) = devWallet.call{value: ethForDev, gas: 30000}("");
            require(successDev, "Failed to send ETH to dev wallet");
        }

        // Transfer ETH to tramp wallet
        if (ethForTramp > 0) {
            (bool successTramp, ) = trampWallet.call{value: ethForTramp, gas: 30000}("");
            require(successTramp, "Failed to send ETH to tramp wallet");
        }
    }

    swapping = false;
}

    /**
     * @dev Allows the owner to rescue ETH from the contract
     */
    function rescueETH() external onlyOwner nonReentrant {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "No ETH to rescue");

        (bool success, ) = owner().call{value: contractETHBalance}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev Allows the owner to rescue any ERC20 tokens, including the contract's own tokens.
     * @param tokenAddress The address of the token to rescue.
     */
    function rescueTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 contractTokenBalance = token.balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens in contract");
        token.transfer(owner(), contractTokenBalance);
    }

    // Receive function to accept ETH
    receive() external payable {}

    // Fallback function
    fallback() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// IUniswapV2Pair Interface
interface IUniswapV2Pair {
    // Events
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    
    // Functions
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

// IUniswapV2Factory Interface
interface IUniswapV2Factory {
    // Events
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    
    // Functions
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// IUniswapV2Router01 Interface
interface IUniswapV2Router01 {
    // Functions
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    // Liquidity functions
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
    function removeLiquidity(
        address tokenA,
        address tokenB, 
        uint liquidity, 
        uint amountAMin, 
        uint amountBMin, 
        address to, 
        uint deadline
    ) external returns (uint amountA, uint amountB);
    
    function removeLiquidityETH(
        address token, 
        uint liquidity, 
        uint amountTokenMin, 
        uint amountETHMin, 
        address to, 
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    
    function removeLiquidityWithPermit(
        address tokenA, 
        address tokenB, 
        uint liquidity, 
        uint amountAMin, 
        uint amountBMin, 
        address to, 
        uint deadline, 
        bool approveMax, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint amountA, uint amountB);
    
    function removeLiquidityETHWithPermit(
        address token, 
        uint liquidity, 
        uint amountTokenMin, 
        uint amountETHMin, 
        address to, 
        uint deadline, 
        bool approveMax, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint amountETH);
    
    // Swap functions
    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapTokensForExactTokens(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    
    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    
    // Utility functions
    function quote(
        uint amountA, 
        uint reserveA, 
        uint reserveB
    ) external pure returns (uint amountB);
    
    function getAmountOut(
        uint amountIn, 
        uint reserveIn, 
        uint reserveOut
    ) external pure returns (uint amountOut);
    
    function getAmountIn(
        uint amountOut, 
        uint reserveIn, 
        uint reserveOut
    ) external pure returns (uint amountIn);
    
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    
    function getAmountsIn(
        uint amountOut, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

// IUniswapV2Router02 Interface
interface IUniswapV2Router02 is IUniswapV2Router01 {
    // Additional swap functions supporting fee-on-transfer tokens
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, 
        uint liquidity, 
        uint amountTokenMin, 
        uint amountETHMin, 
        address to, 
        uint deadline
    ) external returns (uint amountETH);
    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token, 
        uint liquidity, 
        uint amountTokenMin, 
        uint amountETHMin, 
        address to, 
        uint deadline, 
        bool approveMax, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint amountETH);
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable;
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external;
}