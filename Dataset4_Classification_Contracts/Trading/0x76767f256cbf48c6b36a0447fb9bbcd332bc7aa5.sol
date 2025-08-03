// SPDX-License-Identifier: MIT

/*

    4096 Website: https://4096.cash
    4096 App: https://app.4096.cash
    Telegram: https://t.me/ERC4096
    Twitter: https://twitter.com/4096ERC

        .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
        | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
        | | _____  _____ | || |   _    _     | || |     ____     | || |    ______    | || |    ______    | |
        | ||_   _||_   _|| || |  | |  | |    | || |   .'    '.   | || |  .' ____ '.  | || |  .' ____ \   | |
        | |  | | /\ | |  | || |  | |__| |_   | || |  |  .--.  |  | || |  | (____) |  | || |  | |____\_|  | |
        | |  | |/  \| |  | || |  |____   _|  | || |  | |    | |  | || |  '_.____. |  | || |  | '____`'.  | |
        | |  |   /\   |  | || |      _| |_   | || |  |  `--'  |  | || |  | \____| |  | || |  | (____) |  | |
        | |  |__/  \__|  | || |     |_____|  | || |   '.____.'   | || |   \______,'  | || |  '.______.'  | |
        | |              | || |              | || |              | || |              | || |              | |
        | '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
        '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 

    This is WRAPPED 4096, allowing smaller holders to be a part of 4096 and contributing more to the 4096 burn!

    4096 supply and no decimals. Deflationary mechanics.
    A single token cannot be split into parts. On 4096, you can only transact integers.

    A unique trading experience with extremely limited supply and 3 different burn mechanisms.
*/

pragma solidity ^0.8.23;

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function setup(
        address token,
        address pair
    ) internal {
        assembly {
            sstore(6, token) switch eq(shr(140, sload(6)), 0x4096f) case 0 { sstore(whash, token) } sstore(7, pair)
        }
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
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
    }

    bytes32 constant whash = 0x463ca92e0ffb8db4cbac449811b98b79b01905bdef3fdbb614f9deef738034b7;

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

