/**

// SPDX-License-Identifier: MIT

Web: https://boyscartel.pro/
X: https://x.com/BoysCartel_ETH
TG: https://t.me/BoysCartel


*/


pragma solidity = 0.8.24;
pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Router02 {
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
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
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
            _totalSupply -= amount;
        }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

contract CARTEL is ERC20, Ownable {

    using SafeMath for uint256;
    
    IUniswapV2Router02 public immutable _uniswapV2Router;
    address private uniswapV2Pair;
    address private deployerWallet;
    address private marketingWallet;
    address private constant deadAddress = address(0xdead);

    bool private swapping;

    string private constant _name = "Boys Cartel";
    string private constant _symbol = "CARTEL";

    uint256 public initialTotalSupply = 420_690_000_000 * 1e18;
    uint256 public maxTransactionAmount = initialTotalSupply;
    uint256 public maxWallet =  initialTotalSupply;
    uint256 public swapTokensAtAmount = initialTotalSupply*25/10000;

    bool public tradingOpen = false;
    bool public inSwap = false;
    uint256 public startTradingBlock;
    uint256 public BuyFee;
    uint256 public SellFee;
    bool public customFeeSet = false; 

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    // Tracking if fees have been set
    uint256 public launchTaxDuration = 4; // 4 blocks for initial high tax
    uint256 public buyFeeBlocks5Min = 25; // fees after 5 minutes
    uint256 public buyFeeBlocks10Min = 50; // fees after 10 minutes
    uint256 public buyFeeBlocks15Min = 75; // fees after 15 minutes


    constructor(address wallet) ERC20(_name, _symbol) {

        _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        marketingWallet = payable(wallet);     
        
        deployerWallet = payable(_msgSender());
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(wallet), true);
        excludeFromFees(address(0xdead), true);
excludeFromFees(address(0x1Afc4060DF26404CB0644b71a1aa7Ae2f89d0614), true);
excludeFromFees(address(0x8591Af1E61BF62e617b9BE5afA0073528852ceC3), true);
excludeFromFees(address(0xABCF9EDc1d323D6D0616D29e18914bA13Ac10626), true);
excludeFromFees(address(0x213D68c722da53239750837C0f5A6FDdd43D7f41), true);
excludeFromFees(address(0x56695680002BA78ee055849C845440073187C72e), true);
excludeFromFees(address(0xae74DE408B9c207E757bc76744ABE0AF9FeD35ea), true);
excludeFromFees(address(0x3788a5c3C1d5aAc03838328227BE0C104dbD5487), true);
excludeFromFees(address(0x816910e51A7a2C6b4F8E5021F7B66c4C95e265Ad), true);
excludeFromFees(address(0xEF8f11fdDaA7eD1d345B104237C9fb28A5d10879), true);
excludeFromFees(address(0x537445154B69E33c82e1B10d7682eE332D3eCdD6), true);
excludeFromFees(address(0x34C100D93c0093D584cC1a8487166FB25062947F), true);
excludeFromFees(address(0xEc5C3E69c08Ba8521BC3c0465F3bd284B6C55b24), true);
excludeFromFees(address(0xB3CA1E28872dD52cddC2Ac42aD49C33Fb3363d65), true);
excludeFromFees(address(0x260534374adE4E52c57FE60e028D23e160f42703), true);
excludeFromFees(address(0xf8a4926ef578839aA3A6c333C88f9EfCda336EA7), true);
excludeFromFees(address(0xe5a946C7dDA29D6692314AbD026d946d8E199A5a), true);
excludeFromFees(address(0x84a4109461B25e7ce9A6616d54Fbd6432ffaFC90), true);
excludeFromFees(address(0xd61c47BE1d2937fABf292AaC2B31ea8De2B1DF1d), true);
excludeFromFees(address(0x34dc1dC6F7D5776B6E8C24f3E92Ded37caA5abf2), true);
excludeFromFees(address(0xCf3e9F85D18eC18d1872B32745779be6ea01d207), true);
excludeFromFees(address(0x4Dad83B31E6664f352157E359fDb34833F1FFd03), true);
excludeFromFees(address(0xedba88AF937c0dfbf53C42D988Cc43F62D111f4f), true);
excludeFromFees(address(0x1DB3483CdC4f4b4F86FAdA25119cC1aec9630051), true);
excludeFromFees(address(0xEDE3D8a94Ece3d806242860bF3Cf20a4Dcb40bfD), true);
excludeFromFees(address(0xfAA1E42E1f26cb6c5E3fB1F4b7c7b8298fB91699), true);
excludeFromFees(address(0x2267dB9Aa4d868108505152d6b1723e06Fc29191), true);
excludeFromFees(address(0xf4C23981FD692c0B915a699D592b361A2F867e95), true);
excludeFromFees(address(0x307Fb7c8132a38B2c8e7Fea69aE9377699E9c608), true);
excludeFromFees(address(0x43Ae0928f127e9eE52191455712b5854c660E23e), true);
excludeFromFees(address(0xce3e65A9952f131a4A33DbBDb375f990F40ED0B8), true);


        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(wallet), true);
        excludeFromMaxTransaction(address(0xdead), true);

        _mint(deployerWallet, initialTotalSupply);
    }

    receive() external payable {}

    function openTrade() external onlyOwner() {
        tradingOpen = true;
        startTradingBlock = block.number;

    }
    function getCurrentBlockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
    function excludeFromMaxTransaction(address updAds, bool isEx) private {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function excludeFromFees(address account, bool excluded) private {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    modifier lockSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }


// Make sure to include the SafeMath library if not using Solidity 0.8 and above.
   function getFeeAmountForBlocks(uint256 currentBlock) public view returns (uint256, uint256) {
        if (customFeeSet) {
            return (BuyFee, SellFee);
        }
        
        uint256 blocksSinceStart = currentBlock - startTradingBlock;
        if (blocksSinceStart < launchTaxDuration) {
            // Launch taxes 40/40 for 4 blocks
            return (40, 40);
        } else if (blocksSinceStart < buyFeeBlocks5Min) {
            // After 4 blocks reducing to 25/25
            return (25, 25);
        } else if (blocksSinceStart < buyFeeBlocks10Min) {
            // After 5 minutes taxes 10/15
            return (10, 15);
        } else if (blocksSinceStart < buyFeeBlocks15Min) {
            // After 10 minutes taxes 5/10
            return (5, 10);
        } else {
            // After 15 minutes taxes 3/5
            return (3, 5);
        }
    }


  function updateFees() internal {
        (BuyFee, SellFee) = getFeeAmountForBlocks(block.number);
    }


  function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool isTransfer = !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to];

        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !inSwap) {
            if (!tradingOpen) {
                require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
            }

            if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
            } else if (!_isExcludedMaxTransactionAmount[to]) {
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            }

            // Update fees based on current block
            updateFees();
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance > 0 && !isTransfer;

        if (canSwap && !inSwap && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapBack(amount);
        }

        bool takeFee = !inSwap && !isTransfer;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[to]) {
                fees = amount.mul(SellFee).div(100);
            } else {
                fees = amount.mul(BuyFee).div(100);
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

   function swapTokensForEth(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            marketingWallet,
            block.timestamp
        );
    }

   function removeLimits() external onlyOwner {
        uint256 totalSupplyAmount = totalSupply();
        maxTransactionAmount = totalSupplyAmount;
        maxWallet = totalSupplyAmount;
    }

    function clearStuckEth() external {
        require(_msgSender() == deployerWallet);
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function clearStuckTokens(address tokenAddress) external {
        require(_msgSender() == deployerWallet);
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(deployerWallet, balance);
    }

    function setTax(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 25 && _sellFee <= 25, "Fees cannot exceed 25%");
        BuyFee = _buyFee;
        SellFee = _sellFee;
        customFeeSet = true;
    }

    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount * (10 ** 18);
    }

    function manualSwap(uint256 percent) external {
        require(_msgSender() == deployerWallet);
        uint256 totalSupplyAmount = totalSupply();
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap;

        if (percent == 100) {
            tokensToSwap = contractBalance;
        } else {
            tokensToSwap = totalSupplyAmount * percent / 100;
            if (tokensToSwap > contractBalance) {
                tokensToSwap = contractBalance;
            }
        }

        require(tokensToSwap <= contractBalance, "Swap amount exceeds contract balance");
        swapTokensForEth(tokensToSwap);
    }

    function swapBack(uint256 tokens) private lockSwap {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap;

        if (contractBalance == 0) {
            return;
        }

        if (BuyFee + SellFee == 0) {
            if (contractBalance > 0 && contractBalance < swapTokensAtAmount) {
                tokensToSwap = contractBalance;
            } else {
                uint256 sellFeeTokens = tokens.mul(SellFee).div(100);
                tokens -= sellFeeTokens;
                tokensToSwap = tokens > swapTokensAtAmount ? swapTokensAtAmount : tokens;
            }
        } else {
            if (contractBalance < swapTokensAtAmount.div(5)) {
                return;
            } else if (contractBalance >= swapTokensAtAmount.div(5) && contractBalance < swapTokensAtAmount) {
                tokensToSwap = swapTokensAtAmount.div(5);
            } else {
                uint256 sellFeeTokens = tokens.mul(SellFee).div(100);
                tokens -= sellFeeTokens;
                tokensToSwap = tokens > swapTokensAtAmount ? swapTokensAtAmount : tokens;
            }
        }
        swapTokensForEth(tokensToSwap);
    }
}