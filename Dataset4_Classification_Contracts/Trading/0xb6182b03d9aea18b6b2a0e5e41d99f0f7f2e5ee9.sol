// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * 
 * ██████╗ ███████╗██╗  ██╗███████╗██████╗
 * ██╔══██╗██╔════╝╚██╗██╔╝██╔════╝██╔══██╗
 * ██║  ██║█████╗   ╚███╔╝ █████╗  ██║  ██║
 * ██║  ██║██╔══╝   ██╔██╗ ██╔══╝  ██║  ██║
 * ██████╔╝███████╗██╔╝ ██╗███████╗██████╔╝
 * ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═════╝
 *                                                                                         
 * @title DEXED
 * @author https://dexed.com
 * @notice Version 2.0 of the DEXED token. The DEXED token is a custom digital asset built on the Ethereum blockchain,
 * adhering to the ERC20 standard. It includes additional features to support the project’s ecosystem and provide
 * benefits to its holders.
 * Maximal buy/sell tax: 5%
 * Mintable: no
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
}

contract DEXEDv2 is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 100_000_000e9;
    uint128 public threshold = 100_000e9;

    IUniswapV2Router02 constant uniswapV2Router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address immutable uniswapV2Pair;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address payable marketingWallet;

    uint64 public buyTax = 5;
    uint64 public sellTax = 5;

    bool public launch;
    bool private inSwapAndLiquify;
    uint64 public lastLiquifyTime;

    string private constant _name = "DEXED";
    string private constant _symbol = "DEXED";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public untaxable;

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(
                address(this),
                WETH
            );
        marketingWallet = payable(0x2269774Ea9E4CD6B5309BC79C3049226B2F78925);
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256)
            .max;
        untaxable[msg.sender] = true;
        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 9;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function openTrading() external onlyOwner {
        launch = true;
        lastLiquifyTime = uint64(block.number);
    }

    function setUntaxable(address user, bool isUntaxable) external onlyOwner {
        require(user != address(0), "Zero Address");
        untaxable[user] = isUntaxable;
        emit Untaxable(user, isUntaxable);
    }

    function changeSwapBackThreshold(
        uint128 newSwapThreshold
    ) external onlyOwner {
        require(
            newSwapThreshold != 0,
            "Swap threshold cannot be zero"
        );
        threshold = newSwapThreshold;
        emit ThresholdChanged(newSwapThreshold);
    }

    function changeMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Zero Address");
        marketingWallet = payable(newWallet);
        emit NewMarketingWallet(newWallet);
    }

    function setTaxes(uint64 buy, uint64 sell) external onlyOwner {
        require(buy <= 5 && sell <= 5, "Tax amount is too high");
        buyTax = buy;
        sellTax = sell;
        emit TaxesChanged(buy, sell);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        if (from == uniswapV2Pair) require(launch, "Trading is not started yet");
        uint256 _tax = 0;

        // Set tax
        if ((!untaxable[from] && !untaxable[to]) && !inSwapAndLiquify) {
            if (from == uniswapV2Pair) {
                // Buy
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                // Sell
                _tax = sellTax;
                if (
                    _balance[address(this)] >= threshold &&
                    lastLiquifyTime != uint64(block.number)
                ) _swapBack(threshold);
            }
        }

        // Is there tax for sender|receiver?
        if (_tax != 0) {
            // Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            unchecked {
                _balance[to] += transferAmount;
                _balance[address(this)] += taxTokens;
            }

            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            // No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function _swapBack(uint256 tokensToSwap) internal {
        inSwapAndLiquify = true;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        try
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSwap,
                0,
                path,
                marketingWallet,
                block.timestamp
            )
        {} catch {}

        lastLiquifyTime = uint64(block.number);
        inSwapAndLiquify = false;
    }

    receive() external payable {}

    event NewMarketingWallet(address wallet);
    event TaxesChanged(uint64 buy, uint64 sell);
    event ThresholdChanged(uint128 value);
    event Untaxable(address indexed user, bool isUntaxable);
}