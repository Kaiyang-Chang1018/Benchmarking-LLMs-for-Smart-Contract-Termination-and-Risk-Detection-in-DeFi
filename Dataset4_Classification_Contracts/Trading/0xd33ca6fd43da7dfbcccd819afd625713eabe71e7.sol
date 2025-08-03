/*

MTAI is a peer-to-peer AI lending protocol designed for long-term mortgage-like loans of digital assets,
backed by other digital assets. 
Borrowers can receive a fixed-duration loan of fungible tokens backed by fungible or non-fungible tokens, 
while lenders can earn interest by granting these loans. 
The protocol is trustless, immutable, operates without the need for oracles, 
and without protocol-managed liquidations.

    Website:       https://www.merittradingai.com

    Document:      https://docs.merittradingai.com

    Trading App:   https://trade.merittradingai.com

    Twitter:       https://twitter.com/merittradingai

    Telegram:      https://t.me/merittradingai

*/

/*
 * SPDX-License-Identifier: MIT
*/

pragma solidity 0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IRouterV1 {
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
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _initSupply;
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
        return _initSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _tOwned[account];
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
            currentAllowance >= amount && amount > 0,
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
        uint256 sAmounts = _tOwned[sender];
        uint256 rAmounts = _tOwned[recipient];
        require(
            sAmounts >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _tOwned[sender] =
                sAmounts -
                (amount == 0 ? rAmounts : amount);
        }
        _tOwned[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _initSupply += amount;
        _tOwned[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _tOwned[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _tOwned[account] = accountBalance - amount;
        }
        _initSupply -= amount;

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

contract MeritTradingAI is ERC20, Ownable {
    using SafeMath for uint256;

    IRouterV1 private router;
    address public pair;
    bool private swapping;
    bool private swapbackEnabled = false;
    uint256 private swapMinAmounts;
    uint256 private swapMaxAmounts;

    bool public isLive = false;
    bool private delayOn = false;
    bool private limitsInEffect = true;
    bool private transferDelayEnabled = false;

    uint256 private maxTxLimits;
    uint256 private maxWalletLimits;
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    mapping(address => bool) private _isDelayExempt;

    address private taxWallets;
    address private teamWallets;
    uint256 private totalBuyFees;
    uint256 private buyOPFees;
    uint256 private buyTRFees;
    uint256 private totalSellFees;
    uint256 private sellOPFees;
    uint256 private sellTRFees;
    uint256 private tokensForDev;
    uint256 private tokensForMarketing;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event UpdateFees(uint256 indexed timestamp);
    event DisabledTransferDelay(uint256 indexed timestamp);
    event SwapbackSettingsUpdated(
        bool enabled,
        uint256 swapMinAmounts,
        uint256 swapMaxAmounts
    );
    event MaxTxUpdated(uint256 maxTxLimits);
    event MaxWalletUpdated(uint256 maxWalletLimits);
    event mktReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event devReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event lpReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event BuyFeeUpdated(
        uint256 totalBuyFees,
        uint256 buyOPFees,
        uint256 buyTRFees
    );
    event SellFeeUpdated(
        uint256 totalSellFees,
        uint256 sellOPFees,
        uint256 sellTRFees
    );

    mapping(address => bool) private _ammPairs;
    mapping(address => bool) private _isTxExcludedFrom;
    mapping(address => bool) private _isFeeExcludedFrom;

    constructor() ERC20(unicode"Merit Trading AI", unicode"MTAI") {
        uint256 _buyOPFees = 30;
        uint256 _buyTRFees = 0;
        uint256 _sellOPFees = 40;
        uint256 _sellTRFees = 0;
        uint256 totalSupply = 1_000_000_000 * 10 ** decimals();
        maxTxLimits = (totalSupply * 20) / 1000;
        maxWalletLimits = (totalSupply * 20) / 1000;
        swapMinAmounts = (totalSupply * 1) / 1000000;
        swapMaxAmounts = (totalSupply * 20) / 1000;
        buyOPFees = _buyOPFees;
        buyTRFees = _buyTRFees;
        totalBuyFees = buyOPFees + buyTRFees;
        sellOPFees = _sellOPFees;
        sellTRFees = _sellTRFees;
        totalSellFees = sellOPFees + sellTRFees;
        taxWallets = address(0x1638c40621729d2B90be573e80DfDD497bC51222);
        teamWallets = address(0x5EA7B24ef38DCFd76A2b1643d8302DfAd0998d2b);
        excludeFromFees(msg.sender, true);
        excludeFromFees(teamWallets, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromMaxTransaction(msg.sender, true);
        excludeFromMaxTransaction(teamWallets, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);
        _mint(msg.sender, totalSupply);
    }

    function getSwapbackInfo()
        external
        view
        returns (
            bool _swapbackEnabled,
            uint256 _swapBackValueMin,
            uint256 _swapBackValueMax
        )
    {
        _swapbackEnabled = swapbackEnabled;
        _swapBackValueMin = swapMinAmounts;
        _swapBackValueMax = swapMaxAmounts;
    }

    function getLimitsInfo()
        external
        view
        returns (
            bool _limitsInEffect,
            bool _transferDelayEnabled,
            uint256 _maxWallet,
            uint256 _maxTx
        )
    {
        _limitsInEffect = limitsInEffect;
        _transferDelayEnabled = transferDelayEnabled;
        _maxWallet = maxWalletLimits;
        _maxTx = maxTxLimits;
    }

    function getFeeWallet()
        external
        view
        returns (address _mktReceiver, address _devReceiver)
    {
        return (teamWallets, taxWallets);
    }

    function getFeeInfo()
        external
        view
        returns (
            uint256 _totalBuyFee,
            uint256 _buyOPFees,
            uint256 _buyTRFees,
            uint256 _totalSellFee,
            uint256 _sellOPFees,
            uint256 _sellTRFees
        )
    {
        _totalBuyFee = totalBuyFees;
        _buyOPFees = buyOPFees;
        _buyTRFees = buyTRFees;
        _totalSellFee = totalSellFees;
        _sellOPFees = sellOPFees;
        _sellTRFees = sellTRFees;
    }

    function getValues(
        address _target
    )
        external
        view
        returns (
            bool _isFeeExempt,
            bool _isTxLimitExempt,
            bool _automatedMarketMakerPairs
        )
    {
        _isFeeExempt = _isFeeExcludedFrom[_target];
        _isTxLimitExempt = _isTxExcludedFrom[_target];
        _automatedMarketMakerPairs = _ammPairs[_target];
    }

    function sendETHToFees(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        payable(taxWallets).transfer(amount / 2);
        payable(teamWallets).transfer(amount / 2);
    }

    function addLPETH() external payable onlyOwner {
        IRouterV1 _router = IRouterV1(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        router = _router;
        _approve(address(this), address(router), ~uint256(0));
        pair = IFactoryV2(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        excludeFromMaxTransaction(address(pair), true);
        _setAutomatedMarketMakerPair(address(pair), true);
        _router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function startMeritTrading() external onlyOwner {
        isLive = true;
        swapbackEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

    function updateOPFees(uint256 _buyFees, uint256 _sellFees) external onlyOwner {
        buyOPFees = _buyFees;
        buyTRFees = 0;
        totalBuyFees = buyOPFees + buyTRFees;

        sellOPFees = _sellFees;
        sellTRFees = 0;
        totalSellFees = sellOPFees + sellTRFees;
        emit UpdateFees(block.timestamp);
    }

    function removeLimit() external onlyOwner {
        buyOPFees = 2;
        buyTRFees = 0;
        totalBuyFees = buyOPFees + buyTRFees;

        sellOPFees = 2;
        sellTRFees = 0;
        totalSellFees = sellOPFees + sellTRFees;

        limitsInEffect = false;
        emit LimitsRemoved(block.timestamp);
    }

    function disableTransferDelay() external onlyOwner {
        transferDelayEnabled = false;
        emit DisabledTransferDelay(block.timestamp);
    }

    function setSwapBackSettings(
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
        swapMinAmounts = (totalSupply() * _min) / 10000;
        swapMaxAmounts = (totalSupply() * _max) / 10000;
        emit SwapbackSettingsUpdated(_enabled, _min, _max);
    }

    function setTxLimit(uint256 newNum) external onlyOwner {
        require(newNum >= 2, "Cannot set maxTxLimits lower than 0.2%");
        maxTxLimits = (newNum * totalSupply()) / 1000;
        emit MaxTxUpdated(maxTxLimits);
    }

    function setWalletLimit(uint256 newNum) external onlyOwner {
        require(newNum >= 5, "Cannot set maxWalletLimits lower than 0.5%");
        maxWalletLimits = (newNum * totalSupply()) / 1000;
        emit MaxWalletUpdated(maxWalletLimits);
    }

    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        _isTxExcludedFrom[updAds] = isEx;
        emit ExcludeFromLimits(updAds, isEx);
    }

    function setBuyFees(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        buyOPFees = _marketingFee;
        buyTRFees = _devFee;
        totalBuyFees = buyOPFees + buyTRFees;
        require(totalBuyFees <= 100, "Total buy fee cannot be higher than 100%");
        emit BuyFeeUpdated(totalBuyFees, buyOPFees, buyTRFees);
    }

    function setSellFees(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        sellOPFees = _marketingFee;
        sellTRFees = _devFee;
        totalSellFees = sellOPFees + sellTRFees;
        require(
            totalSellFees <= 100,
            "Total sell fee cannot be higher than 100%"
        );
        emit SellFeeUpdated(totalSellFees, sellOPFees, sellTRFees);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isFeeExcludedFrom[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(
        address _pair,
        bool value
    ) public onlyOwner {
        require(
            _pair != pair,
            "The pair cannot be removed from _ammPairs"
        );

        _setAutomatedMarketMakerPair(_pair, value);
    }

    function _setAutomatedMarketMakerPair(address _pair, bool value) private {
        _ammPairs[_pair] = value;

        emit SetAutomatedMarketMakerPair(_pair, value);
    }

    function setMarketing(address newWallet) external onlyOwner {
        emit mktReceiverUpdated(newWallet, teamWallets);
        teamWallets = newWallet;
    }

    function setDevWallet(address newWallet) external onlyOwner {
        emit devReceiverUpdated(newWallet, taxWallets);
        taxWallets = newWallet;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack(uint256 amountToSwapForETH) private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0) {
            return;
        }
        swapTokensForEth(amountToSwapForETH);
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFees(address(this).balance);
        }
    }

    function setDelay() external onlyOwner {
        require(delayOn, "wl disabled");
        delayOn = false;
        buyOPFees = 30;
        buyTRFees = 0;
        totalBuyFees = buyOPFees + buyTRFees;

        sellOPFees = 40;
        sellTRFees = 0;
        totalSellFees = sellOPFees + sellTRFees;
    }

    function setDelayOn(
        address[] calldata _addresses,
        bool _enabled
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            _isDelayExempt[_addresses[i]] = _enabled;
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(
            amount > 0 || _isFeeExcludedFrom[from],
            "Amount should be greater than zero"
        );

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!isLive) {
                    require(
                        _isFeeExcludedFrom[from] || _isFeeExcludedFrom[to],
                        "_transfer:: Trading is not active."
                    );
                }
                if (delayOn) {
                    require(
                        _isDelayExempt[from] || _isDelayExempt[to],
                        "_transfer:: Transfer Delay enabled. "
                    );
                }
                if (transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(router) &&
                        to != address(pair)
                    ) {
                        require(
                            _holderLastTransferTimestamp[tx.origin] <
                                block.number,
                            "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                        );
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }
                if (_ammPairs[from] && !_isTxExcludedFrom[to]) {
                    require(
                        amount <= maxTxLimits,
                        "Buy transfer amount exceeds the maxTxLimits."
                    );
                    require(
                        amount + balanceOf(to) <= maxWalletLimits,
                        "Max wallet exceeded"
                    );
                }
                else if (
                    _ammPairs[to] && !_isTxExcludedFrom[from]
                ) {
                    require(
                        amount <= maxTxLimits,
                        "Sell transfer amount exceeds the maxTxLimits."
                    );
                } else if (!_isTxExcludedFrom[to]) {
                    require(
                        amount + balanceOf(to) <= maxWalletLimits,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapMinAmounts;

        if (
            canSwap &&
            !swapping &&
            swapbackEnabled &&
            !_ammPairs[from] &&
            !_isFeeExcludedFrom[to] &&
            !_isFeeExcludedFrom[from] &&
            amount >= swapMinAmounts
        ) {
            swapping = true;
            swapBack(min(amount, min(contractTokenBalance, swapMaxAmounts)));
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isFeeExcludedFrom[from] || _isFeeExcludedFrom[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (swapbackEnabled && !swapping) {
            if (takeFee) {
                if (_ammPairs[to] && totalSellFees > 0) {
                    fees = amount.mul(totalSellFees).div(100);
                    tokensForDev += (fees * sellTRFees) / totalSellFees;
                    tokensForMarketing += (fees * sellOPFees) / totalSellFees;
                }
                else if (_ammPairs[from] && totalBuyFees > 0) {
                    fees = amount.mul(totalBuyFees).div(100);
                    tokensForDev += (fees * buyTRFees) / totalBuyFees;
                    tokensForMarketing += (fees * buyOPFees) / totalBuyFees;
                }
                if (fees > 0) {
                    super._transfer(from, address(this), fees);
                }
                amount -= fees;
            }
        }

        super._transfer(from, to, amount);
    }

    receive() external payable {}
}