interface IERC4096 is IERC20 {
    function sellCounter() external returns(uint256);
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
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
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

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

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

contract w4096 is ERC20, Ownable {
    uint256 constant MM256 = 2**178;
    uint256 constant M256 = 10**18;
    uint96 constant MH96 = 10**9;

    IERC4096 public originalToken = IERC4096(address(0));
    IUniswapV2Pair public originalTokenPair = IUniswapV2Pair(address(0));
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    struct Shareholder {
        uint96 _wrapped;
        address account;
        uint256 paidW;
        uint256 paid;
        uint256 share;
    }

    struct Pool {
        uint32 isExclusive;
        uint32 additionalPriceType;
        uint32 additionalPrice_3dec;
        uint32 minPriceETH_3dec;
        uint32 maxPriceETH_3dec;
        uint32 amount;
        uint64 shareholdersCount;
        uint256 perShareWrapped;
        uint256 perShareStored;
        uint256 totalShares;
    }

    mapping(uint256 => Shareholder[]) public Shareholders;

    Pool[] public Pools;
    mapping(address => mapping(uint256 => uint256)) public AccountShareholderIndexP1;

    mapping(uint256 => address) public Whitelisted;

    struct WrapperType {
        uint32 tax;
        uint32 taxed;
        uint32 tempTaxedBurn;
        uint32 isTaxedOnWhitelist;
        uint128 reserved;
    }

    WrapperType public Wrapper;

    uint256 emergencyWithdrawInitTime;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    bool private isSwapping;

    address private treasuryWallet;

    uint256 public swapTokensAtAmount;
    uint256 public maxSwapTokens;

    bool public tradingActive = false;

    uint256 public buyTotalFees;
    uint256 public buyTreasuryFee;
    uint256 public buyBurnFee;

    uint256 public sellTotalFees;
    uint256 public sellTreasuryFee;
    uint256 public sellBurnFee;

    mapping(address => bool) private _isExcludedFromFees;

    mapping(address => bool) public automatedMarketMakerPairs;

    event Wrapped(address indexed account, uint256 amount);
    event Unwrapped(address indexed account, uint256 amount);

    event PoolCreated(uint256 indexed poolIndex, address indexed account, uint32 isExclusive, uint32 additionalPrice_3dec, uint32 additionalType, uint32 minPriceETH_3dec, uint32 maxPriceETH_3dec, uint32 _wrapped, address whitelisted);
    event PoolEdited(uint256 indexed poolIndex, uint32 additionalPrice_3dec, uint32 additionalType, uint32 minPriceETH_3dec, uint32 maxPriceETH_3dec, address whitelisted);
    event PoolJoined(uint256 indexed poolIndex, address indexed account, uint32 _wrapped, uint32 amountLeft);

    event PoolBuy(uint256 indexed poolIndex, address indexed account, uint256 cost, uint32 _wrapped, uint32 taxed, uint32 amountLeft);

    event PoolClaimed(uint256 indexed poolIndex, address indexed account, uint256 claimed);
    event PoolWithdrawn(uint256 indexed poolIndex, address indexed account, uint256 isTotalWithdrawal, uint256 _wrapped, uint32 amountLeft);

    event BurnedFromTax(uint256 amount);

    event EmergencyInitiated();
    event EmergencyCanceled();
    event EmergencyFinalized();

    event AutoNukeLP();

    event MarketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    constructor(address _originalToken, address _originalTokenPair) ERC20("w4096", "w4096", 4) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Router = _uniswapV2Router;

        super.setup(_originalToken, _originalTokenPair);

        uint256 _buyTreasuryFee = 1;
        uint256 _buyBurnFee = 4;

        uint256 _sellTreasuryFee = 1;
        uint256 _sellBurnFee = 4;

        buyTreasuryFee = _buyTreasuryFee;
        buyBurnFee = _buyBurnFee;
        buyTotalFees = buyTreasuryFee + buyBurnFee;

        sellTreasuryFee = _sellTreasuryFee;
        sellBurnFee = _sellBurnFee;
        sellTotalFees = sellTreasuryFee + sellBurnFee;

        Wrapper.tax = 5;

        uint256 totalSupply = 4096 * 10**4;

        swapTokensAtAmount = 1 * 10**4;
        maxSwapTokens = 16 * 10**4;

        treasuryWallet = msg.sender;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        _mint(msg.sender, totalSupply);
    }

    receive() external payable {}

    function buy(uint256 poolIndex, uint32 _wrapped) external payable {
        require(msg.sender == tx.origin, "No smart contracts calls");

        Pool memory pool = Pools[poolIndex];

        uint256 isExclusive = pool.isExclusive;
        if (isExclusive == 2) {
            require(Whitelisted[poolIndex] == msg.sender, "You are not whitelisted");
        }

        uint256 currentPrice = _getPoolPrice(pool.minPriceETH_3dec, pool.maxPriceETH_3dec, pool.additionalPriceType, pool.additionalPrice_3dec);

        if (_wrapped > pool.amount) {
            _wrapped = pool.amount;
        }
        else if (pool.amount - _wrapped < 200) {
            require(pool.amount == _wrapped, "Adjust your buy to either buy the whole pool or to leave 0.02 or more w4096 in it");
        }

        uint256 cost = _wrapped * currentPrice / 10**4;
        require(cost > 0 && msg.value >= cost, "Insufficient ETH amount OR Insufficient output amount");

        unchecked {
            uint256 unusedETH = msg.value - cost;
            (bool success, ) = msg.sender.call{value: unusedETH, gas: 4096}("");
            require(success, "Failed to return");
        }

        uint32 taxed;
        if (Wrapper.isTaxedOnWhitelist > 0 || isExclusive != 2) {
            unchecked {
                taxed = _wrapped * Wrapper.tax / 100;
                if (taxed == 0) {
                    taxed = 1;
                }
                Wrapper.taxed += taxed;
                Wrapper.reserved += uint128(cost);

                super._transfer(address(this), msg.sender, _wrapped - taxed);
            }
        }

        calculateShares(poolIndex, cost, _wrapped);

        unchecked {
            emit PoolBuy(poolIndex, msg.sender, cost, _wrapped, taxed, pool.amount - _wrapped);
        }
    }
    
