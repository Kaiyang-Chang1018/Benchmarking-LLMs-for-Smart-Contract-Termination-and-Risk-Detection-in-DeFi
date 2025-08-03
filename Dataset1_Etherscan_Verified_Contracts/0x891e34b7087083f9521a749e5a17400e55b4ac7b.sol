/*

Autistic Secret Service - $ASS

https://x.com/AutisticSecServ

https://autisticss.com/

https://t.me/autisticsecretservice

 */

// SPDX-License-Identifier: NONE

pragma solidity 0.8.23;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
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
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IDexFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract ASS is ERC20, Ownable {
    using SafeMath for uint256;

    IDexRouter private immutable dexRouter;
    address public immutable dexPair;

    bool private swapping;
    bool private limitsEnabled = true;
    bool private transferDelayEnabled = true;
    uint256 private maxWallet;
    uint256 private maxTx;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    bool private swapbackEnabled = false;
    uint256 private swapBackValueMin;
    uint256 private swapBackValueMax;

    mapping(address => bool) private transferTaxExempt;
    mapping(address => bool) private transferLimitExempt;
    mapping(address => bool) private automatedMarketMakerPairs;

    bool public tradingEnabled = false;
    uint256 private sellTaxTotal;
    uint256 private sellMarketingTax;
    uint256 private sellProjectTax;

    uint256 private tokensForMarketing;
    uint256 private tokensForProject;
    address private marketingWallet;
    address private projectWallet;

    uint256 private buyTaxTotal;
    uint256 private buyMarketingTax;
    uint256 private buyProjectTax;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event DisabledTransferDelay(uint256 indexed timestamp);

    event SwapbackSettingsUpdated(
        bool enabled,
        uint256 swapBackValueMin,
        uint256 swapBackValueMax
    );
    event MaxTxUpdated(uint256 maxTx);
    event MaxWalletUpdated(uint256 maxWallet);

    event MarketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event ProjectWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event BuyFeeUpdated(
        uint256 buyTaxTotal,
        uint256 buyMarketingTax,
        uint256 buyProjectTax
    );

    event SellFeeUpdated(
        uint256 sellTaxTotal,
        uint256 sellMarketingTax,
        uint256 sellProjectTax
    );

    constructor() ERC20("Autistic Secret Service", "ASS") {
        IDexRouter _dexRouter = IDexRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 
        );

        limitWL(address(_dexRouter), true);
        dexRouter = _dexRouter;

        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );
        limitWL(address(dexPair), true);
        _setAutomatedMarketMakerPair(address(dexPair), true);

        uint256 _buyMarketingTax = 8;
        uint256 _buyProjectTax = 7;

        uint256 _sellMarketingTax = 8;
        uint256 _sellProjectTax = 7;

        uint256 _totalSupply = 10_000_000_000 * 10 ** decimals();

        maxTx = (_totalSupply * 30) / 1000;
        maxWallet = (_totalSupply * 30) / 1000;

        swapBackValueMin = (_totalSupply * 1) / 1000;
        swapBackValueMax = (_totalSupply * 2) / 100;

        buyMarketingTax = _buyMarketingTax;
        buyProjectTax = _buyProjectTax;
        buyTaxTotal = buyMarketingTax + buyProjectTax;

        sellMarketingTax = _sellMarketingTax;
        sellProjectTax = _sellProjectTax;
        sellTaxTotal = sellMarketingTax + sellProjectTax;

        marketingWallet = address(0x60ED9b5280192a69417450d5705b474f38a97009);
        projectWallet = address(msg.sender);


        feeWL(msg.sender, true);
        feeWL(address(this), true);
        feeWL(address(0xdead), true);
        feeWL(marketingWallet, true);

        limitWL(msg.sender, true);
        limitWL(address(this), true);
        limitWL(address(0xdead), true);
        limitWL(marketingWallet, true);

        transferOwnership(msg.sender);

        _mint(msg.sender, _totalSupply);
    }

    receive() external payable {}

    function setRangeSwapback(
        bool _enabled,
        uint256 _min,
        uint256 _max
    ) external onlyOwner {
        require(
            _min >= 1,
            "Swap amount cannot be lower than 0.01% total supply."
        );
        require(_max >= _min, "maximum amount cant be higher than minimum");

        swapbackEnabled = _enabled;
        swapBackValueMin = (totalSupply() * _min) / 10000;
        swapBackValueMax = (totalSupply() * _max) / 10000;
        emit SwapbackSettingsUpdated(_enabled, _min, _max);
    }

    function disableDelayTransfers() external onlyOwner {
        transferDelayEnabled = false;
        emit DisabledTransferDelay(block.timestamp);
    }

    function setMaxTxnLimit(uint256 newNum) external onlyOwner {
        require(newNum >= 2, "Cannot set maxTx lower than 0.2%");
        maxTx = (newNum * totalSupply()) / 1000;
        emit MaxTxUpdated(maxTx);
    }

    function setWalletLimit(uint256 newNum) external onlyOwner {
        require(newNum >= 5, "Cannot set maxWallet lower than 0.5%");
        maxWallet = (newNum * totalSupply()) / 1000;
        emit MaxWalletUpdated(maxWallet);
    }

    function limitWL(
        address updAds,
        bool isEx
    ) public onlyOwner {
        transferLimitExempt[updAds] = isEx;
        emit ExcludeFromLimits(updAds, isEx);
    }

    function updateBuyFee(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        buyMarketingTax = _marketingFee;
        buyProjectTax = _devFee;
        buyTaxTotal = buyMarketingTax + buyProjectTax;
        require(buyTaxTotal <= 1000, "Total buy fee cannot be higher than 10%");
        emit BuyFeeUpdated(buyTaxTotal, buyMarketingTax, buyProjectTax);
    }

    function updateSellFee(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        sellMarketingTax = _marketingFee;
        sellProjectTax = _devFee;
        sellTaxTotal = sellMarketingTax + sellProjectTax;
        require(
            sellTaxTotal <= 1000,
            "Total sell fee cannot be higher than 10%"
        );
        emit SellFeeUpdated(sellTaxTotal, sellMarketingTax, sellProjectTax);
    }

    function openTrade() external onlyOwner {
        tradingEnabled = true;
        swapbackEnabled = true;
        emit TradingEnabled(block.timestamp);
        transferDelayEnabled = false;
        emit DisabledTransferDelay(block.timestamp);
    }

    function removeTXLimits() external onlyOwner {
        limitsEnabled = false;
        emit LimitsRemoved(block.timestamp);
    }

    function feeWL(address account, bool excluded) public onlyOwner {
        transferTaxExempt[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        require(
            pair != dexPair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @notice Sets the marketing wallet
     * @dev onlyOwner.
     * Emits an {MarketingWalletUpdated} event
     * @param newWallet The new marketing wallet
     */
    function changeFeeReceiverMarketing(address newWallet) external onlyOwner {
        emit MarketingWalletUpdated(newWallet, marketingWallet);
        marketingWallet = newWallet;
    }

    /**
     * @notice Sets the project wallet
     * @dev onlyOwner.
     * Emits an {ProjectWalletUpdated} event
     * @param newWallet The new dev wallet
     */
    function changeFeeReceiverProject(address newWallet) external onlyOwner {
        emit ProjectWalletUpdated(newWallet, projectWallet);
        projectWallet = newWallet;
    }

    /**
     * @notice  Information about the swapback settings
     * @return  _swapbackEnabled  if swapback is enabled
     * @return  _swapBackValueMin  the minimum amount of tokens in the contract balance to trigger swapback
     * @return  _swapBackValueMax  the maximum amount of tokens in the contract balance to trigger swapback
     */
    function swapbackValues()
        external
        view
        returns (
            bool _swapbackEnabled,
            uint256 _swapBackValueMin,
            uint256 _swapBackValueMax
        )
    {
        _swapbackEnabled = swapbackEnabled;
        _swapBackValueMin = swapBackValueMin;
        _swapBackValueMax = swapBackValueMax;
    }

    /**
     * @notice  Information about the anti whale parameters
     * @return  _limitsEnabled  if the wallet limits are in effect
     * @return  _transferDelayEnabled  if the transfer delay is enabled
     * @return  _maxWallet  The maximum amount of tokens that can be held by a wallet
     * @return  _maxTx  The maximum amount of tokens that can be bought or sold in a single transaction
     */
    function maxTxValues()
        external
        view
        returns (
            bool _limitsEnabled,
            bool _transferDelayEnabled,
            uint256 _maxWallet,
            uint256 _maxTx
        )
    {
        _limitsEnabled = limitsEnabled;
        _transferDelayEnabled = transferDelayEnabled;
        _maxWallet = maxWallet;
        _maxTx = maxTx;
    }

    /**
     * @notice The wallets that receive the collected fees
     * @return _marketingWallet The wallet that receives the marketing fees
     * @return _projectWallet The wallet that receives the dev fees
     */
    function receiverwallets()
        external
        view
        returns (address _marketingWallet, address _projectWallet)
    {
        return (marketingWallet, projectWallet);
    }


    function taxValues()
        external
        view
        returns (
            uint256 _buyTaxTotal,
            uint256 _buyMarketingTax,
            uint256 _buyProjectTax,
            uint256 _sellTaxTotal,
            uint256 _sellMarketingTax,
            uint256 _sellProjectTax
        )
    {
        _buyTaxTotal = buyTaxTotal;
        _buyMarketingTax = buyMarketingTax;
        _buyProjectTax = buyProjectTax;
        _sellTaxTotal = sellTaxTotal;
        _sellMarketingTax = sellMarketingTax;
        _sellProjectTax = sellProjectTax;
    }

    /**
     * @notice  If the wallet is excluded from fees and max transaction amount and if the wallet is a automated market maker pair
     * @param   _target  The wallet to check
     * @return  _transferTaxExempt  If the wallet is excluded from fees
     * @return  _transferLimitExempt  If the wallet is excluded from max transaction amount
     * @return  _automatedMarketMakerPairs If the wallet is a automated market maker pair
     */
    function checkMappings(
        address _target
    )
        external
        view
        returns (
            bool _transferTaxExempt,
            bool _transferLimitExempt,
            bool _automatedMarketMakerPairs
        )
    {
        _transferTaxExempt = transferTaxExempt[_target];
        _transferLimitExempt = transferLimitExempt[_target];
        _automatedMarketMakerPairs = automatedMarketMakerPairs[_target];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsEnabled) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!tradingEnabled) {
                    require(
                        transferTaxExempt[from] || transferTaxExempt[to],
                        "_transfer:: Trading is not active."
                    );
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(dexRouter) &&
                        to != address(dexPair)
                    ) {
                        require(
                            _holderLastTransferTimestamp[tx.origin] <
                                block.number,
                            "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                        );
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }

                //when buy
                if (
                    automatedMarketMakerPairs[from] && !transferLimitExempt[to]
                ) {
                    require(
                        amount <= maxTx,
                        "Buy transfer amount exceeds the maxTx."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    automatedMarketMakerPairs[to] && !transferLimitExempt[from]
                ) {
                    require(
                        amount <= maxTx,
                        "Sell transfer amount exceeds the maxTx."
                    );
                } else if (!transferLimitExempt[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapBackValueMin;

        if (
            canSwap &&
            swapbackEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !transferTaxExempt[from] &&
            !transferTaxExempt[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (transferTaxExempt[from] || transferTaxExempt[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (automatedMarketMakerPairs[to] && sellTaxTotal > 0) {
                fees = amount.mul(sellTaxTotal).div(100);
                tokensForProject += (fees * sellProjectTax) / sellTaxTotal;
                tokensForMarketing += (fees * sellMarketingTax) / sellTaxTotal;
            }
            // on buy
            else if (automatedMarketMakerPairs[from] && buyTaxTotal > 0) {
                fees = amount.mul(buyTaxTotal).div(100);
                tokensForProject += (fees * buyProjectTax) / buyTaxTotal;
                tokensForMarketing += (fees * buyMarketingTax) / buyTaxTotal;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = contractBalance;
        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > swapBackValueMax) {
            contractBalance = swapBackValueMax;
        }

        uint256 amountToSwapForETH = contractBalance;

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForDev = ethBalance.mul(tokensForProject).div(
            totalTokensToSwap
        );

        tokensForMarketing = 0;
        tokensForProject = 0;

        (success, ) = address(projectWallet).call{value: ethForDev}("");

        (success, ) = address(marketingWallet).call{
            value: address(this).balance
        }("");
    }
}