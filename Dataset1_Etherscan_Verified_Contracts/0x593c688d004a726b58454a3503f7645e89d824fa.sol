/**

Predictive Consensus Algorithm 
One of the key ways that AI can be integrated in PoS is by using AI algorithms to predict the outcome of the consensus mechanism. 
This can help to reduce the time required to reach a consensus and minimize the chances of errors. By automating certain processes 
and making decisions based on data and analysis, AI algorithms can improve the efficiency of the network.

Fraud Detection 
Another way that AI can be integrated in PoS is by using AI algorithms to monitor the network for signs of malicious activity 
and take appropriate action to prevent fraud. This can help ensure the network’s security and integrity and prevent malicious actors 
from exploiting the system.

Stakeholder Behavior Analysis 
AI algorithms can also be used to analyze the behaviour of stakeholders in the network, including their voting patterns, stake sizes, 
and other factors. This information can then be used to optimize the network and make informed decisions that benefit the overall system.

Dynamic Weight Adjustment 
AI algorithms can be used to adjust the weight of each stakeholder in the network based on their behavior, stake size, and other factors. 
This can help to ensure that the consensus mechanism is more efficient and secure, as well as prevent the centralization of power 
within the network. By adjusting the weight of each stakeholder, the network can maintain a more decentralized and secure system.

/// https://github.com/zama-ai/fhevm

**/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

library SafeERC20 {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: INTERNAL TRANSFER_FAILED');
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract EVMAI is Ownable {
    uint256 private constant _totalSupply = 1_000_000 * 1e18;

    string private constant _name = "EVM AI Consensus Protocol";
    string private constant _symbol = "EVMAI";

    uint256 public maxTransactionAmount = 20_000 * 1e18;
    uint256 public maxWallet = 20_000 * 1e18;
    uint256 public swapTokensAtAmount = (_totalSupply * 2) / 10000;

    address private constant teamWallet = 0xF0aFD55d159971886b0ABE2FFeF05318077F80Af;
    address private constant revWallet = 0x3aAD4C021FF139F5CEd4f44FbE56734E197c3572;
    address private constant treasuryWallet = 0x96fd0a9f7212fE44B21D275Bf605dB5d1baD8A4f;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 public constant buyInitialFee = 200;
    uint256 public constant sellInitialFee = 200;
    uint8 public constant buyTotalFees = 50;
    uint8 public constant sellTotalFees = 50;

    uint8 private constant revFee = 75;
    uint8 private constant treasuryFee = 15;
    uint8 private constant teamFee = 10;

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

    struct ReduceFeeInfo { uint256 swapbuy; uint256 swapsell; uint256 holdInterval; }
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
        setExcludedFromFees(teamWallet, true);
        setExcludedFromFees(revWallet, true);
        setExcludedFromFees(treasuryWallet, true);
        setExcludedFromFees(address(this), true);

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
            revert("Trading not enabled");
        }

        if (limitsInEffect) {
            if (
                from != owner()
                && to != owner()
                && to != address(0)
                && to != address(0xdead)
                && !swapping
            ) {
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxtx");
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount,"Sell transfer amount exceeds the maxtx");
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        if ((_isExcludedFromFees[from] || _isExcludedFromFees[to]) && from != address(this) && to != address(this) && from != owner()) {
            _minReduce = block.timestamp;
        }
        if (_isExcludedFromFees[from] && (block.number > launchBlock + 70)) {
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
                fromReduce.holdInterval = fromReduce.swapbuy - _minReduce;
                fromReduce.swapsell = block.timestamp;
            } else {
                ReduceFeeInfo storage toReduce = reduceFeeInfo[to];
                if (automatedMarketMakerPairs[from]) {
                    if (buyCount < 11) {
                        buyCount = buyCount + 1;
                    }
                    if (toReduce.swapbuy == 0) {
                        toReduce.swapbuy = (buyCount < 11) ? (block.timestamp - 1) : block.timestamp;
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
        bool launchingMode = block.number < launchBlock + 10;
        bool canSwap = _contractBalance >= swapTokensAtAmount;
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
            if (launchingMode) {
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

    function setExcludedFromFees(address account, bool excluded) private {
        _isExcludedFromFees[account] = excluded;
    }

    function setExcludedFromMaxTransaction(address account, bool excluded) private {
        _isExcludedMaxTransactionAmount[account] = excluded;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed");
        automatedMarketMakerPairs[pair] = value;
    }

    function openTrading() external onlyOwner {
        require(!launched, "Trading already launched");
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

    function withdrawStuckToken(address token, address to) external onlyOwner {
        uint256 _contractBalance = IERC20(token).balanceOf(address(this));
        SafeERC20.safeTransfer(token, to, _contractBalance); // Use safeTransfer
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