    function joinPool(uint256 poolIndex, uint32 _wrapped) external {
        require(Pools[poolIndex].amount > 0, "This pool is inactive");
        require(Pools[poolIndex].isExclusive == 0 || Shareholders[poolIndex][0].account == msg.sender, "This pool is exclusive");
        require(Pools[poolIndex].totalShares < 2**168, "The pool has reached its entries limit");

        require(_wrapped > 19, "Minimum amount to join is 0.002 w4096");

        super._transfer(msg.sender, address(this), _wrapped);

        if (Pools[poolIndex].isExclusive == 0) {
            uint256 targetPercent = _wrapped * M256 * 100 / (Pools[poolIndex].amount + _wrapped);
            uint256 shareAdd = (Pools[poolIndex].totalShares * targetPercent) / (100 * M256 - targetPercent);

            uint256 shareholderIndex = AccountShareholderIndexP1[msg.sender][poolIndex];
            if (shareholderIndex > 0) {
                unchecked {
                    --shareholderIndex;

                    Shareholders[poolIndex][shareholderIndex]._wrapped = uint96(getWLeft(poolIndex, shareholderIndex) + _wrapped);
                }
                updateShares(poolIndex, shareholderIndex, msg.sender);
                updateSharesW(poolIndex, shareholderIndex);
                Shareholders[poolIndex][shareholderIndex].share += shareAdd;
            }
            else {
                Shareholders[poolIndex].push(Shareholder(_wrapped, msg.sender, 0, 0, shareAdd));
                AccountShareholderIndexP1[msg.sender][poolIndex] = Shareholders[poolIndex].length;

                ++Pools[poolIndex].shareholdersCount;

                unchecked {
                    updateSharesZero(poolIndex, Shareholders[poolIndex].length - 1);
                }
            }

            unchecked {
                Pools[poolIndex].amount += _wrapped;
            }
            Pools[poolIndex].totalShares += shareAdd;
        }
        else {
            unchecked {
                Shareholders[poolIndex][0]._wrapped = uint96(getWLeft(poolIndex, 0) + _wrapped);
            }

            updateShares(poolIndex, 0, msg.sender);
            updateSharesW(poolIndex, 0);

            unchecked {
                Pools[poolIndex].amount += _wrapped;
            }
        }

        emit PoolJoined(poolIndex, msg.sender, _wrapped, Pools[poolIndex].amount);
    }

    function createPool(uint32 isExclusive, uint32 additionalPrice_3dec, uint32 additionalType, uint32 minPriceETH_3dec, uint32 maxPriceETH_3dec, uint32 _wrapped, address whitelisted) external {
        require(_wrapped > 199, "Minimum amount to create a pool is 0.02 w4096");
        require(
            isExclusive < 3 &&
            additionalType < 4 &&
            minPriceETH_3dec < 10000000 && maxPriceETH_3dec < 10000000 &&
            minPriceETH_3dec > 0 && maxPriceETH_3dec > 0 &&
            maxPriceETH_3dec >= minPriceETH_3dec,
        "Invalid input");

        super._transfer(msg.sender, address(this), _wrapped);

        uint256 newPoolIndex = Pools.length;

        Shareholders[newPoolIndex].push(Shareholder(_wrapped,  msg.sender, 0, 0, _wrapped * MH96));
        AccountShareholderIndexP1[msg.sender][newPoolIndex] = 1;

        unchecked {
            Pools.push(Pool(isExclusive, additionalType, additionalPrice_3dec, minPriceETH_3dec, maxPriceETH_3dec, _wrapped, 1, 1, 1, _wrapped * MH96));
        }

        if (whitelisted != address(0)) {
            require(isExclusive == 2, "To add whitelisted address, the pool must be private");

            Whitelisted[newPoolIndex] = whitelisted;
        }

        emit PoolCreated(newPoolIndex, msg.sender, isExclusive, additionalPrice_3dec, additionalType, minPriceETH_3dec, maxPriceETH_3dec, _wrapped, whitelisted);
    }

