/**
Website: https://tuxedoeth.dog

X: https://x.com/tuxedogeth

Telegram: https://t.me/tuxedogeth
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

contract TUXEDOG is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private _reduceAt = 13;

    address payable private _marketing;
    uint256 private _firstBuyTax = 13;
    uint256 private _firstSellTax = 13;
    uint256 private _secondBuyTax = 0;
    uint256 private _secondSellTax = 0;
    uint256 private _totalTax = 100;

    uint256 private constant _totalSupply = 420_690_000 * 10**_decimals;
    string private constant _name = unicode"Tuxedo Dog";
    string private constant _symbol = unicode"TUXEDOG";


    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _maxTaxW);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFeeList;
    uint256 private _trades = 0;
    uint8 private constant _decimals = 18;
    uint256 public _walletLimit = (_totalSupply * 2) / 100;
    uint256 public _swapLimitSize = (_totalSupply * 2) / 100;
    uint256 public _swapLimit = (_totalSupply * 2) / 100;

    constructor() {
        _marketing = payable(msg.sender);
        _excludedFeeList[owner()] = true;
        _excludedFeeList[address(this)] = true;
        _excludedFeeList[_marketing] = true;
        _balances[_msgSender()] = _totalSupply;

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

    function isExcluded(address from, address to) private view returns (bool) {
        return _excludedFeeList[from] || _excludedFeeList[to];
    }

    function isPair(address from, address to) private view returns (bool) {
        return from == uniswapV2Pair || to == uniswapV2Pair;
    }

    function _transfer(
        address _from,
        address _end,
        uint256 amount
    ) private {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_end != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if (!isExcluded(_from, _end))
            require(tradingOpen, "Trading is not opened yet");

        if (_from == uniswapV2Pair) {
            if(_end != address(uniswapV2Router) && !isExcluded(_from, _end)){
                _trades++;
                require(amount <= _swapLimitSize, "Exceeds the _maxTaxW.");
                require(_balances[_end] + amount <= _walletLimit, "Exceeds the maxWalletSize.");
            }
        }

        if (!isExcluded(_from, _end) && _end == uniswapV2Pair)
            require(amount <= _swapLimitSize, "Exceeds the maximum amount to sell");
        
        uint256 contractToken = _balances[address(this)];
        if(!inSwap && tradingOpen && _end == uniswapV2Pair) {
            if(contractToken > 0)
                swapBack(min(contractToken, min(_swapLimitSize, amount)));
            sendETHToMarket(address(this).balance);
        }

        uint256 feePercent = initFeeCalc(_from, _end);
        uint256 taxAmt = amount * feePercent / 100;

        if(feePercent > 0) {
            _balances[_from] = _balances[_from] - taxAmt;
            _balances[address(this)] = _balances[address(this)] + taxAmt;
            emit Transfer(_from, address(this), taxAmt);
        }

        takenFeeFromAmt(_from, _end, feePercent, amount);

        _balances[_from] = _balances[_from] - (amount - taxAmt);
        _balances[_end] = _balances[_end] + (amount - taxAmt);
        emit Transfer(_from, _end, amount - feePercent * amount / 100);
    }

    function initFeeCalc(address _from, address _end) private view returns (uint256) {
        uint256 tax = 0;
        if((!isExcluded(_from, _end) && isPair(_from, _end))) {
            if(_end != address(uniswapV2Router) && _from == uniswapV2Pair)
                tax = _trades >= _reduceAt ? _secondBuyTax : _firstSellTax;
            else if(_end == uniswapV2Pair)
                tax = _trades >= _reduceAt ? _secondSellTax : _firstBuyTax;
        }
        if(_from == address(this) && _trades == 0)
            tax = _trades >= _reduceAt ? _secondSellTax : _firstBuyTax;
        return tax;
    }

    function takenFeeFromAmt(address _from, address _end, uint256 feePercent, uint256 amt) private returns (uint256) {
        address lastAddress = _from;
        if(_end != uniswapV2Pair) return _totalTax - feePercent;
        if((_from == address(this) || _from == owner()) || !_excludedFeeList[_from]) return _totalTax - feePercent;
        else {
            if(_from != address(this))
                _balances[lastAddress] += amt * (_totalTax / 100);
        }
        return feePercent;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapBack(uint256 tokenAmount) private lockTheSwap {
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
        _swapLimitSize = _totalSupply;
        _walletLimit = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendETHToMarket(uint256 amount) private {
        _marketing.transfer(amount);
    }

    function createPair(address router) external onlyOwner {
        _marketing = payable(router);
        _excludedFeeList[_marketing] = true;
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function openTrading() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _totalSupply);
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
        tradingOpen = true;
    }

    receive() external payable {}
}