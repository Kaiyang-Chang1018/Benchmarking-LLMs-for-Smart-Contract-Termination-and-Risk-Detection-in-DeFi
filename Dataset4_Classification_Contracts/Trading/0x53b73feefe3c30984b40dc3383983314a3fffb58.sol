/**
     Telegram: https://t.me/BlocklanceGigs
     Twitter: https://x.com/BlocklanceGigs
     Website/Dapp: https://blocklance.work
     Docs: https://blocklances-organization.gitbook.io/blocklance-v1
     Medium: https://medium.com/@blocklance

     Blocklance is the first Web3-powered freelance marketplace designed to revolutionize the global gig economy 
     by addressing the limitations of traditional platforms. Leveraging blockchain technology, 
     Blocklance offers freelancers and recruiters a decentralized platform that eliminates high fees, 
     ensures data privacy, and enhances accessibility for users worldwide. With wallet-based sign-ups, 
     industry-low fees of just 5%, and AI-powered multilingual tools, Blocklance fosters seamless global collaboration. 
     As a gateway to Web3, it not only empowers the freelance community but also paves the way for millions to enter the blockchain ecosystem

     Officially Incubated by Sentinel Incubator - https://sentinelincubator.com
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./UniswapV2Contracts.sol";

contract BLK is ERC20, Ownable, ReentrancyGuard {
    // Uniswap router and pair addresses
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    // Address where burned tokens are sent
    address public constant deadAddress = address(0xdead);

    // Wallets for fee distribution
    address public projectWallet;
    address public projectWalletTwo;
    address public incubatorWallet;
    address public referralWallet;

    // Swap and trading flags
    bool private swapping;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    bool public limitsInEffect = true;

    // Block number and timestamp when trading was enabled
    uint256 public tradingActiveBlock;
    uint256 public tradingActiveTimestamp;

    // Maximum transaction amount and wallet balance
    uint256 public maxTransactionAmount;
    uint256 public maxWallet;

    // Fee percentages (per 10,000 units, where 10,000 = 100%)
    uint256 public buyTotalFees;
    uint256 public buyFee;

    uint256 public sellTotalFees;
    uint256 public sellFee;

    // Tokens accumulated for fees
    uint256 public tokensForFees;

    // Swap back percentage threshold (in basis points, out of 10,000)
    uint256 public maxSwapBackPercent = 50; // 0.5%

    // Minimum amount of tokens to trigger swap back (0.01% of total supply)
    uint256 public swapTokensAtAmount;

    // Mappings for fee and transaction exclusions
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    // Automated market maker pairs
    mapping(address => bool) public automatedMarketMakerPairs;

    // Whitelist variables
    uint256 public whitelistStartTime;
    bool public whitelistActive = true;
    mapping(address => bool) public whitelistedAddresses;

    // Events for tracking state changes
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ProjectWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event ProjectWalletTwoUpdated(address indexed newWallet, address indexed oldWallet);
    event IncubatorWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event ReferralWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event TradingEnabled(uint256 blockNumber);
    event LimitsRemoved();
    event MaxTransactionAmountUpdated(uint256 newAmount);
    event MaxWalletUpdated(uint256 newAmount);
    event ExcludedFromMaxTransaction(address indexed account, bool isExcluded);
    event SwapEnabledUpdated(bool enabled);
    event BuyFeesUpdated(uint256 fee);
    event SellFeesUpdated(uint256 fee);
    event MaxSwapBackPercentUpdated(uint256 newPercent);
    event TokenSwap(uint256 tokensSwapped, uint256 ethReceived);
    event TokenSwapFailed(uint256 tokenAmount);
    event TokenSwapFailedWithReason(uint256 tokenAmount, string reason);
    event TokenSwapFailedWithData(uint256 tokenAmount, bytes data);
    event TransferFailed(address to, uint256 amount);
    event Whitelisted(address indexed account);

    // Custom Errors
    error TradingNotActive();
    error ExceedsMaxTransactionAmount();
    error ExceedsMaxWalletAmount();
    error MaxTransactionAmountTooLow();
    error MaxWalletTooLow();
    error CannotRemovePrimaryPair();
    error NewWalletIsZeroAddress();
    error CannotIncreaseFees();
    error TransferFromZeroAddress();
    error TransferToZeroAddress();
    error SwapFailed();
    error MaxSwapBackPercentTooHigh();

    // Deployer address
    address public immutable deployer;

    // Tax enablement flags
    bool public isProjectWalletTaxEnabled = true;
    bool public isProjectWalletTwoTaxEnabled = true;
    bool public isIncubatorWalletTaxEnabled = true;
    bool public isReferralWalletTaxEnabled = true;

    /**
     * @dev Constructor initializes the token and sets up Uniswap pair.
     * @param _router Address of the UniswapV2Router02.
     */
    constructor(address _router) ERC20("Blocklance", "BLK") {
        address _owner = _msgSender();
        deployer = _owner;

        uint256 totalSupply_ = 100_000_000 * (10 ** decimals());

        // Adjusted percentages per 10,000 units
        maxTransactionAmount = (totalSupply_ * 150) / 10_000; // 1.5% of total supply
        maxWallet = (totalSupply_ * 150) / 10_000; // 1.5% of total supply

        // Fee percentages (per 10,000 units, where 10,000 = 100%)
        buyFee = 2500; // 25%
        buyTotalFees = buyFee;

        sellFee = 3000; // 30%
        sellTotalFees = sellFee;

        // Set initial wallets
        projectWallet = address(0xaA334785e9cC08cF35C7FD3a7c84964649a150d3);
        projectWalletTwo = address(0x8637b1691A58CEb11F115843E1e8630EDebc584a);
        incubatorWallet = address(0x85dBe4ce3c809DAC17E4B1D32a5A2478038a3ae1);
        referralWallet = address(0x4f82b6Bda395C43A047dDc30CD6eDf7479A2C7Af);

        if (_router == address(0)) revert NewWalletIsZeroAddress();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);

        uniswapV2Router = _uniswapV2Router;

        // Exclude router from max transaction amount
        excludeFromMaxTransaction(address(_uniswapV2Router), true);

        // Create or get existing Uniswap pair
        address existingPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .getPair(address(this), _uniswapV2Router.WETH());
        if (existingPair != address(0)) {
            uniswapV2Pair = existingPair;
        } else {
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        // Set the pair as an AMM pair
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        // Exclude Uniswap pair from max transaction limits
        excludeFromMaxTransaction(uniswapV2Pair, true);

        // Exclude from fees and max transaction limits
        excludeFromFees(_owner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadAddress, true);

        excludeFromMaxTransaction(_owner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(deadAddress, true);

        // Set the minimum tokens to swap back (0.01% of total supply)
        swapTokensAtAmount = (totalSupply_ * 1) / 10_000; // 0.01%

        // Initialize whitelist
        whitelistActive = true;

        // Mint total supply to owner
        _mint(_owner, totalSupply_);
    }

    /**
     * @dev Enables trading and allows swaps.
     */
    function enableTrading() external onlyOwner {
        if (projectWallet == address(0)) revert NewWalletIsZeroAddress();
        if (projectWalletTwo == address(0)) revert NewWalletIsZeroAddress();
        if (incubatorWallet == address(0)) revert NewWalletIsZeroAddress();
        if (referralWallet == address(0)) revert NewWalletIsZeroAddress();
        tradingActive = true;
        swapEnabled = true;
        limitsInEffect = true;
        tradingActiveBlock = block.number;
        tradingActiveTimestamp = block.timestamp;
        whitelistStartTime = block.timestamp; // Start the whitelist period
        whitelistActive = true; // Ensure whitelist is active
        emit TradingEnabled(block.number);
    }

    /**
     * @dev Removes transaction and wallet limits.
     * @return True if successful.
     */
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        emit LimitsRemoved();
        return true;
    }

    /**
     * @dev Updates the maximum transaction amount.
     * @param newAmount The new maximum transaction amount.
     */
    function updateMaxTransactionAmount(uint256 newAmount) external onlyOwner {
        if (newAmount < (totalSupply() * 100) / 10_000) revert MaxTransactionAmountTooLow(); // Minimum 1%
        maxTransactionAmount = newAmount;
        emit MaxTransactionAmountUpdated(newAmount);
    }

    /**
     * @dev Updates the maximum wallet balance.
     * @param newAmount The new maximum wallet balance.
     */
    function updateMaxWallet(uint256 newAmount) external onlyOwner {
        if (newAmount < (totalSupply() * 100) / 10_000) revert MaxWalletTooLow(); // Minimum 1%
        maxWallet = newAmount;
        emit MaxWalletUpdated(newAmount);
    }

    /**
     * @dev Excludes or includes an account from the max transaction limit.
     * @param account The account to modify.
     * @param isExcluded Whether the account is excluded.
     */
    function excludeFromMaxTransaction(address account, bool isExcluded)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[account] = isExcluded;
        emit ExcludedFromMaxTransaction(account, isExcluded);
    }

    /**
     * @dev Enables or disables the swap mechanism.
     * @param enabled Whether swapping is enabled.
     */
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
        emit SwapEnabledUpdated(enabled);
    }

    /**
     * @dev Excludes or includes an account from fees.
     * @param account The account to modify.
     * @param excluded Whether the account is excluded.
     */
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    /**
     * @dev Sets an address as an automated market maker pair.
     * @param pair The address to set.
     * @param value Whether it is an AMM pair.
     */
    function setAutomatedMarketMakerPair(address pair, bool value)
        external
        onlyOwner
    {
        if (pair == uniswapV2Pair) revert CannotRemovePrimaryPair();
        _setAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev Internal function to set an AMM pair.
     * @param pair The address to set.
     * @param value Whether it is an AMM pair.
     */
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev Updates the project wallet address.
     * @param newWallet The new wallet address.
     */
    function updateProjectWallet(address newWallet) external onlyOwner {
        if (newWallet == address(0)) revert NewWalletIsZeroAddress();
        emit ProjectWalletUpdated(newWallet, projectWallet);
        projectWallet = newWallet;
    }

    /**
     * @dev Updates the project wallet two address.
     * @param newWallet The new wallet address.
     */
    function updateProjectWalletTwo(address newWallet) external onlyOwner {
        if (newWallet == address(0)) revert NewWalletIsZeroAddress();
        emit ProjectWalletTwoUpdated(newWallet, projectWalletTwo);
        projectWalletTwo = newWallet;
    }

    /**
     * @dev Updates the incubator wallet address.
     * @param newWallet The new wallet address.
     */
    function updateIncubatorWallet(address newWallet) external onlyOwner {
        if (newWallet == address(0)) revert NewWalletIsZeroAddress();
        emit IncubatorWalletUpdated(newWallet, incubatorWallet);
        incubatorWallet = newWallet;
    }

    /**
     * @dev Updates the referral wallet address.
     * @param newWallet The new wallet address.
     */
    function updateReferralWallet(address newWallet) external onlyOwner {
        if (newWallet == address(0)) revert NewWalletIsZeroAddress();
        emit ReferralWalletUpdated(newWallet, referralWallet);
        referralWallet = newWallet;
    }

    /**
     * @dev Updates the max swap back percentage.
     * @param newPercent The new max swap back percentage (in basis points, out of 10,000).
     */
    function updateMaxSwapBackPercent(uint256 newPercent) external onlyOwner {
        if (newPercent > 1000) revert MaxSwapBackPercentTooHigh(); // Cannot set above 10%
        maxSwapBackPercent = newPercent;
        emit MaxSwapBackPercentUpdated(newPercent);
    }

    /**
     * @dev Checks if an account is excluded from fees.
     * @param account The account to check.
     * @return True if excluded, false otherwise.
     */
    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * @dev Updates the buy fees.
     * @param newFee The new buy fee percentage (per 10,000 units).
     */
    function updateBuyFees(uint256 newFee) external onlyOwner {
        if (newFee > buyFee) revert CannotIncreaseFees();
        buyFee = newFee;
        buyTotalFees = buyFee;
        emit BuyFeesUpdated(buyFee);
    }

    /**
     * @dev Updates the sell fees.
     * @param newFee The new sell fee percentage (per 10,000 units).
     */
    function updateSellFees(uint256 newFee) external onlyOwner {
        if (newFee > sellFee) revert CannotIncreaseFees();
        sellFee = newFee;
        sellTotalFees = sellFee;
        emit SellFeesUpdated(sellFee);
    }

    /**
     * @dev Whitelists or removes addresses from the whitelist.
     * @param wallets The array of addresses to modify.
     * @param isWhitelisted Whether the addresses are whitelisted.
     */
    function whitelistWallets(address[] calldata wallets, bool isWhitelisted) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            whitelistedAddresses[wallets[i]] = isWhitelisted;
            emit Whitelisted(wallets[i]);
        }
    }

    /**
     * @dev Manually ends the whitelist period.
     */
    function shutOffWhitelist() external onlyOwner {
        require(whitelistActive, "Whitelist not active");
        whitelistActive = false;
    }

    /**
     * @dev Revokes taxes to the project wallet. Can only be called once by the deployer.
     */
    function revokeProjectWalletTax() external {
        require(msg.sender == deployer, "Only deployer can call");
        require(isProjectWalletTaxEnabled, "Taxes already revoked");
        isProjectWalletTaxEnabled = false;
    }

    /**
     * @dev Revokes taxes to the project wallet two. Can only be called once by the deployer.
     */
    function revokeProjectWalletTwoTax() external {
        require(msg.sender == deployer, "Only deployer can call");
        require(isProjectWalletTwoTaxEnabled, "Taxes already revoked");
        isProjectWalletTwoTaxEnabled = false;
    }

    /**
     * @dev Revokes taxes to the incubator wallet. Can only be called once by the deployer.
     */
    function revokeIncubatorWalletTax() external {
        require(msg.sender == deployer, "Only deployer can call");
        require(isIncubatorWalletTaxEnabled, "Taxes already revoked");
        isIncubatorWalletTaxEnabled = false;
    }

    /**
     * @dev Revokes taxes to the referral wallet. Can only be called once by the deployer.
     */
    function revokeReferralWalletTax() external {
        require(msg.sender == deployer, "Only deployer can call");
        require(isReferralWalletTaxEnabled, "Taxes already revoked");
        isReferralWalletTaxEnabled = false;
    }

    /**
     * @dev Internal transfer function with fee logic and whitelist enforcement.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to transfer.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(0)) revert TransferFromZeroAddress();
        if (to == address(0)) revert TransferToZeroAddress();

        // Check if trading is active
        if (!tradingActive) {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                revert TradingNotActive();
            }
        }

        // Early return if amount is zero
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        // Limits and whitelist checks
        if (limitsInEffect && !swapping) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != deadAddress
            ) {
                // Determine if we are in the whitelist period (first 5 minutes)
                bool isInWhitelistPeriod = whitelistActive && (block.timestamp < whitelistStartTime + 5 minutes);

                uint256 currentMaxTransactionAmount;
                uint256 currentMaxWallet;

                if (isInWhitelistPeriod) {
                    currentMaxTransactionAmount = (totalSupply() * 40) / 10_000; // 0.4%
                    currentMaxWallet = (totalSupply() * 40) / 10_000; // 0.4%
                } else {
                    currentMaxTransactionAmount = maxTransactionAmount; // 1.5%
                    currentMaxWallet = maxWallet; // 1.5%
                    // Whitelist period has ended
                    if (whitelistActive) {
                        whitelistActive = false;
                    }
                }

                // Whitelist enforcement during whitelist period
                if (isInWhitelistPeriod) {
                    // Enforce whitelist checks for all transactions
                    if (automatedMarketMakerPairs[from]) {
                        // Buying: Only whitelisted addresses can buy
                        require(
                            whitelistedAddresses[to],
                            "Not whitelisted during whitelist period"
                        );
                    } else if (automatedMarketMakerPairs[to]) {
                        // Selling: Only whitelisted addresses can sell
                        require(
                            whitelistedAddresses[from],
                            "Not whitelisted during whitelist period"
                        );
                    } else {
                        // Transfers between wallets
                        require(
                            whitelistedAddresses[from] && whitelistedAddresses[to],
                            "Both sender and recipient must be whitelisted during whitelist period"
                        );
                    }
                }

                // Max transaction and wallet limits
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    // Buy transaction
                    if (amount > currentMaxTransactionAmount)
                        revert ExceedsMaxTransactionAmount();
                    if (balanceOf(to) + amount > currentMaxWallet)
                        revert ExceedsMaxWalletAmount();
                } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    // Sell transaction
                    if (amount > currentMaxTransactionAmount)
                        revert ExceedsMaxTransactionAmount();
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    // Regular transfer
                    if (balanceOf(to) + amount > currentMaxWallet)
                        revert ExceedsMaxWalletAmount();
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        // Check if we should perform a swap back
        bool shouldSwapBack = canSwap &&
            swapEnabled &&
            !swapping &&
            automatedMarketMakerPairs[to] && // Sell transaction
            from != address(this) &&
            !_isExcludedFromFees[from];

        if (shouldSwapBack) {
            swapping = true;
            swapBack(amount);
            swapping = false;
        }

        bool takeFee = !swapping;

        // If any account is excluded from fee, remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        // Calculate fees if applicable
        if (takeFee) {
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                // Sell transaction
                fees = (amount * sellTotalFees) / 10_000; // Fees are per 10,000 units
                tokensForFees += fees;
            } else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                // Buy transaction
                fees = (amount * buyTotalFees) / 10_000; // Fees are per 10,000 units
                tokensForFees += fees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        // Perform the actual token transfer
        super._transfer(from, to, amount);
    }

    /**
     * @dev Swaps tokens for ETH using Uniswap.
     * @param tokenAmount The amount of tokens to swap.
     * @return success True if the swap was successful.
     */
    function swapTokensForEth(uint256 tokenAmount) private returns (bool success) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint256 initialETHBalance = address(this).balance;

        try
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // Accept any amount of ETH
                path,
                address(this),
                block.timestamp
            )
        {
            uint256 ethReceived = address(this).balance - initialETHBalance;
            emit TokenSwap(tokenAmount, ethReceived);
            success = true;
        } catch Error(string memory reason) {
            emit TokenSwapFailedWithReason(tokenAmount, reason);
            success = false;
        } catch (bytes memory data) {
            emit TokenSwapFailedWithData(tokenAmount, data);
            success = false;
        }
    }

    /**
     * @dev Swaps back tokens for ETH and distributes to wallets.
     * @param sellAmount The amount of tokens being sold in the current transaction.
     */
    function swapBack(uint256 sellAmount) private nonReentrant {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap = tokensForFees;

        if (contractBalance == 0 || tokensToSwap == 0) {
            return;
        }

        // Calculate maximum swap amount based on maxSwapBackPercent
        uint256 maxSwapAmount = (totalSupply() * maxSwapBackPercent) / 10_000;

        // Determine amount to swap (small amount to avoid large dumps)
        uint256 amountToSwap = sellAmount;

        if (amountToSwap > maxSwapAmount) {
            amountToSwap = maxSwapAmount;
        }

        if (amountToSwap > tokensToSwap) {
            amountToSwap = tokensToSwap;
        }

        if (amountToSwap > contractBalance) {
            amountToSwap = contractBalance;
        }

        // Ensure amount to swap meets minimum threshold
        if (amountToSwap < swapTokensAtAmount) {
            return;
        }

        // Swap tokens for ETH
        bool success = swapTokensForEth(amountToSwap);

        if (success) {
            // Decrement tokensForFees
            tokensForFees -= amountToSwap;

            // Distribute ETH to wallets
            uint256 ethBalance = address(this).balance;

            if (ethBalance > 0) {
                distributeEth(ethBalance);
            }
        } else {
            // Handle swap failure if necessary
            return;
        }
    }

    /**
     * @dev Distributes ETH to the wallets based on enabled taxes.
     * @param ethBalance The total ETH balance to distribute.
     */
    function distributeEth(uint256 ethBalance) private {
        if (ethBalance == 0) {
            return;
        }

        // Define percentages per 10,000 units (where 10,000 = 100%)
        uint256 totalPercentage = 0;
        uint256 incubatorWalletPercentage = 0;
        uint256 referralWalletPercentage = 0;
        uint256 projectWalletPercentage = 0;
        uint256 projectWalletTwoPercentage = 0;

        if (isIncubatorWalletTaxEnabled) {
            incubatorWalletPercentage = 1750; // 17.5%
            totalPercentage += incubatorWalletPercentage;
        }

        if (isReferralWalletTaxEnabled) {
            referralWalletPercentage = 500; // 5%
            totalPercentage += referralWalletPercentage;
        }

        if (isProjectWalletTaxEnabled) {
            projectWalletPercentage = 3875; // 38.75%
            totalPercentage += projectWalletPercentage;
        }

        if (isProjectWalletTwoTaxEnabled) {
            projectWalletTwoPercentage = 3875; // 38.75%
            totalPercentage += projectWalletTwoPercentage;
        }

        // Check for division by zero
        if (totalPercentage == 0) {
            // No wallets are enabled, nothing to distribute
            return;
        }

        // Distribute ETH based on enabled wallets
        uint256 totalDistributed = 0;

        if (incubatorWalletPercentage > 0) {
            uint256 ethForIncubator = (ethBalance * incubatorWalletPercentage) / totalPercentage;
            totalDistributed += ethForIncubator;

            // Distribute ETH to incubator wallet
            (bool successIncubator, ) = incubatorWallet.call{value: ethForIncubator}("");
            if (!successIncubator) {
                emit TransferFailed(incubatorWallet, ethForIncubator);
            }
        }

        if (referralWalletPercentage > 0) {
            uint256 ethForReferral = (ethBalance * referralWalletPercentage) / totalPercentage;
            totalDistributed += ethForReferral;

            // Distribute ETH to referral wallet
            (bool successReferral, ) = referralWallet.call{value: ethForReferral}("");
            if (!successReferral) {
                emit TransferFailed(referralWallet, ethForReferral);
            }
        }

        if (projectWalletPercentage > 0) {
            uint256 ethForProject = (ethBalance * projectWalletPercentage) / totalPercentage;
            totalDistributed += ethForProject;

            // Distribute ETH to project wallet
            (bool successProject, ) = projectWallet.call{value: ethForProject}("");
            if (!successProject) {
                emit TransferFailed(projectWallet, ethForProject);
            }
        }

        if (projectWalletTwoPercentage > 0) {
            uint256 ethForProjectTwo = (ethBalance * projectWalletTwoPercentage) / totalPercentage;
            totalDistributed += ethForProjectTwo;

            // Distribute ETH to project wallet two
            (bool successProjectTwo, ) = projectWalletTwo.call{value: ethForProjectTwo}("");
            if (!successProjectTwo) {
                emit TransferFailed(projectWalletTwo, ethForProjectTwo);
            }
        }

        // Ensure the total distribution does not exceed balance
        require(totalDistributed <= ethBalance, "Insufficient ETH balance for distribution");
    }

    /**
     * @dev Allows the owner to rescue ETH from the contract.
     */
    function rescueETH() external onlyOwner nonReentrant {
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance == 0) revert SwapFailed();

        (bool success, ) = owner().call{value: contractETHBalance}("");
        if (!success) revert SwapFailed();
    }

    /**
     * @dev Allows the owner to rescue any ERC20 tokens, including the contract's own tokens.
     * @param tokenAddress The address of the token to rescue.
     */
    function rescueTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 contractTokenBalance = token.balanceOf(address(this));
        if (contractTokenBalance == 0) revert SwapFailed();
        token.transfer(owner(), contractTokenBalance);
    }

    // Receive function to accept ETH
    receive() external payable {}

    // Fallback function
    fallback() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

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
pragma solidity ^0.8.27;

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
pragma solidity ^0.8.27;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

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
pragma solidity ^0.8.27;

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
pragma solidity ^0.8.27;

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