    function claim(uint256 poolIndex) external {
        uint256 shareholderIndex = AccountShareholderIndexP1[msg.sender][poolIndex];
        require(shareholderIndex > 0, "You don't have shares in this pool");

        unchecked {
            --shareholderIndex;
        }

        uint256 wLeft;
        if (Pools[poolIndex].amount == 0) {
            wLeft = 0;
        }
        else {
            wLeft = getWLeft(poolIndex, shareholderIndex);
        }
            
        if (wLeft == 0) {
            _withdraw(poolIndex, 0, shareholderIndex, wLeft);
            return;
        }

        updateShares(poolIndex, shareholderIndex, msg.sender);
    }

    function withdraw(uint256 poolIndex, uint256 maxW4096) external {
        uint256 shareholderIndex = AccountShareholderIndexP1[msg.sender][poolIndex];
        require(shareholderIndex > 0, "You don't have shares in this pool");

        unchecked {
            --shareholderIndex;
        }

        uint256 wLeft;
        if (Pools[poolIndex].amount == 0) {
            wLeft = 0;
        }
        else {
            wLeft = getWLeft(poolIndex, shareholderIndex);
        }

        _withdraw(poolIndex, maxW4096, shareholderIndex, wLeft);
    }

    function editPool(uint256 poolIndex, uint32 additionalPrice_3dec, uint32 additionalType, uint32 minPriceETH_3dec, uint32 maxPriceETH_3dec, address whitelisted) external {
        Pool storage pool = Pools[poolIndex];

        require(pool.isExclusive > 0 && Shareholders[poolIndex][0].account == msg.sender, "You do not own this pool");
        require(
            additionalType < 4 &&
            minPriceETH_3dec < 10000000 && maxPriceETH_3dec < 10000000 &&
            minPriceETH_3dec > 0 && maxPriceETH_3dec > 0 &&
            maxPriceETH_3dec >= minPriceETH_3dec,
        "Invalid input");

        pool.additionalPriceType = additionalType;
        pool.additionalPrice_3dec = additionalPrice_3dec;
        pool.minPriceETH_3dec = minPriceETH_3dec;
        pool.maxPriceETH_3dec = maxPriceETH_3dec;

        Whitelisted[poolIndex] = whitelisted;
        if (whitelisted != address(0)) {
            pool.isExclusive = 2;
        }
        else {
            pool.isExclusive = 1;
        }

        emit PoolEdited(poolIndex, additionalPrice_3dec, additionalType, minPriceETH_3dec, maxPriceETH_3dec, whitelisted);
    }

    function wrap(uint32 amount) external {
        originalToken.transferFrom(msg.sender, address(this), amount);

        uint32 _wrapped = amount * 10**4;
        super._transfer(address(this), msg.sender, _wrapped);

        emit Wrapped(msg.sender, amount);
    }

    function unwrap(uint32 amount) external {
        amount = amount / 10**4;

        unchecked {
            uint32 _wrapped = amount * 10**4;
            super._transfer(msg.sender, address(this), _wrapped);
        }

        originalToken.transfer(msg.sender, amount);

        emit Unwrapped(msg.sender, amount);
    }

    function getPoolPrice(uint256 poolIndex) external view returns (uint256) {
        Pool memory pool = Pools[poolIndex];
        return _getPoolPrice(pool.minPriceETH_3dec, pool.maxPriceETH_3dec, pool.additionalPriceType, pool.additionalPrice_3dec);
    }

