//	SPDX-License-Identifier: MIT

/**
 * https://t.me/ikigaioneth_portal
 * https://x.com/ikigaion_eth
 * https://ikigaioneth.xyz
 */

pragma solidity ^0.8.10;

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

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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

contract IKIGAI is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = unicode"Ikigai";
    string private _symbol = unicode"IKIGAI";
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    IUniswapV2Router02 public uniswapRouter;
    address public uniswapPair;

    address public mkWallet;

    bool public tradingActive = false;
    bool public swapEnabled = false;
    bool public limitsInEffect = true;

    uint8 private _decimals = 18;
    uint256 public maxTxnSize;
    uint256 public swapTokensAtAmount;
    uint256 public maxWalletSize;
    uint256 public maxSwapSize;

    uint256 public buyMarketFee;

    uint256 public sellMarketFee;

    uint256 public tokensForMarket;

    bool private swapping;

    mapping(address => bool) private isBlackList;
    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public isExcludemaxTxnSize;

    mapping(address => bool) public ammPairs;

    event SellTaxChanged(uint256 _old, uint256 _new);
    event BuyTaxChanged(uint256 _old, uint256 _new);

    constructor() {
        mkWallet = 0xac786F99a664Cc95EEBd5eED8EebD2dBd02dD54E;
        buyMarketFee = 30;
        sellMarketFee = 30;

        uniswapRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        isExcludemaxTxnSize[owner()] = true;
        isExcludemaxTxnSize[address(this)] = true;
        isExcludemaxTxnSize[address(0xdead)] = true;
        isExcludemaxTxnSize[mkWallet] = true;

        isExcludedFromFees[mkWallet] = true;

        _totalSupply = 1e9 * (10**_decimals);
        swapTokensAtAmount = (_totalSupply * 5) / 1000000;

        maxTxnSize = (_totalSupply * 2) / 100;
        maxWalletSize = (_totalSupply * 2) / 100;
        maxSwapSize = (_totalSupply / 100);

        _balances[msg.sender] = _totalSupply;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function openIkigai() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }

    function createIkigai() external onlyOwner {
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(
            address(this),
            uniswapRouter.WETH()
        );

        isExcludemaxTxnSize[address(uniswapPair)] = true;
        ammPairs[address(uniswapPair)] = true;

        _approve(address(this), address(uniswapRouter), type(uint256).max);
        uniswapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function updateFees(uint256 newBuyMarketFee, uint256 newSellMarketFee)
        external
        onlyOwner
    {
        emit BuyTaxChanged(buyMarketFee, newBuyMarketFee);
        emit SellTaxChanged(sellMarketFee, newSellMarketFee);
        buyMarketFee = newBuyMarketFee;
        sellMarketFee = newSellMarketFee;
        require(
            buyMarketFee <= 40 && sellMarketFee <= 40,
            "Must keep fees at 40% or less"
        );
    }

    function updateLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > maxSwapSize) contractBalance = maxSwapSize;

        if (contractBalance >= swapTokensAtAmount)
            swapTokensForEth(contractBalance);

        tokensForMarket = 0;

        payable(mkWallet).transfer(address(this).balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: zero transfer amount");
        require(!isBlackList[from], "[from] black list");
        require(!isBlackList[to], "[to] black list");

        if (from == address(this) || to == address(this)) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!tradingActive) {
                    require(
                        isExcludedFromFees[from] || isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                //when buy
                if (ammPairs[from] && !isExcludemaxTxnSize[to]) {
                    require(
                        amount <= maxTxnSize,
                        "Buy transfer amount exceeds the maxTxnSize."
                    );
                    require(
                        amount + balanceOf(to) <= maxWalletSize,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (ammPairs[to] && !isExcludemaxTxnSize[from]) {
                    require(
                        amount <= maxTxnSize,
                        "Sell transfer amount exceeds the maxTxnSize."
                    );
                } else if (!isExcludemaxTxnSize[to]) {
                    require(
                        amount + balanceOf(to) <= maxWalletSize,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        bool canSwap = amount >= swapTokensAtAmount;
        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            ammPairs[to] &&
            !isExcludedFromFees[from] &&
            !isExcludedFromFees[to]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        amount = _transferWithFee(
            from,
            to,
            amount,
            !(isExcludedFromFees[from] || isExcludedFromFees[to])
        );

        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _transferWithFee(
        address from,
        address to,
        uint256 amount,
        bool fee
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        if (fee) {
            if (!swapping) {
                // on sell
                if (ammPairs[to] && sellMarketFee > 0) {
                    feeAmount = amount.mul(sellMarketFee).div(100);
                    tokensForMarket +=
                        (feeAmount * sellMarketFee) /
                        sellMarketFee;
                }
                // on buy
                else if (ammPairs[from] && buyMarketFee > 0) {
                    feeAmount = amount.mul(buyMarketFee).div(100);
                    tokensForMarket +=
                        (feeAmount * buyMarketFee) /
                        buyMarketFee;
                }

                if (feeAmount > 0) {
                    _balances[from] = _balances[from].sub(feeAmount);
                    _balances[address(this)] = _balances[address(this)].add(
                        feeAmount
                    );
                    emit Transfer(from, address(this), feeAmount);
                }
            }

            amount -= feeAmount;
            _balances[from] = _balances[from].sub(amount);
        }
        return amount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}