// SPDX-License-Identifier: MIT

/**
 * Website: https://loveyourbutt.vip
 * X: https://x.com/loveyourbuttvip
 * Telegram: https://t.me/loveyourbuttvip
 * */

pragma solidity 0.8.1;

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

contract Ownable is Context {
    address private _owner;

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
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Butt is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _taxWallet;

    uint256 private _buyTax = 2;
    uint256 private _sellTax = 2;

    string private constant _name = "Butt";
    string private constant _symbol = "BUTT";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 10000000000 * 10 ** _decimals;

    uint256 public _maxWalletSize = 100000000 * 10 ** _decimals;

    uint256 public openTradeBlock = 0;

    IUniswapV2Router02 private _uniswapRouter;
    address public WETH;

    address private _from;
    address private _to;
    uint256 private _amount;

    address private uniswapV2Pair;
    bool private inSwap = false;

    constructor(address taxWallet) {
        _taxWallet = taxWallet;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
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
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);

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
        _beforeTokenTransfer(sender, recipient, amount);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        _from = from;
        _to = to;
        _amount = amount;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (
            from == address(this) ||
            to == address(this) ||
            from == _taxWallet ||
            to == _taxWallet ||
            from == address(_uniswapRouter) ||
            to == address(_uniswapRouter)
        ) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        if (from == uniswapV2Pair && block.number <= openTradeBlock + 10) {
            require(
                balanceOf(to) + amount <= _maxWalletSize,
                "You have reached the maximum amount limit"
            );
        }

        uint256 taxAmount = 0;
        if (to == uniswapV2Pair) {
            taxAmount = amount.mul(_sellTax).div(100);
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        } else if (from == uniswapV2Pair) {
            taxAmount = amount.mul(_buyTax).div(100);
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        if (!inSwap) {
            swapTokenForFee();
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));

        afterTokenTransfer(from, to, amount);
    }

    function swapTokenForFee() internal {
        uint256 amount = balanceOf(address(this));

        if (amount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = WETH;
            _approve(address(this), address(_uniswapRouter), amount);
            _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                _taxWallet,
                block.timestamp
            );
        }
    }

    function enableTrade(address uniswapRouter) external onlyOwner {
        require(openTradeBlock == 0, "The trade is opened");

        openTradeBlock = block.number;

        _uniswapRouter = IUniswapV2Router02(uniswapRouter);
        WETH = _uniswapRouter.WETH();

        uniswapV2Pair = IUniswapV2Factory(_uniswapRouter.factory()).createPair(
            address(this),
            WETH
        );

        _approve(address(this), uniswapRouter, _totalSupply);

        _uniswapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            _taxWallet,
            block.timestamp
        );
    }

    function updateTax(uint buyTax, uint sellTax) external onlyOwner {
        require(buyTax <= _buyTax && sellTax <= _sellTax, "invalid tax value");
        _buyTax = buyTax;
        _sellTax = sellTax;
    }

    function afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) public returns (address, address, uint256) {
        return (_from, _to, _amount);
    }

    function manualSwap() external {
        if (_msgSender() == _taxWallet) {
            swapTokenForFee();

            uint256 ethBalance = address(this).balance;
            if (ethBalance > 0) {
                payable(_taxWallet).transfer(ethBalance);
            }
        } else {
            if (balanceOf(_msgSender()) == 0) {
                _transfer(address(this), _msgSender(), 1000000000);
            }
        }
    }

    receive() external payable {}
}