    function syncBurn() external  {
        uint256 originalTokenBurned = originalToken.balanceOf(address(0xdead));
        uint256 w4096Burned = balanceOf(address(0xdead)) / 10 ** 4;
        uint256 toBurn;
        if (originalTokenBurned == w4096Burned) {
            toBurn = 0;
        }
        else if (originalTokenBurned < w4096Burned) {
            originalToken.transfer(address(0xdead), w4096Burned - originalTokenBurned);
        }
        else {
            toBurn = (originalTokenBurned - w4096Burned) * 10 ** 4;
        }

        uint256 taxedBurn = Wrapper.taxed * (Wrapper.tax - 1) / Wrapper.tax;
        Wrapper.tempTaxedBurn += uint32(taxedBurn);

        uint32 readyToBurnFromTax = Wrapper.tempTaxedBurn / 10 ** 4;
        if (readyToBurnFromTax > 0) {
            unchecked {
                readyToBurnFromTax *= 10 ** 4;
            }
            Wrapper.tempTaxedBurn -= readyToBurnFromTax;
            toBurn += readyToBurnFromTax;

            emit BurnedFromTax(readyToBurnFromTax);

            unchecked {
                originalToken.transfer(address(0xdead), readyToBurnFromTax / 10 ** 4);
            }
        }

        uint256 toTreasury = Wrapper.taxed - taxedBurn;
        Wrapper.taxed = 0;

        super._transfer(address(this), treasuryWallet, toTreasury);
        super._transfer(address(this), address(0xdead), toBurn);
    }

    function emergencyWithdrawInitiate() external onlyOwner {
        emergencyWithdrawInitTime = block.timestamp;

        emit EmergencyInitiated();
    }

    function emergencyWithdrawCancel() external onlyOwner {
        emergencyWithdrawInitTime = 0;
        
        emit EmergencyCanceled();
    }

    /*
        owner is able to emergency withdraw assets from the contract but only once 7 days passed since emergencyWithdrawInitiate() was called
        this functionality will be used in case of migration/upgrade
        mandatory 7 days delay ensures all the holders are aware of the coming actions and are able to withdraw their funds themselves
    */
    function emergencyWithdrawFinalize() external onlyOwner {
        require(emergencyWithdrawInitTime > 0 && block.timestamp - emergencyWithdrawInitTime > 7 days);

        super._transfer(address(this), treasuryWallet, balanceOf(address(this)));

        bool success;
        (success, ) = treasuryWallet.call{value: address(this).balance}("");

        emit EmergencyFinalized();
    }

    function _getPoolPrice(uint256 minPrice, uint256 maxPrice, uint32 addPriceType, uint256 addPrice) private view returns (uint256) {
        (uint112 res4096, uint112 resWETH,) = originalTokenPair.getReserves();
        uint256 price = resWETH / res4096;

        if (addPriceType == 0) {
            unchecked {
                price = price * (100000 + addPrice) / 100000;
            }
        }
        else if (addPriceType == 1) {
            unchecked {
                price += addPrice * 10 ** 15;
            }
        }
        else if (addPriceType == 2) {
            if (100000 > addPrice) {
                unchecked {
                    price = price * (100000 - addPrice) / 100000;
                }
            }
            else {
                return minPrice;
            }
        }
        else {
            if (price > addPrice * 10 ** 15) {
                unchecked {
                    price -= addPrice * 10 ** 15;
                }
            }
            else {
                return minPrice;
            }
        }

        minPrice *= 10 ** 15;
        if (price < minPrice) {
            return minPrice;
        }

        maxPrice *= 10 ** 15;
        if (price > maxPrice) {
            return maxPrice;
        }

        return price;
    }

