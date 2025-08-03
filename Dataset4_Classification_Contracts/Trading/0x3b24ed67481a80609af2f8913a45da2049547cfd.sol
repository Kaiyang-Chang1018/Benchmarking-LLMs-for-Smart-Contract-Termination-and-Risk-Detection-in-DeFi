// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/* 
     Nodez is officially incubated by Sentinel Incubator - https://sentinelbot.ai
     
     Deploy and manage blockchain nodes with unprecedented ease. 
     Earn rewards and contribute to network security without technical expertise. 
     Join the decentralized revolution with just a single click. 

     Website: https://nodez.tech
     Dapp: https://app.nodez.tech/
     Telegram: https://t.me/NodezTech
     Twitter: https://x.com/nodeztech
     Whitepaper: https://nodez.tech/whitepaper
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ReentrancyGuard {
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

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

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, 
        uint liquidity, 
        uint amountTokenMin, 
        uint amountETHMin, 
        address to, 
        uint deadline, 
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

contract Nodez is ERC20, Ownable, ReentrancyGuard {
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant deadAddress = address(0xdead);

    bool private swapping;

    address public projectWallet;
    address public incubatorWallet;

    uint256 public maxTransactionAmount;
    uint256 public maxWallet;
    uint8 private _decimals;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    bool public rescueSwap = false;

    uint256 public tradingActiveBlock;
    uint256 public taxStartTime;
    uint256 public redirectionHours = 2160; // Default 2160 hours (90 days)

    uint256 public buyTotalFees;
    uint256 public sellTotalFees;

    uint256 public tokensForProject;
    uint256 public tokensForIncubator;

    // Exclusions from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    // Store AMM pairs
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ProjectWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event IncubatorWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event OwnerForcedSwapBack(uint256 timestamp);

    // Added event declarations for new events
    event TradingEnabled(uint256 blockNumber);
    event LimitsRemoved();
    event MaxTransactionAmountUpdated(uint256 newAmount);
    event MaxWalletUpdated(uint256 newAmount);
    event ExcludedFromMaxTransaction(address account, bool isExcluded);
    event SwapEnabledUpdated(bool enabled);
    event RescueSwapUpdated(bool enabled);
    event BuyFeesUpdated(uint256 totalBuyFee);
    event SellFeesUpdated(uint256 totalSellFee);
    event RedirectionHoursUpdated(uint256 newRedirectionHours);

    constructor() ERC20('Nodez', 'NODE') {
        address _owner = _msgSender();

        _decimals = 18;

        uint256 totalSupply = 100_000_000 * (10 ** _decimals); // 100 million

        maxTransactionAmount = totalSupply * 2 / 100; // 2%
        maxWallet = totalSupply * 2 / 100; // 2%

        // Initial buy and sell fees
        buyTotalFees = 30;
        sellTotalFees = 40;

        projectWallet = 0x1C812f13BEB346678a134Bf89480076e8D299701;
        incubatorWallet = 0x85dBe4ce3c809DAC17E4B1D32a5A2478038a3ae1;

        address currentRouter;

        if (block.chainid == 56) {
            currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PCS Router
        } else if (block.chainid == 97) {
            currentRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PCS Testnet
        } else if (block.chainid == 43114) {
            currentRouter = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; // Avax Mainnet
        } else if (block.chainid == 137) {
            currentRouter = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; // Polygon Ropsten
        } else if (block.chainid == 250) {
            currentRouter = 0xF491e7B69E4244ad4002BC14e878a34207E38c29; // SpookySwap FTM
        } else if (block.chainid == 3) {
            currentRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Ropsten
        } else if (block.chainid == 1 || block.chainid == 4) {
            currentRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Mainnet
        } else if (block.chainid == 8453) {
            currentRouter = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24; // Base Mainnet Router
        } else {
            revert("Unsupported chain");
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);

        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        // Exclude from fees and max transaction amount
        excludeFromFees(_owner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadAddress, true);

        excludeFromMaxTransaction(_owner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(deadAddress, true);

        _mint(_owner, totalSupply);
        transferOwnership(_owner);
    }

    receive() external payable {}

    // Enable trading (irreversible)
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        taxStartTime = block.timestamp;

        // Set initial tax rates
        buyTotalFees = 30;
        sellTotalFees = 40;

        emit TradingEnabled(block.number);
    }

    // Remove transaction and wallet limits
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        emit LimitsRemoved();
        return true;
    }

    // Update max transaction amount
    function updateMaxTransactionAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 100), 'Cannot set maxTransactionAmount lower than 1%');
        maxTransactionAmount = newNum;
        emit MaxTransactionAmountUpdated(newNum);
    }

    // Update max wallet amount
    function updateMaxWallet(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 100), 'Cannot set maxWallet lower than 1%');
        maxWallet = newNum;
        emit MaxWalletUpdated(newNum);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
        emit ExcludedFromMaxTransaction(updAds, isEx);
    }

    // Only use to disable contract sales in an emergency
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
        emit SwapEnabledUpdated(enabled);
    }

    // Disable swap and send tokens as is
    function updateRescueSwap(bool enabled) external onlyOwner {
        rescueSwap = enabled;
        emit RescueSwapUpdated(enabled);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, 'Cannot remove pair');
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateProjectWallet(address newWallet) external onlyOwner {
        emit ProjectWalletUpdated(newWallet, projectWallet);
        projectWallet = newWallet;
    }

    function updateIncubatorWallet(address newWallet) external onlyOwner {
        emit IncubatorWalletUpdated(newWallet, incubatorWallet);
        incubatorWallet = newWallet;
    }

    function updateRedirectionHours(uint256 newRedirectionHours) external onlyOwner {
    require(newRedirectionHours >= 1 && newRedirectionHours <= 2160, "Duration must be between 1 and 2160 hours");
    redirectionHours = newRedirectionHours;
    emit RedirectionHoursUpdated(newRedirectionHours);
    }


    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    // Timelock tax mechanism
    function getTaxRates() public view returns (uint256 buyFee, uint256 sellFee) {
        if (!tradingActive) {
            return (0, 0);
        }

        uint256 timeElapsed = block.timestamp - taxStartTime;

        if (timeElapsed <= 30 minutes) {
            if (timeElapsed <= 5 minutes) {
                return (30, 40);
            } else if (timeElapsed <= 10 minutes) {
                return (20, 30);
            } else if (timeElapsed <= 15 minutes) {
                return (15, 25);
            } else if (timeElapsed <= 20 minutes) {
                return (10, 20);
            } else if (timeElapsed <= 25 minutes) {
                return (7, 15);
            } else if (timeElapsed <= 30 minutes) {
                return (5, 5);
            }
        }

        // After the timelock period, use the manually set fees
        return (buyTotalFees, sellTotalFees);
    }

    function updateBuyFees(uint256 newBuyFee) external onlyOwner {
        require(newBuyFee <= 30, "Total buy fees cannot exceed 30%");
        buyTotalFees = newBuyFee;
        emit BuyFeesUpdated(newBuyFee);
    }

    function updateSellFees(uint256 newSellFee) external onlyOwner {
        require(newSellFee <= 40, "Total sell fees cannot exceed 40%");
        sellTotalFees = newSellFee;
        emit SellFeesUpdated(newSellFee);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), 'ERC20: transfer from the zero address');
        require(to != address(0), 'ERC20: transfer to the zero address');

        if (!tradingActive) {
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], 'Trading is not active.');
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsInEffect) {
            if (from != owner() && to != owner() && to != address(0) && to != deadAddress && !(_isExcludedFromFees[from] || _isExcludedFromFees[to]) && !swapping) {
                // On buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, 'Buy exceeds max transaction amount.');
                    require(amount + balanceOf(to) <= maxWallet, 'Exceeds max wallet.');
                }
                // On sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount, 'Sell exceeds max transaction amount.');
                } else {
                    require(amount + balanceOf(to) <= maxWallet, 'Exceeds max wallet.');
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance > 0;

        if (canSwap && swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

        // If any account is excluded from fees, remove fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (takeFee) {
            (uint256 buyFee, uint256 sellFee) = getTaxRates();

            if (automatedMarketMakerPairs[to]) {
                fees = amount * sellFee / 100;
            } else if (automatedMarketMakerPairs[from]) {
                fees = amount * buyFee / 100;
            }

            if (fees > 0) {
                uint256 timeElapsed = block.timestamp - taxStartTime;
                if (timeElapsed >= redirectionHours * 1 hours) {
                    // After the specified hours, redirect 100% of the fees to the project wallet
                    tokensForProject += fees;
                } else {
                    uint256 incubatorShare = fees * 20 / 100;
                    uint256 projectShare = fees - incubatorShare;

                    tokensForIncubator += incubatorShare;
                    tokensForProject += projectShare;
                }

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

        uniswapV2Router.addLiquidityETH{ value: ethAmount }(
            address(this),
            tokenAmount,
            0,
            0,
            deadAddress,
            block.timestamp
        );
    }

    function swapBack() private nonReentrant {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForProject + tokensForIncubator;

        if (contractBalance == 0 || totalTokensToSwap == 0) return;

        // Limit swap to 0.5% of total supply
        uint256 maxTokensToSwap = totalSupply() * 5 / 1000;
        if (contractBalance > maxTokensToSwap) {
            contractBalance = maxTokensToSwap;
        }

        uint256 amountToSwapForETH = contractBalance;

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - initialETHBalance;

        uint256 ethForIncubator = ethBalance * tokensForIncubator / totalTokensToSwap;
        uint256 ethForProject = ethBalance - ethForIncubator;

        tokensForIncubator = 0;
        tokensForProject = 0;

        payable(incubatorWallet).transfer(ethForIncubator);
        payable(projectWallet).transfer(ethForProject);
    }

    // Rescue ETH from the contract to the owner's wallet
    function rescueETH() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "No ETH in contract");
        payable(owner()).transfer(contractETHBalance);
    }

    // Rescue ERC20 tokens from the contract to the owner's wallet
    function rescueTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 contractTokenBalance = token.balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens in contract");
        token.transfer(owner(), contractTokenBalance);
    }
}