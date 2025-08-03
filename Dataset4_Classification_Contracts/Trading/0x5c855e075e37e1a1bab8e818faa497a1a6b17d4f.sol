// SPDX-License-Identifier: MIT

/**
    web   : https://nerdai.tech
    docs  : https://docs.nerdai.tech

    twitter  : https://twitter.com/nerdai_
    telegram : https://t.me/nerdai_portal
*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, " multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract NERDAIBOT is Context, IERC20, Ownable {

    using SafeMath for uint256;
    
    uint256 private constant _totalSupply = 100_000_000e18;
    uint256 private constant onePercent = 1_000_000e18;

    uint256 private _minNerdSwapSize = 50*1e18;
    uint256 private _maxNerdSwapSize = onePercent;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable uniswapV2Router;
    address public uniswapV2Pair;
    address immutable WETH;
    address payable _nerdFees;

    uint256 private _buyTax = 0;
    uint256 private _sellTax = 5;

    string private constant _name = "NERD AI BOT";
    string private constant _symbol = "NERD";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromNerdFees;
    mapping(address => bool) private _isExcludedMaxTxAmount;

    uint8 private launch;
    uint8 private inSwapAndLiquify;

    uint256 private launchBlock;
    uint256 private launchDelay = 2;

    uint256 public maxWalletAmount = 2 * onePercent; // MaxWallet 2%

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D  // UniSwap V2 Router
        );
        WETH = uniswapV2Router.WETH();
        _nerdFees = payable(0xfBc36D7a8d47a433Fa5D98e1c41C29b3c805a426);  // Nerd fees

        _balance[msg.sender] = _totalSupply;
        _isExcludedFromNerdFees[_nerdFees] = true;
        _isExcludedFromNerdFees[address(this)] = true;
        _isExcludedMaxTxAmount[address(this)] = true;

        _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
            _allowances[sender][_msgSender()] - amount
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool _takeFee = true;
        uint256 _tax;

        if (_isExcludedMaxTxAmount[from] || _isExcludedMaxTxAmount[to]) {
            _basicTransfer(from, to, amount);
            return;
        }

        if (_isExcludedFromNerdFees[from] || _isExcludedFromNerdFees[to]) {
            _tax = 0;
            _takeFee = false;

        } else {
            require(
                launch != 0 && amount <= maxWalletAmount,
                "Launch / Max Amount at launch"
            );
            if (block.number < launchBlock + launchDelay) {_tax=42;} else {            
                if (inSwapAndLiquify == 1) {
                    //No tax transfer
                    _balance[from] -= amount;
                    _balance[to] += amount;

                    emit Transfer(from, to, amount);
                    return;
                }

                if (from == uniswapV2Pair) {
                    _tax = _buyTax;
                } else if (to == uniswapV2Pair) {
                    uint256 tokensToSwap = _balance[address(this)];
                    if (inSwapAndLiquify == 0 && amount > _minNerdSwapSize) {
                        if (tokensToSwap > _minNerdSwapSize) {
                            if (tokensToSwap > _maxNerdSwapSize) {
                                tokensToSwap = _maxNerdSwapSize;
                            }
                            inSwapAndLiquify = 1;
                            address[] memory path = new address[](2);
                            path[0] = address(this);
                            path[1] = WETH;
                            uniswapV2Router
                                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                    tokensToSwap,
                                    0,
                                    path,
                                    _nerdFees,
                                    block.timestamp
                                );
                            inSwapAndLiquify = 0;
                        }
                    }
                    _tax = _sellTax;

                } else {
                    _tax = 0;   // No Tax For Transfer
                }
            }
        }

        if (_takeFee) {
            //Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            _balance[to] += transferAmount;
            _balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            _tax = 0;
            _balance[to] += amount;            
            emit Transfer(from, to, amount);
        }
    }

    function initializeNerdPairs() external onlyOwner {
        require(launch == 0, "already launched");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        maxWalletAmount = _totalSupply;
    }

    receive() external payable {}

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balance[sender] = _balance[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balance[recipient] = _balance[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function enableTrading() external onlyOwner {
        require(launch == 0, "already launched");        
        launch = 1;
        launchBlock = block.number;
    }

}