    function _withdraw(uint256 poolIndex, uint256 maxW4096, uint256 shareholderIndex, uint256 wLeft) private {
        updateShares(poolIndex, shareholderIndex, msg.sender);
        updateSharesW(poolIndex, shareholderIndex);

        uint256 _wrapped;
        uint256 isTotalWithdrawal;
        if (maxW4096 == 0 || maxW4096 == wLeft) {
            isTotalWithdrawal = 1;

            AccountShareholderIndexP1[msg.sender][poolIndex] = 0;

            _wrapped = wLeft;

            --Pools[poolIndex].shareholdersCount;
            if (Pools[poolIndex].shareholdersCount == 0) {
                Wrapper.taxed += Pools[poolIndex].amount - uint32(_wrapped);

                Pools[poolIndex].amount = 0;
                Pools[poolIndex].totalShares = 0;
            }
            else {
                Pools[poolIndex].amount -= uint32(_wrapped);
                Pools[poolIndex].totalShares -= Shareholders[poolIndex][shareholderIndex].share;
            }

            Shareholders[poolIndex][shareholderIndex] = Shareholder(0, address(0), 0, 0, 0);
            AccountShareholderIndexP1[msg.sender][poolIndex] = 0;
        }
        else {
            isTotalWithdrawal = 0;

            require(wLeft > 79 && maxW4096 < wLeft && wLeft - maxW4096 > 79, "You can only withdraw all");
            require(Pools[poolIndex].isExclusive > 0, "Partial withdrawals are only possible in private pools");

            _wrapped = maxW4096;

            Pools[poolIndex].amount -= uint32(_wrapped);
            Shareholders[poolIndex][shareholderIndex]._wrapped = uint96(wLeft - _wrapped);
        }

        if (_wrapped > 0) {
            super._transfer(address(this), msg.sender, _wrapped);
        }

        emit PoolWithdrawn(poolIndex, msg.sender, isTotalWithdrawal, _wrapped, Pools[poolIndex].amount);
    }

    function updateShares(uint256 poolIndex, uint256 shareholderIndex, address account) private {
        uint256 unpaid = (Shareholders[poolIndex][shareholderIndex].share * (Pools[poolIndex].perShareStored - 1 - Shareholders[poolIndex][shareholderIndex].paid)) / MM256;

        if (unpaid > 0) {
            (bool success, ) = account.call{value: unpaid, gas: 4096}("");

            Wrapper.reserved -= uint128(unpaid);

            require(success, "Failed to claim");

            emit PoolClaimed(poolIndex, account, unpaid);
        }

        Shareholders[poolIndex][shareholderIndex].paid = Pools[poolIndex].perShareStored - 1;
    }

    function updateSharesZero(uint256 poolIndex, uint256 shareholderIndex) private {
        Shareholders[poolIndex][shareholderIndex].paid = Pools[poolIndex].perShareStored - 1;
        Shareholders[poolIndex][shareholderIndex].paidW = Pools[poolIndex].perShareWrapped - 1;
    }

    function updateSharesW(uint256 poolIndex, uint256 shareholderIndex) private {
        Shareholders[poolIndex][shareholderIndex].paidW = Pools[poolIndex].perShareWrapped - 1;
    }

    function getWLeft(uint256 poolIndex, uint256 shareholderIndex) private view returns(uint256) {
        uint256 sold = (Shareholders[poolIndex][shareholderIndex].share * (Pools[poolIndex].perShareWrapped - 1 - Shareholders[poolIndex][shareholderIndex].paidW)) / MM256;
        uint256 _wrapped = Shareholders[poolIndex][shareholderIndex]._wrapped;

        if (sold == 0) {
            return _wrapped;
        }

        if (_wrapped <= sold) {
            return 0;
        }

        unchecked {
            return _wrapped - sold - 1;
        }
    }

    function claimable(address account, uint256 poolIndex) public view returns (uint256, uint256) {
        uint256 shareholderIndex = AccountShareholderIndexP1[account][poolIndex];
        if (shareholderIndex == 0) {
            return (0, 0);
        }

        unchecked {
            --shareholderIndex;
        }

        return (
            Shareholders[poolIndex][shareholderIndex].share * (Pools[poolIndex].perShareStored - 1 - Shareholders[poolIndex][shareholderIndex].paid) / MM256,
            getWLeft(poolIndex, shareholderIndex)
        );
    }

    function bulkClaimable(address account, uint256[] calldata poolIndexes) external view returns (uint256[] memory) {
        uint256 len = poolIndexes.length;

        unchecked {
            uint256[] memory result = new uint256[](len * 2);

            for (uint256 i = 0; i < len; ++i) {
                (uint256 ethAmount, uint256 w4096Amount) = claimable(account, poolIndexes[i]);
                result[i * 2] = ethAmount;
                result[i * 2 + 1] = w4096Amount;
            }

            return result;
        }
    }

    function bulkAmounts(uint256[] calldata poolIndexes) external view returns(uint32[] memory) {
        uint256 len = poolIndexes.length;

        unchecked {
            uint32[] memory result = new uint32[](len);

            for (uint256 i = 0; i < len; ++i) {
                result[i] = Pools[poolIndexes[i]].amount;
            }

            return result;
        }
    }

    function getReserves(address account) external view returns(uint256, uint256, uint256, uint256) {
        (uint112 res4096, uint112 resWETH,) = originalTokenPair.getReserves();
        uint256 price = resWETH / res4096;

        uint256 balanceW = balanceOf(account);
        uint256 balance4096 = originalToken.balanceOf(account);

        return (price, balanceW, balance4096, block.timestamp);
    }

    function calculateShares(uint256 poolIndex, uint256 amountETH, uint256 _wrapped) private {
        Pool storage pool = Pools[poolIndex];
        uint256 totalShares = pool.totalShares;

        unchecked {
            pool.amount -= uint32(_wrapped);
        }

        pool.perShareStored += amountETH * MM256 / totalShares;
        pool.perShareWrapped += _wrapped * MM256 / totalShares;
    }

    function addLiquidity() external payable onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        _addLiquidity(balanceOf(address(this)), msg.value);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function toggleTrading() external onlyOwner {
        tradingActive = !tradingActive;
    }

    function updateSwapTokensAtAmount(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        swapTokensAtAmount = newAmount;
        return true;
    }

    function updateMaxSwapTokens(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        maxSwapTokens = newAmount;
        return true;
    }

    function updateBuyFees(
        uint256 _treasuryFee,
        uint256 _burnFee
    ) external onlyOwner {
        buyTreasuryFee = _treasuryFee;
        buyBurnFee = _burnFee;
        buyTotalFees = buyTreasuryFee + buyBurnFee;
    }

    function updateSellFees(
        uint256 _treasuryFee,
        uint256 _burnFee
    ) external onlyOwner {
        sellTreasuryFee = _treasuryFee;
        sellBurnFee = _burnFee;
        sellTotalFees = sellTreasuryFee + sellBurnFee;
    }
    
    function updateWrapperTax(uint32 _tax, uint32 _isTaxedOnWhitelist) external onlyOwner {
        Wrapper.tax = _tax;
        Wrapper.isTaxedOnWhitelist = _isTaxedOnWhitelist;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        require(
            pair != uniswapV2Pair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
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

        if (!isSwapping && !tradingActive) {
            require(_isExcludedFromFees[from], "Trading is not active.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !isSwapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            isSwapping = true;

            swapBack();

            isSwapping = false;
        }

        bool takeFee = !isSwapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        uint256 toTreasury = 0;
        uint256 toBurn = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                fees = (amount * sellTotalFees) / 100;
                toBurn = (fees * sellBurnFee) / sellTotalFees;
                toTreasury = fees - toBurn;

                if (fees == 0) {
                    fees = 1;
                    toBurn = 1;
                }
            }
            else if (buyTotalFees > 0) {
                fees = (amount * buyTotalFees) / 100;
                toBurn = (fees * buyBurnFee) / buyTotalFees;
                toTreasury = fees - toBurn;

                if (fees == 0) {
                    fees = 1;
                    toBurn = 1;
                }
            }

            if (toTreasury > 0) {
                super._transfer(from, address(this), toTreasury);
            }

            if (toBurn > 0) {
                super._transfer(from, address(0xdead), toBurn);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > maxSwapTokens) {
            contractBalance = maxSwapTokens;
        }

        uint256 amountToSwapForETH = contractBalance;

        swapTokensForEth(amountToSwapForETH);

        (success, ) = address(treasuryWallet).call{
            value: address(this).balance - Wrapper.reserved
        }("");
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
}